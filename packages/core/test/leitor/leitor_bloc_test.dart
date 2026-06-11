// ignore_for_file: unused_element_parameter

import 'package:core/bloc_test.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';
import 'package:core/leitor/leitor_bloc/leitor_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLeitorData with LeitorData {
  @override
  final String codigoDeBarras;

  @override
  final String descricao;

  @override
  final int idReferencia;

  @override
  final String tamanho;

  @override
  final String cor;

  @override
  final int quantidade;

  @override
  final double? valor;

  @override
  final Map<String, dynamic> dados;

  _FakeLeitorData({
    required this.codigoDeBarras,
    required this.descricao,
    required this.quantidade,
    this.idReferencia = 1,
    this.tamanho = 'tam',
    this.cor = 'cor',
    this.valor,
    Map<String, dynamic>? dados,
  }) : dados = dados ?? const {};

  @override
  int get id => 1;
}

class _FakeLeitorDataDatasource extends Fake implements ILeitorDataDatasource {
  Future<LeitorData?> Function(String codigo, {int? tabelaDePrecoId})? handler;
  Future<LeitorData?> Function(int produtoId, {int? tabelaDePrecoId})?
      handlerPorProdutoId;

  @override
  Future<LeitorData?> getData(String codigo, {int? tabelaDePrecoId}) {
    return handler!(codigo, tabelaDePrecoId: tabelaDePrecoId);
  }

  @override
  Future<LeitorData?> getDataPorProdutoId(
    int produtoId, {
    int? tabelaDePrecoId,
  }) {
    final handler = handlerPorProdutoId;
    if (handler == null) {
      return Future<LeitorData?>.value(null);
    }
    return handler(produtoId, tabelaDePrecoId: tabelaDePrecoId);
  }
}

