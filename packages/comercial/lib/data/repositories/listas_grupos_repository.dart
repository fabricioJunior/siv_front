import 'dart:typed_data';

import 'package:comercial/domain/data/remote/i_listas_grupos_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_listas_grupos_repository.dart';
import 'package:comercial/domain/models/lista_grupo.dart';

class ListasGruposRepository implements IListasGruposRepository {
  final IListasGruposRemoteDataSource remoteDataSource;

  ListasGruposRepository({required this.remoteDataSource});

  @override
  Future<PaginaListasGrupos> listar({int page = 1, int limit = 20}) =>
      remoteDataSource.listar(page: page, limit: limit);

  @override
  Future<ListaGrupo> buscarPorId(int id) => remoteDataSource.buscarPorId(id);

  @override
  Future<ListaGrupo> criar({required String nome, String? descricao, bool? ativo}) =>
      remoteDataSource.criar(nome: nome, descricao: descricao, ativo: ativo);

  @override
  Future<ListaGrupo> atualizar(int id, {required String nome, String? descricao, bool? ativo}) =>
      remoteDataSource.atualizar(id, nome: nome, descricao: descricao, ativo: ativo);

  @override
  Future<void> excluir(int id) => remoteDataSource.excluir(id);

  @override
  Future<void> definirListas(int id, List<int> listaIds) =>
      remoteDataSource.definirListas(id, listaIds);

  @override
  Future<ListaGrupo> enviarIcone(int id, Uint8List bytes, String fileName) =>
      remoteDataSource.enviarIcone(id, bytes, fileName);
}
