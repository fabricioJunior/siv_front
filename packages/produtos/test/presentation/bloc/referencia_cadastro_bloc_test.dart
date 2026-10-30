import 'dart:typed_data';

import 'package:core/imagens.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:core/precos_portas.dart';
import 'package:core/seletores/i_seletor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/categoria_dto.dart';
import 'package:produtos/data/remote/dtos/sub_categoria_dto.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:produtos/repositorios.dart';
import 'package:produtos/use_cases.dart';

class _RepoCat implements ICategoriasRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _RepoSub implements ISubCategoriasRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _RepoRef implements IReferenciasRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _PortaListar implements PortaListarPrecosDaReferenciaPorTabela {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _PortaSalvar implements PortaSalvarPrecoDaReferencia {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _Categorias extends RecuperarCategorias {
  _Categorias() : super(categoriasRepository: _RepoCat());
  @override
  Future<List<Categoria>> call({String? nome, bool? inativa}) async => [
    CategoriaDto(id: 1, inativa: false, nome: 'Body'),
  ];
}

class _SubCategorias extends RecuperarSubCategorias {
  _SubCategorias([this.subs = const []])
    : super(subCategoriasRepository: _RepoSub());
  final List<SubCategoria> subs;
  @override
  Future<List<SubCategoria>> call(
    int categoriaId, {
    String? nome,
    bool? inativa,
  }) async => subs;
}

class _CriarReferencia extends CriarReferencia {
  _CriarReferencia() : super(referenciasRepository: _RepoRef());
}

class _ProximoId extends RecuperarProximoIdReferencia {
  _ProximoId() : super(referenciasRepository: _RepoRef());
}

class _SalvarCusto extends SalvarCustoReferencia {
  _SalvarCusto() : super(referenciasRepository: _RepoRef());
}

class _Permissoes implements IPermissoesController {
  @override
  Future<bool> acessoPermitido({String? idComponente, int? grupoId}) async =>
      true;

  @override
  bool temAcesso({String? idComponente, int? grupoId}) => true;
}

class _ListarPrecos extends ListarPrecosDaReferenciaPorTabela {
  _ListarPrecos() : super(_PortaListar());
}

class _SalvarPreco extends SalvarPrecoDaReferencia {
  _SalvarPreco() : super(_PortaSalvar());
}

class _RepoMidias implements IReferenciaMidiasRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

/// Guarda o que o wizard mandou criar, sem tocar na API.
class _CriarReferenciaFake extends CriarReferencia {
  _CriarReferenciaFake() : super(referenciasRepository: _RepoRef());
  Map<String, Object?>? enviado;

  @override
  Future<Referencia> call({
    required int id,
    required String nome,
    int? categoriaId,
    int? subCategoriaId,
    String? idExterno,
    String? unidadeMedida,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
    String? ncm,
    int? pesoGramas,
    EsperaReferencia? espera,
  }) async {
    enviado = {'categoriaId': categoriaId, 'id': id, 'idExterno': idExterno, 'espera': espera};
    return Referencia.create(id: id, nome: nome);
  }
}

class _ProximoIdFake extends RecuperarProximoIdReferencia {
  _ProximoIdFake() : super(referenciasRepository: _RepoRef());
  @override
  Future<int> call() async => 10;
}

class _ListarPrecosFake extends ListarPrecosDaReferenciaPorTabela {
  _ListarPrecosFake() : super(_PortaListar());
  @override
  Future<List<PrecoDaReferenciaPorTabela>> call({
    required int referenciaId,
  }) async => const [
    PrecoDaReferenciaPorTabela(
      tabelaDePrecoId: 1,
      tabelaNome: 'Padrão',
      tabelaInativa: false,
      tabelaPadrao: true,
    ),
  ];
}

class _SalvarPrecoFake extends SalvarPrecoDaReferencia {
  _SalvarPrecoFake() : super(_PortaSalvar());
  @override
  Future<PrecoDaReferenciaPorTabela> call({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
    required bool precoJaExiste,
  }) async => const PrecoDaReferenciaPorTabela(
    tabelaDePrecoId: 1,
    tabelaNome: 'Padrão',
    tabelaInativa: false,
    tabelaPadrao: true,
  );
}

class _CriarMidiaFake extends CriarReferenciaMidia {
  _CriarMidiaFake({this.falha = false})
    : super(referenciaMidiasRepository: _RepoMidias());
  final bool falha;
  final enviadas = <Map<String, Object?>>[];

