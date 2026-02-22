import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class AtualizarReferencia {
  final IReferenciasRepository _referenciasRepository;

  AtualizarReferencia({required IReferenciasRepository referenciasRepository})
    : _referenciasRepository = referenciasRepository;

  Future<Referencia> call({
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
  }) async {
    return _referenciasRepository.atualizarReferencia(
      id: id,
      nome: nome,
      categoriaId: categoriaId,
      subCategoriaId: subCategoriaId,
      idExterno: idExterno,
      unidadeMedida: unidadeMedida,
      marcaId: marcaId,
      descricao: descricao,
      composicao: composicao,
      cuidados: cuidados,
    );
  }
}
