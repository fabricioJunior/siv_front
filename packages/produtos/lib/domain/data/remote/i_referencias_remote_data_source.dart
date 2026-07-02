import 'package:produtos/models.dart';

abstract class IReferenciasRemoteDataSource {
  Future<Referencia> fetchReferencia({required int id});

  Future<Referencia> createReferencia({
    required int id,
    required String nome,
    required int categoriaId,
    int? subCategoriaId,
    String? idExterno,
    String? unidadeMedida,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
    String? ncm,
  });

  Future<Referencia> atualizarReferencia({
    required int id,
    required String nome,
    required int categoriaId,
    int? subCategoriaId,
    String? idExterno,
    String? unidadeMedida,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
    String? ncm,
  });

  Future<List<Referencia>> fetchReferencias({String? nome, bool? inativo});
}
