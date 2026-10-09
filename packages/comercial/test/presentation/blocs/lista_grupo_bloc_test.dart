import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/lista_grupo.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/arquivos.dart';
import 'package:flutter_test/flutter_test.dart';

class _GruposRepo implements IListasGruposRepository {
  final chamadas = <String>[];

  @override
  Future<ListaGrupo> criar({required String nome, String? descricao}) async {
    chamadas.add('criar($nome)');
    return ListaGrupo(id: 8, nome: nome);
  }

  @override
  Future<void> definirListas(int id, List<int> listaIds) async =>
      chamadas.add('listas($id,$listaIds)');

  @override
  Future<ListaGrupo> enviarIcone(int id, Uint8List bytes, String fileName) async {
    chamadas.add('icone($id)');
    return ListaGrupo(id: id, nome: 'x', icone: 'u');
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _ListasRepo implements IListaPersonalizadaRepository {
  ListaTipo? tipoPedido;

  @override
  Future<PaginaListasPersonalizadas> listar({int page = 1, int limit = 20, ListaTipo? tipo}) async {
    tipoPedido = tipo;
    return const PaginaListasPersonalizadas(
      meta: MetaListasPersonalizadas(
        totalItems: 0,
        itemCount: 0,
        itemsPerPage: 100,
        totalPages: 1,
        currentPage: 1,
      ),
      items: [],
    );
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Arquivos extends ArquivoService {
  @override
  Future<ArquivoSelecionado?> selecionarArquivoComBytes({List<String>? extensoes}) async =>
      ArquivoSelecionado(nome: 'i.png', bytes: Uint8List(1), tamanho: 1);
}

void main() {
  test('salvar grupo novo: cria, grava as listas na ordem recebida e envia o ícone', () async {
    final repo = _GruposRepo();
    final listas = _ListasRepo();
    final bloc = ListaGrupoBloc(
      RecuperarListaGrupo(repository: repo),
      CriarListaGrupo(repository: repo),
      AtualizarListaGrupo(repository: repo),
      DefinirListasDoGrupo(repository: repo),
      EnviarIconeListaGrupo(repository: repo),
      ListarListasPersonalizadas(repository: listas),
      _Arquivos(),
    );

    bloc.add(const ListaGrupoAbriu());
    await bloc.stream.firstWhere((s) => s.step == ListaGrupoStep.pronto);
    bloc.add(const ListaGrupoIconeEscolheu());
    await bloc.stream.firstWhere((s) => s.iconeLocal != null);
    bloc.add(const ListaGrupoSalvou(nome: 'Verão', listaIds: [3, 1, 2]));
    final fim = await bloc.stream.firstWhere((s) => s.step == ListaGrupoStep.salvo);

    expect(listas.tipoPedido, ListaTipo.catalogo);
    expect(repo.chamadas, ['criar(Verão)', 'listas(8,[3, 1, 2])', 'icone(8)']);
    expect(fim.grupo!.icone, 'u');
    await bloc.close();
  });
}