  @override
  Future<ReferenciaMidia> call({
    required Uint8List bytes,
    required String fileName,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    required TipoReferenciaMidia tipo,
    required String field,
    required String? descricao,
    required String? cor,
    required String? tamanho,
    String origem = 'site',
    void Function(int sent, int total)? onSendProgress,
  }) async {
    if (falha) throw Exception('upload falhou');
    enviadas.add({
      'referenciaId': referenciaId,
      'ePublica': ePublica,
      'ePrincipal': ePrincipal,
      'origem': origem,
    });
    return ReferenciaMidia.create(
      id: 1,
      url: 'x',
      referenciaId: referenciaId,
      ePrincipal: ePrincipal,
      ePublica: ePublica,
      origem: origem,
    );
  }
}

void main() {
  ReferenciaCadastroBloc build({
    CriarReferencia? criar,
    CriarReferenciaMidia? midia,
    bool fake = false,
    List<SubCategoria> subs = const [],
  }) => ReferenciaCadastroBloc(
    _Categorias(),
    _SubCategorias(subs),
    criar ?? _CriarReferencia(),
    fake ? _ProximoIdFake() : _ProximoId(),
    _SalvarCusto(),
    fake ? _ListarPrecosFake() : _ListarPrecos(),
    fake ? _SalvarPrecoFake() : _SalvarPreco(),
    midia ?? _CriarMidiaFake(),
  );

  // Leva o wizard até o preço, com o preço preenchido.
  Future<ReferenciaCadastroBloc> atePreco(ReferenciaCadastroBloc bloc) async {
    bloc.add(ReferenciaCadastroIniciou());
    await bloc.stream.firstWhere((s) => s.categorias.isNotEmpty);
    bloc.add(
      ReferenciaCadastroCategoriaSelecionada(
        categoria: CategoriaDto(id: 1, inativa: false, nome: 'Body'),
      ),
    );
    await bloc.stream.firstWhere((s) => s.step == ReferenciaCadastroStep.nome);
    bloc.add(ReferenciaCadastroProximo());
    await bloc.stream.firstWhere((s) => s.step == ReferenciaCadastroStep.preco);
    bloc.add(const ReferenciaCadastroPrecoAlterado(preco: '49,90'));
    await bloc.stream.firstWhere((s) => s.preco == '49,90');
    return bloc;
  }

  Future<ReferenciaCadastroBloc> ate(String? nomeInicial) async {
    final bloc = build();
    bloc.add(ReferenciaCadastroIniciou(nomeInicial: nomeInicial));
    await bloc.stream.firstWhere((s) => s.categorias.isNotEmpty);
    bloc.add(
      ReferenciaCadastroCategoriaSelecionada(
        categoria: CategoriaDto(id: 1, inativa: false, nome: 'Body'),
      ),
    );
    await bloc.stream.firstWhere((s) => s.step == ReferenciaCadastroStep.nome);
    return bloc;
  }

  group('categoria e subcategoria opcionais', () {
    Future<ReferenciaCadastroBloc> iniciado(ReferenciaCadastroBloc bloc) async {
      bloc.add(ReferenciaCadastroIniciou());
      await bloc.stream.firstWhere((s) => s.categorias.isNotEmpty);
      return bloc;
    }

    test('pular subcategoria vai pro nome com o nome da categoria', () async {
      final bloc = await iniciado(
        build(subs: [SubCategoriaDto(id: 5, categoriaId: 1, inativa: false, nome: 'Alca')]),
      );
      bloc.add(
        ReferenciaCadastroCategoriaSelecionada(
          categoria: CategoriaDto(id: 1, inativa: false, nome: 'Body'),
        ),
      );
      await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.subCategoria,
      );
      bloc.add(const ReferenciaCadastroPular());
      final s = await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.nome,
      );
      expect(s.subCategoria, isNull);
      expect(s.categoria?.id, 1);
      expect(s.nome, 'Body');
      await bloc.close();
    });

    test('pular categoria vai pro nome vazio e permite voltar', () async {
      final bloc = await iniciado(build());
      bloc.add(const ReferenciaCadastroPular());
      final s = await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.nome,
      );
      expect(s.categoria, isNull);
      expect(s.subCategoria, isNull);
      expect(s.nome, '');
      bloc.add(ReferenciaCadastroVoltar());
      await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.categoria,
      );
      await bloc.close();
    });

