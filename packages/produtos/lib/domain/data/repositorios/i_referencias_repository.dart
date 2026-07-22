import 'package:produtos/models.dart';

abstract class IReferenciasRepository {
  Future<Referencia> obterReferencia({required int id});

  Future<int> obterProximoId();

  Future<Referencia> criarReferencia({
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

  Future<List<Referencia>> obterReferencias({String? nome, bool? inativo});
}
