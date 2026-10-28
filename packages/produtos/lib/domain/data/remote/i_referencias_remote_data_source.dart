import 'package:produtos/models.dart';

abstract class IReferenciasRemoteDataSource {
  Future<Referencia> fetchReferencia({required int id});

  Future<int> fetchProximoId();

  Future<double?> fetchCusto({required int id});

  Future<void> updateCusto({required int id, double? custo});

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
    int? pesoGramas,
    EsperaReferencia? espera,
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
    int? pesoGramas,
    EsperaReferencia? espera,
  });

  Future<List<Referencia>> fetchReferencias({String? nome, bool? inativo});
}
