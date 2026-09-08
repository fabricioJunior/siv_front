import 'dart:typed_data';

import 'package:produtos/models.dart';

abstract class ICategoriasRepository {
  Future<Categoria> criarCategoria(
    String nome, {
    String? ncm,
    String? descricao,
    int? pesoGramas,
  });
  Future<List<Categoria>> obterCategorias({String? nome, bool? inativa});
  Future<Categoria?> obterCategoria(int id);
  Future<void> desativarCategoria(int id);

  Future<Categoria> atualizarCategoria(
    int id,
    String nome, {
    String? ncm,
    String? descricao,
    int? pesoGramas,
  });

  Future<Categoria> enviarIconeCategoria(int id, Uint8List bytes, String fileName);
}