    test('criar sem categoria envia categoriaId nulo', () async {
      final criar = _CriarReferenciaFake();
      final bloc = await iniciado(build(criar: criar, fake: true));
      bloc.add(const ReferenciaCadastroPular());
      await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.nome,
      );
      bloc.add(const ReferenciaCadastroNomeAlterado(nome: 'Livre'));
      bloc.add(ReferenciaCadastroProximo());
      await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.preco,
      );
      bloc.add(const ReferenciaCadastroPrecoAlterado(preco: '10,00'));
      await bloc.stream.firstWhere((s) => s.preco == '10,00');
      bloc.add(ReferenciaCadastroProximo());
      await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.variacoes,
      );
      expect(criar.enviado!['categoriaId'], isNull);
      await bloc.close();
    });
  });

  test('sem nome inicial mantém a geração automática pela categoria', () async {
    final bloc = await ate(null);
    expect(bloc.state.nome, 'Body');
    await bloc.close();
  });

  test(
    'nome inicial vale no lugar do nome gerado e não bloqueia a edição',
    () async {
      final bloc = await ate('  Body rendado vinho ');
      expect(bloc.state.nome, 'Body rendado vinho');
      bloc.add(const ReferenciaCadastroNomeAlterado(nome: 'Body Aurora'));
      await bloc.stream.firstWhere((s) => s.nome == 'Body Aurora');
      expect(bloc.state.criada, isFalse);
      await bloc.close();
    },
  );

  test('custo de compra digitado fica no state', () async {
    final bloc = await ate(null);
    bloc.add(const ReferenciaCadastroCustoAlterado(custo: '12,50'));
    await bloc.stream.firstWhere((s) => s.custo == '12,50');
    await bloc.close();
  });

  group('referência esperada', () {
    final fornecedor = SelectData(id: 7, nome: 'Duloren', data: const {});

    test('"Definir na chegada" cria só a referência: fornecedor, código e qtd, sem variações', () async {
      final criar = _CriarReferenciaFake();
      final midia = _CriarMidiaFake();
      final bloc = await atePreco(build(criar: criar, midia: midia, fake: true));
      bloc
        ..add(ReferenciaCadastroFornecedorAlterado(fornecedor))
        ..add(const ReferenciaCadastroCodigoFornecedorAlterado(' DL-2231 '))
        ..add(const ReferenciaCadastroDefinirNaChegadaAlterado(true))
        ..add(const ReferenciaCadastroQuantidadeEsperadaAlterada('24'));
      await bloc.stream.firstWhere((s) => s.quantidadeEsperada == '24');

      bloc.add(ReferenciaCadastroProximo());
      final fim = await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.concluido,
      );

      expect(fim.referenciaId, 10);
      expect(criar.enviado!['idExterno'], 'DL-2231');
      expect(
        criar.enviado!['espera'],
        const EsperaReferencia(fornecedorId: 7, quantidadeEsperada: 24),
      );
      expect(midia.enviadas, isEmpty); // sem foto escolhida
      await bloc.close();
    });

    test('foto do fornecedor sobe como interna: nunca pública nem capa', () async {
      final midia = _CriarMidiaFake();
      final bloc = await atePreco(
        build(criar: _CriarReferenciaFake(), midia: midia, fake: true),
      );
      bloc
        ..add(const ReferenciaCadastroDefinirNaChegadaAlterado(true))
        ..add(
          ReferenciaCadastroFotoFornecedorAlterada(
            Imagem(path: '/tmp/foto.jpg', bytes: Uint8List.fromList([1, 2, 3])),
          ),
        );
      await bloc.stream.firstWhere((s) => s.fotoFornecedor != null);

      bloc.add(ReferenciaCadastroProximo());
      await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.concluido,
      );

      expect(midia.enviadas, [
        {'referenciaId': 10, 'ePublica': false, 'ePrincipal': false, 'origem': 'fornecedor'},
      ]);
      await bloc.close();
    });

    test('falha no envio da foto não desfaz a criação e avisa', () async {
      final bloc = await atePreco(
        build(
          criar: _CriarReferenciaFake(),
          midia: _CriarMidiaFake(falha: true),
          fake: true,
        ),
      );
      bloc
        ..add(const ReferenciaCadastroDefinirNaChegadaAlterado(true))
        ..add(
          ReferenciaCadastroFotoFornecedorAlterada(
            Imagem(bytes: Uint8List.fromList([1])),
          ),
        );
      await bloc.stream.firstWhere((s) => s.fotoFornecedor != null);

      bloc.add(ReferenciaCadastroProximo());
      final fim = await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.concluido,
      );

      expect(fim.referenciaId, 10);
      expect(fim.mensagem, contains('foto do fornecedor'));
      await bloc.close();
    });

    test('"Escolher agora" segue para as variações e ignora quantidade e foto', () async {
      final criar = _CriarReferenciaFake();
      final midia = _CriarMidiaFake();
      final bloc = await atePreco(build(criar: criar, midia: midia, fake: true));
      bloc
        ..add(const ReferenciaCadastroQuantidadeEsperadaAlterada('24'))
        ..add(
          ReferenciaCadastroFotoFornecedorAlterada(
            Imagem(bytes: Uint8List.fromList([1])),
          ),
        );
      await bloc.stream.firstWhere((s) => s.fotoFornecedor != null);

      bloc.add(ReferenciaCadastroProximo());
      await bloc.stream.firstWhere(
        (s) => s.step == ReferenciaCadastroStep.variacoes,
      );

      expect(criar.enviado!['espera'], isNull); // sem fornecedor nem qtd válida
      expect(midia.enviadas, isEmpty);
      await bloc.close();
    });
  });

  testWidgets('wizard: sair sem criar devolve null (show -> Future<int?>)', (
    t,
  ) async {
    t.view.physicalSize = const Size(1600, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await sl.reset();
    sl.registerFactory<ReferenciaCadastroBloc>(build);
    sl.registerSingleton<IPermissoesController>(_Permissoes());
    addTearDown(sl.reset);
    int? resultado = -1;
    await t.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => const ReferenciaCadastroPage(),
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                resultado = await ReferenciaCadastroPage.show(
                  context: context,
                  nomeInicial: 'Body',
                  corIdsIniciais: const [1],
                  tamanhoIdsIniciais: const [2],
                ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    expect(find.text('Nova referência'), findsOneWidget);
    await t.tap(find.byTooltip('Fechar'));
    await t.pumpAndSettle();
    expect(resultado, isNull);
  });
}
