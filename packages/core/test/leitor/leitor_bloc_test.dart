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
  final int quantidade;

  @override
  final Map<String, dynamic> dados;

  _FakeLeitorData({
    required this.codigoDeBarras,
    required this.descricao,
    required this.quantidade,
    Map<String, dynamic>? dados,
  }) : dados = dados ?? const {};
}

class _FakeLeitorDataDatasource extends Fake implements ILeitorDataDatasource {
  Future<LeitorData?> Function(String codigo)? handler;

  @override
  Future<LeitorData?> getData(String codigo) {
    return handler!(codigo);
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
      dataSource.handler = (_) async => _FakeLeitorData(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidade: 5,
            dados: const {'produtoId': 10},
          );
      return LeitorBloc(dataSource: dataSource);
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
        itens: [
          const LeitorItemContado(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidadeLida: 1,
            estoqueDisponivel: 5,
            dados: {'produtoId': 10},
          ),
        ],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 1,
          estoqueDisponivel: 5,
          dados: {'produtoId': 10},
        ),
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: true,
        tokenUltimoProduto: 1,
      ),
    ],
  );

  blocTest<LeitorBloc, LeitorState>(
    'avisa duplicidade sem interromper a contagem',
    build: () {
      dataSource.handler = (_) async => _FakeLeitorData(
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
      LeitorState.initial().copyWith(
        processando: true,
        erro: null,
        aviso: null,
        avisoTipo: null,
        ultimoCodigoInformado: '123',
      ),
      LeitorState.initial().copyWith(
        itens: [
          const LeitorItemContado(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidadeLida: 1,
            estoqueDisponivel: 5,
            dados: {},
          ),
        ],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 1,
          estoqueDisponivel: 5,
          dados: {},
        ),
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: true,
        tokenUltimoProduto: 1,
      ),
      LeitorState.initial().copyWith(
        itens: [
          const LeitorItemContado(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidadeLida: 1,
            estoqueDisponivel: 5,
            dados: {},
          ),
        ],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 1,
          estoqueDisponivel: 5,
          dados: {},
        ),
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: true,
        tokenUltimoProduto: 1,
        processando: true,
      ),
      LeitorState.initial().copyWith(
        itens: [
          const LeitorItemContado(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidadeLida: 2,
            estoqueDisponivel: 5,
            dados: {},
          ),
        ],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 2,
          estoqueDisponivel: 5,
          dados: {},
        ),
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: true,
        aviso: 'O mesmo código foi informado novamente: 123.',
        avisoTipo: LeitorAvisoTipo.codigoDuplicado,
        tokenUltimoProduto: 2,
        tokenAviso: 1,
      ),
    ],
  );

  blocTest<LeitorBloc, LeitorState>(
    'impede ultrapassar o estoque quando controlar quantidade estiver ativo',
    build: () {
      dataSource.handler = (_) async => _FakeLeitorData(
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
      LeitorState.initial(controlarQuantidade: true).copyWith(
        processando: true,
        erro: null,
        aviso: null,
        avisoTipo: null,
        ultimoCodigoInformado: '123',
      ),
      LeitorState.initial(controlarQuantidade: true).copyWith(
        itens: [
          const LeitorItemContado(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidadeLida: 1,
            estoqueDisponivel: 1,
            dados: {},
          ),
        ],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 1,
          estoqueDisponivel: 1,
          dados: {},
        ),
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: true,
        tokenUltimoProduto: 1,
      ),
      LeitorState.initial(controlarQuantidade: true).copyWith(
        itens: [
          const LeitorItemContado(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidadeLida: 1,
            estoqueDisponivel: 1,
            dados: {},
          ),
        ],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 1,
          estoqueDisponivel: 1,
          dados: {},
        ),
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: true,
        tokenUltimoProduto: 1,
        processando: true,
      ),
      LeitorState.initial(controlarQuantidade: true).copyWith(
        itens: [
          const LeitorItemContado(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidadeLida: 1,
            estoqueDisponivel: 1,
            dados: {},
          ),
        ],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 1,
          estoqueDisponivel: 1,
          dados: {},
        ),
        ultimoCodigoInformado: '123',
        erro: 'Quantidade excede o estoque disponível para Produto A.',
        tokenUltimoProduto: 1,
        tokenErro: 1,
      ),
    ],
  );

  blocTest<LeitorBloc, LeitorState>(
    'remove quantidade e exclui item quando chegar a zero',
    build: () {
      dataSource.handler = (_) async => _FakeLeitorData(
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
      LeitorState.initial().copyWith(
        itens: [
          const LeitorItemContado(
            codigoDeBarras: '123',
            descricao: 'Produto A',
            quantidadeLida: 1,
            estoqueDisponivel: 5,
            dados: {},
          ),
        ],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 2,
          estoqueDisponivel: 5,
          dados: {},
        ),
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: true,
        tokenUltimoProduto: 2,
        tokenAviso: 1,
      ),
      LeitorState.initial().copyWith(
        itens: const [],
        ultimoProdutoLido: const LeitorItemContado(
          codigoDeBarras: '123',
          descricao: 'Produto A',
          quantidadeLida: 2,
          estoqueDisponivel: 5,
          dados: {},
        ),
        ultimoCodigoInformado: '123',
        ultimoCodigoLidoValido: true,
        tokenUltimoProduto: 2,
        tokenAviso: 1,
      ),
    ],
  );
}
