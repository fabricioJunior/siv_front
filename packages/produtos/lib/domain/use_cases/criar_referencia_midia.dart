import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:produtos/models.dart';

class CriarReferenciaMidia {
  final IReferenciaMidiasRepository referenciaMidiasRepository;

  CriarReferenciaMidia({required this.referenciaMidiasRepository});

  Future<void> call({
    required String filePath,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    required TipoReferenciaMidia tipo,
    required String field,
    required String? descricao,
    required String? cor,
    required String? tamanho,
  }) {
    return referenciaMidiasRepository.criarReferenciaMidia(
      filePath: filePath,
      referenciaId: referenciaId,
      ePrincipal: ePrincipal,
      ePublica: ePublica,
      tipo: tipo,
      field: field,
      descricao: descricao,
      cor: cor,
      tamanho: tamanho,
    );
  }
}
