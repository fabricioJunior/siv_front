import 'package:produtos/models.dart';

abstract class IReferenciaMidiasRemoteDataSource {
  Future<List<ReferenciaMidia>> recuperarReferenciasMidias(int referenciaId);
  Future<ReferenciaMidia> criarReferenciaMidia({
    required String filePath,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    required TipoReferenciaMidia tipo,
    required String field,
  });
  Future<ReferenciaMidia> atualizarReferenciaMidia(
    ReferenciaMidia referenciaMidia,
  );
  Future<void> excluirReferenciaMidia(int id);
}
