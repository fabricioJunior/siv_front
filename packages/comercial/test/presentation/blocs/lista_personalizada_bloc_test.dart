import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/arquivos.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements IListaPersonalizadaRepository {
  final chamadas = <String>[];
  ListaItensLote? lote;
  ListaPersonalizadaInput? criado;

  ListaPersonalizada _lista({String? icone}) => ListaPersonalizada(
        id: 5,
        hash: 'h',
        situacao: ListaPersonalizadaSituacao.ativa,
        tipo: ListaTipo.catalogo,
        icone: icone,
      );

  @override
  Future<ListaPersonalizada> criar(ListaPersonalizadaInput input) async {
    chamadas.add('criar');
    criado = input;
    return _lista();
  }

  @override
  Future<ListaPersonalizada> enviarIcone(int id, Uint8List bytes, String fileName) async {
    chamadas.add('icone($id,$fileName)');
    return _lista(icone: 'https://x/i.png');
  }

  @override
  Future<ListaItensLoteResultado> adicionarPorFiltro(int id, ListaItensLote l) async {
    chamadas.add('por-filtro($id)');
    lote = l;
    return const ListaItensLoteResultado(adicionadas: 3, total: 8);
  }

  @override
  Future<ListaPersonalizada> buscarPorId(int id) async {
    chamadas.add('buscar($id)');
    return _lista();
  }

  @override
  Future<ListaPrevia> previa(int id, {int page = 1, int limit = 20}) async {
    chamadas.add('previa($id,$page)');
    return const ListaPrevia(
      items: [ListaPreviaItem(id: 1, nome: 'Blusa')],
      totalItems: 1,
      page: 1,
      totalPages: 1,
    );
  }

  @override
  Future<ListaPersonalizada> atualizar(int id, ListaPersonalizadaInput input) async {
    chamadas.add('atualizar($id)');
    return _lista();
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Arquivos extends ArquivoService {
  @override
  Future<ArquivoSelecionado?> selecionarArquivoComBytes({List<String>? extensoes}) async =>
      ArquivoSelecionado(nome: 'i.png', bytes: Uint8List(1), tamanho: 1);
}

ListaPersonalizadaBloc _bloc(_Repo r) => ListaPersonalizadaBloc(
      CriarListaPersonalizada(repository: r),
      AdicionarItensListaPersonalizada(repository: r),
      RemoverItensListaPersonalizada(repository: r),
      RecuperarListaPersonalizada(repository: r),
      BuscarLinkListaPersonalizada(repository: r),
      AtualizarTituloListaPersonalizada(repository: r),
      AtualizarListaPersonalizada(repository: r),
      EnviarIconeListaPersonalizada(repository: r),
      AdicionarItensPorFiltroListaPersonalizada(repository: r),
      RecuperarPreviaListaPersonalizada(repository: r),
      _Arquivos(),
    );

void main() {
  test('criar catálogo com ícone escolhido antes: cria e envia o ícone (sem buscar link)', () async {
    final repo = _Repo();
    final bloc = _bloc(repo);

    bloc.add(const ListaPersonalizadaIconeEscolheu());
    await bloc.stream.firstWhere((s) => s.iconeLocal != null);
    bloc.add(
      const ListaPersonalizadaCriou(
        input: ListaPersonalizadaInput(titulo: 'Novidades', tipo: ListaTipo.catalogo),
      ),
    );
    final s = await bloc.stream.firstWhere((x) => x.step == ListaPersonalizadaStep.criada);

    expect(repo.chamadas, ['criar', 'icone(5,i.png)']);
    expect(repo.criado!.tipo, ListaTipo.catalogo);
    expect(s.lista!.icone, 'https://x/i.png');
    await bloc.close();
  });

  test('adicionar em lote por categoria chama por-filtro e recarrega a lista', () async {
    final repo = _Repo();
    final bloc = _bloc(repo);
    bloc.add(const ListaPersonalizadaAbriu(id: 5));
    await bloc.stream.firstWhere((s) => s.lista != null);

    bloc.add(
      const ListaPersonalizadaItensPorFiltroAdicionou(
        lote: ListaItensLote(categoriaIds: [1], subCategoriaIds: [2]),
      ),
    );
    final s = await bloc.stream.firstWhere((x) => x.ultimoLote != null);

    expect(repo.chamadas, contains('por-filtro(5)'));
    expect(repo.chamadas.last, 'buscar(5)');
    expect(repo.lote!.categoriaIds, [1]);
    expect(repo.lote!.subCategoriaIds, [2]);
    expect(s.ultimoLote!.adicionadas, 3);
    await bloc.close();
  });

  test('prévia e edição usam a lista aberta', () async {
    final repo = _Repo();
    final bloc = _bloc(repo);
    bloc.add(const ListaPersonalizadaAbriu(id: 5));
    await bloc.stream.firstWhere((s) => s.lista != null);

    bloc.add(const ListaPersonalizadaPreviaSolicitou(page: 2));
    final s = await bloc.stream.firstWhere((x) => x.previa != null);
    bloc.add(const ListaPersonalizadaAtualizou(input: ListaPersonalizadaInput(tipo: ListaTipo.catalogo)));
    await bloc.stream.firstWhere((x) => repo.chamadas.contains('atualizar(5)') && !x.salvandoDados);

    expect(s.previa!.items.single.nome, 'Blusa');
    expect(repo.chamadas, containsAll(['previa(5,2)', 'atualizar(5)']));
    await bloc.close();
  });
}
