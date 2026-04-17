import 'package:produtos/models.dart';

abstract class IReferenciaMidiasRepository {
  Future<List<ReferenciaMidia>> recuperarReferenciasMidias(int referenciaId);

  Future<ReferenciaMidia> criarReferenciaMidia({
    required String filePath,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    required TipoReferenciaMidia tipo,
    required String field,
    required String? descricao,
    required String? cor,
    required String? tamanho,
    void Function(int sent, int total)? onSendProgress,
  });

  Future<ReferenciaMidia> atualizarReferenciaMidia(
    ReferenciaMidia referenciaMidia,
  );

  Future<void> excluirReferenciaMidia({
    required int referenciaId,
    required int id,
  });
}
