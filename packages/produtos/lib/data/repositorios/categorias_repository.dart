import 'dart:typed_data';

import 'package:produtos/domain/data/remote/i_categorias_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_categorias_repository.dart';
import 'package:produtos/domain/models/categoria.dart';

class CategoriasRepository implements ICategoriasRepository {
  final ICategoriasRemoteDataSource categoriasRemoteDataSource;

  CategoriasRepository({required this.categoriasRemoteDataSource});

  @override
  Future<Categoria> atualizarCategoria(
    int id,
    String nome, {
    String? ncm,
    String? descricao,
    int? pesoGramas,
  }) {
    return categoriasRemoteDataSource.atualizarCategoria(
      id,
      nome,
      ncm: ncm,
      descricao: descricao,
      pesoGramas: pesoGramas,
    );
  }

  @override
  Future<Categoria> criarCategoria(
    String nome, {
    String? ncm,
    String? descricao,
    int? pesoGramas,
  }) {
    return categoriasRemoteDataSource.createCategoria(
      nome,
      ncm: ncm,
      descricao: descricao,
      pesoGramas: pesoGramas,
    );
  }

  @override
  Future<Categoria> enviarIconeCategoria(int id, Uint8List bytes, String fileName) {
    return categoriasRemoteDataSource.enviarIcone(id, bytes, fileName);
  }

  @override
  Future<void> desativarCategoria(int id) {
    return categoriasRemoteDataSource.desativarCategoria(id);
  }

  @override
  Future<Categoria?> obterCategoria(int id) {
    return categoriasRemoteDataSource.fetchCategoria(id);
  }

  @override
  Future<List<Categoria>> obterCategorias({String? nome, bool? inativa}) {
    return categoriasRemoteDataSource.fetchCategorias(
      nome: nome,
      inativa: inativa,
    );
  }
}
