import 'package:core/injecoes.dart';
import 'package:core/precos_portas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/categoria_dto.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
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
  Future<List<Categoria>> call({String? nome, bool? inativa}) async =>
      [CategoriaDto(id: 1, inativa: false, nome: 'Body')];
}

class _SubCategorias extends RecuperarSubCategorias {
  _SubCategorias() : super(subCategoriasRepository: _RepoSub());
  @override
  Future<List<SubCategoria>> call(
    int categoriaId, {
    String? nome,
    bool? inativa,
  }) async =>
      const [];
}

class _CriarReferencia extends CriarReferencia {
  _CriarReferencia() : super(referenciasRepository: _RepoRef());
}

class _ProximoId extends RecuperarProximoIdReferencia {
  _ProximoId() : super(referenciasRepository: _RepoRef());
}

class _ListarPrecos extends ListarPrecosDaReferenciaPorTabela {
  _ListarPrecos() : super(_PortaListar());
}

class _SalvarPreco extends SalvarPrecoDaReferencia {
  _SalvarPreco() : super(_PortaSalvar());
}

void main() {
  ReferenciaCadastroBloc build() => ReferenciaCadastroBloc(
        _Categorias(),
        _SubCategorias(),
        _CriarReferencia(),
        _ProximoId(),
        _ListarPrecos(),
        _SalvarPreco(),
      );

  Future<ReferenciaCadastroBloc> ate(
    String? nomeInicial,
  ) async {
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

  test('sem nome inicial mantém a geração automática pela categoria', () async {
    final bloc = await ate(null);
    expect(bloc.state.nome, 'Body');
    await bloc.close();
  });

  test('nome inicial vale no lugar do nome gerado e não bloqueia a edição',
      () async {
    final bloc = await ate('  Body rendado vinho ');
    expect(bloc.state.nome, 'Body rendado vinho');
    bloc.add(const ReferenciaCadastroNomeAlterado(nome: 'Body Aurora'));
    await bloc.stream.firstWhere((s) => s.nome == 'Body Aurora');
    expect(bloc.state.criada, isFalse);
    await bloc.close();
  });

  testWidgets('wizard: sair sem criar devolve null (show -> Future<int?>)',
      (t) async {
    t.view.physicalSize = const Size(1600, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await sl.reset();
    sl.registerFactory<ReferenciaCadastroBloc>(build);
    addTearDown(sl.reset);
    int? resultado = -1;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => resultado = await ReferenciaCadastroPage.show(
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
