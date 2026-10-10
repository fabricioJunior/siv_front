import 'dart:typed_data';

import 'package:comercial/domain/data/remote/i_lista_personalizada_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_lista_personalizada_repository.dart';
import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';

class ListaPersonalizadaRepository implements IListaPersonalizadaRepository {
  final IListaPersonalizadaRemoteDataSource remoteDataSource;

  ListaPersonalizadaRepository({required this.remoteDataSource});

  @override
  Future<ListaPersonalizada> criar(ListaPersonalizadaInput input) =>
      remoteDataSource.criar(input);

  @override
  Future<ListaPersonalizada> atualizar(int id, ListaPersonalizadaInput input) =>
      remoteDataSource.atualizar(id, input);

  @override
  Future<ListaPersonalizada> atualizarTitulo(int id, String? titulo) =>
      remoteDataSource.atualizarTitulo(id, titulo);

  @override
  Future<ListaPersonalizada> adicionarItens(int id, List<int> referenciaIds) =>
      remoteDataSource.adicionarItens(id, referenciaIds);

  @override
  Future<ListaItensLoteResultado> adicionarPorFiltro(int id, ListaItensLote lote) =>
      remoteDataSource.adicionarPorFiltro(id, lote);

  @override
  Future<ListaPersonalizada> removerItens(int id, List<int> referenciaIds) =>
      remoteDataSource.removerItens(id, referenciaIds);

  @override
  Future<ListaPersonalizada> buscarPorId(int id) => remoteDataSource.buscarPorId(id);

  @override
  Future<String> buscarLink(int id) => remoteDataSource.buscarLink(id);

  @override
  Future<ListaPersonalizada> enviarIcone(int id, Uint8List bytes, String fileName) =>
      remoteDataSource.enviarIcone(id, bytes, fileName);

  @override
  Future<ListaPrevia> previa(int id, {int page = 1, int limit = 20}) =>
      remoteDataSource.previa(id, page: page, limit: limit);

  @override
  Future<PaginaListasPersonalizadas> listar({
    int page = 1,
    int limit = 20,
    ListaTipo? tipo,
  }) =>
      remoteDataSource.listar(page: page, limit: limit, tipo: tipo);
}
