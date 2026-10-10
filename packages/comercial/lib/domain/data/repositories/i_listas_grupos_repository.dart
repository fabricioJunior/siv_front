import 'dart:typed_data';

import 'package:comercial/domain/models/lista_grupo.dart';

abstract class IListasGruposRepository {
  Future<PaginaListasGrupos> listar({int page = 1, int limit = 20});

  Future<ListaGrupo> buscarPorId(int id);

  Future<ListaGrupo> criar({required String nome, String? descricao, bool? ativo});

  Future<ListaGrupo> atualizar(int id, {required String nome, String? descricao, bool? ativo});

  Future<void> excluir(int id);

  /// Substitui as listas do grupo; a posição em [listaIds] vira a ordem.
  Future<void> definirListas(int id, List<int> listaIds);

  Future<ListaGrupo> enviarIcone(int id, Uint8List bytes, String fileName);
}