void main() {
  late _FakeLeitorDataDatasource dataSource;

  setUp(() {
    dataSource = _FakeLeitorDataDatasource();
  });

  blocTest<LeitorBloc, LeitorState>(
    'carrega um produto e incrementa a quantidade lida',
    build: () {
      dataSource.handler = (_, {tabelaDePrecoId}) async => _FakeLeitorData(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidade: 5,
            dados: const {'produtoId': 10},
          );
      return LeitorBloc(dataSource: dataSource);
    },
    act: (bloc) => bloc.add(const LeitorCodigoInformado('123')),
    expect: () => [
      isA<LeitorState>()
          .having((state) => state.processando, 'processando', true)
          .having(
            (state) => state.ultimoCodigoInformado,
            'ultimoCodigoInformado',
            '123',
          ),
      isA<LeitorState>()
          .having((state) => state.itens.length, 'itens.length', 1)
          .having(
            (state) => state.ultimoProdutoLido?.codigoDeBarras,
            'ultimoProdutoLido.codigoDeBarras',
            '123',
          )
          .having((state) => state.historico.length, 'historico.length', 1),
    ],
  );

  blocTest<LeitorBloc, LeitorState>(
    'avisa duplicidade sem interromper a contagem',
    build: () {
      dataSource.handler = (_, {tabelaDePrecoId}) async => _FakeLeitorData(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidade: 5,
          );
      return LeitorBloc(dataSource: dataSource);
    },
    act: (bloc) {
      bloc.add(const LeitorCodigoInformado('123'));
      bloc.add(const LeitorCodigoInformado('123'));
    },
    expect: () => [
      isA<LeitorState>()
          .having((state) => state.processando, 'processando', true),
      isA<LeitorState>()
          .having(
              (state) => state.itens.single.quantidadeLida, 'quantidadeLida', 1)
          .having((state) => state.historico.length, 'historico.length', 1),
      isA<LeitorState>()
          .having((state) => state.processando, 'processando', true)
          .having((state) => state.itens.single.quantidadeLida,
              'quantidadeLida', 1),
      isA<LeitorState>()
          .having(
              (state) => state.itens.single.quantidadeLida, 'quantidadeLida', 2)
          .having((state) => state.avisoTipo, 'avisoTipo',
              LeitorAvisoTipo.codigoDuplicado)
          .having((state) => state.tokenAviso, 'tokenAviso', 1)
          .having((state) => state.historico.length, 'historico.length', 2),
    ],
  );

  blocTest<LeitorBloc, LeitorState>(
    'impede ultrapassar o estoque quando controlar quantidade estiver ativo',
    build: () {
      dataSource.handler = (_, {tabelaDePrecoId}) async => _FakeLeitorData(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidade: 1,
          );
      return LeitorBloc(
        dataSource: dataSource,
        controlarQuantidade: true,
      );
    },
    act: (bloc) {
      bloc.add(const LeitorCodigoInformado('123'));
      bloc.add(const LeitorCodigoInformado('123'));
    },
    expect: () => [
      isA<LeitorState>()
          .having((state) => state.processando, 'processando', true),
      isA<LeitorState>()
          .having(
              (state) => state.itens.single.quantidadeLida, 'quantidadeLida', 1)
          .having((state) => state.historico.length, 'historico.length', 1),
      isA<LeitorState>()
          .having((state) => state.processando, 'processando', true)
          .having((state) => state.itens.single.quantidadeLida,
              'quantidadeLida', 1),
      isA<LeitorState>()
          .having((state) => state.erro, 'erro',
              'Quantidade excede o estoque disponível para Produto A.')
          .having((state) => state.tokenErro, 'tokenErro', 1)
          .having((state) => state.historico.length, 'historico.length', 1),
    ],
  );

  blocTest<LeitorBloc, LeitorState>(
    'repasse a tabela de preço e calcula o total lido quando informado',
    build: () {
      dataSource.handler = (_, {tabelaDePrecoId}) async {
        expect(tabelaDePrecoId, 99);
        return _FakeLeitorData(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidade: 5,
          valor: 12.5,
        );
      };
      return LeitorBloc(
        dataSource: dataSource,
        tabelaDePrecoId: 99,
      );
    },
    act: (bloc) => bloc.add(const LeitorCodigoInformado('123')),
    verify: (bloc) {
      expect(bloc.state.ultimoProdutoLido?.valorUnitario, 12.5);
      expect(bloc.state.valorTotalLido, 12.5);
    },
  );

  blocTest<LeitorBloc, LeitorState>(
    'bloqueia leitura quando exigir preço e o produto estiver sem preço',
    build: () {
      dataSource.handler = (_, {tabelaDePrecoId}) async {
        expect(tabelaDePrecoId, 10);
        return _FakeLeitorData(
          codigoDeBarras: '123',
          descricao: 'Produto sem preço',
          quantidade: 5,
          valor: 0,
        );
      };
      return LeitorBloc(
        dataSource: dataSource,
        tabelaDePrecoId: 10,
        aceitarApenasProdutosComPreco: true,
      );
    },
    act: (bloc) => bloc.add(const LeitorCodigoInformado('123')),
    expect: () => [
      LeitorState.initial().copyWith(
        processando: true,
        erro: null,
        aviso: null,
        avisoTipo: null,
        ultimoCodigoInformado: '123',
      ),
      LeitorState.initial().copyWith(
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: false,
        erro: 'Produto sem preço cadastrado para a tabela de preço informada.',
        tokenErro: 1,
      ),
    ],
  );

  blocTest<LeitorBloc, LeitorState>(
    'remove quantidade e exclui item quando chegar a zero',
    build: () {
      dataSource.handler = (_, {tabelaDePrecoId}) async => _FakeLeitorData(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidade: 5,
          );
      return LeitorBloc(dataSource: dataSource);
    },
    act: (bloc) async {
      bloc.add(const LeitorCodigoInformado('123'));
      bloc.add(const LeitorCodigoInformado('123'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        const LeitorQuantidadeRemovida(codigo: '123', quantidade: 1),
      );
      bloc.add(
        const LeitorQuantidadeRemovida(codigo: '123', quantidade: 1),
      );
    },
    skip: 4,
    expect: () => [
      isA<LeitorState>()
          .having(
              (state) => state.itens.single.quantidadeLida, 'quantidadeLida', 1)
          .having((state) => state.historico.length, 'historico.length', 3),
      isA<LeitorState>()
          .having((state) => state.itens.isEmpty, 'itens.isEmpty', true)
          .having((state) => state.ultimoProdutoLido, 'ultimoProdutoLido', null)
          .having((state) => state.historico.length, 'historico.length', 4),
    ],
  );

  blocTest<LeitorBloc, LeitorState>(
    'pre-carregamento com controle ativo ignora estoque zero, limita quantidade e emite aviso',
    build: () {
      dataSource.handler = (codigo, {tabelaDePrecoId}) async {
        if (codigo == '222') {
          return _FakeLeitorData(
            codigoDeBarras: '222',
            descricao: 'Produto limitado',
            quantidade: 3,
          );
        }
        return null;
      };
      dataSource.handlerPorProdutoId = (produtoId, {tabelaDePrecoId}) async {
        if (produtoId == 1) {
          return _FakeLeitorData(
            codigoDeBarras: '111',
            descricao: 'Produto sem estoque',
            quantidade: 0,
          );
        }
        if (produtoId == 2) {
          return _FakeLeitorData(
            codigoDeBarras: '222',
            descricao: 'Produto limitado',
            quantidade: 3,
          );
        }
        return null;
      };
      return LeitorBloc(
        dataSource: dataSource,
        controlarQuantidade: true,
      );
    },
    act: (bloc) {
      bloc.add(
        const LeitorProdutosPreCarregadosInformados([
          LeitorProdutoPreCarregado(produtoId: 1, quantidade: 2),
          LeitorProdutoPreCarregado(produtoId: 2, quantidade: 10),
        ]),
      );
    },
    expect: () => [
      isA<LeitorState>()
          .having(
            (state) => state.aviso
                ?.contains('Pré-carregamento concluído com ajustes:'),
            'aviso de ajustes',
            true,
          )
          .having((state) => state.tokenAviso, 'tokenAviso', 1),
      isA<LeitorState>()
          .having((state) => state.processando, 'processando', true)
          .having((state) => state.ultimoCodigoInformado,
              'ultimoCodigoInformado', '222'),
      isA<LeitorState>()
          .having((state) => state.itens.length, 'itens.length', 1)
          .having((state) => state.itens.single.codigoDeBarras, 'codigo', '222')
          .having((state) => state.itens.single.quantidadeLida,
              'quantidadeLida', 3),
    ],
  );
}
