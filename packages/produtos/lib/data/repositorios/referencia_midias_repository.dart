import 'package:produtos/domain/data/remote/i_referencia_midias_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:produtos/domain/models/referencia_midia.dart';

class ReferenciaMidiasRepository implements IReferenciaMidiasRepository {
  final IReferenciaMidiasRemoteDataSource referenciaMidiasRemoteDataSource;

  ReferenciaMidiasRepository({required this.referenciaMidiasRemoteDataSource});
  @override
  Future<ReferenciaMidia> atualizarReferenciaMidia(
    ReferenciaMidia referenciaMidia,
  ) {
    return referenciaMidiasRemoteDataSource.atualizarReferenciaMidia(
      referenciaMidia,
    );
  }

  @override
  Future<ReferenciaMidia> criarReferenciaMidia({
    required String filePath,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    required TipoReferenciaMidia tipo,
    required String field,
    required String? descricao,
  }) {
    return referenciaMidiasRemoteDataSource.criarReferenciaMidia(
      filePath: filePath,
      referenciaId: referenciaId,
      ePrincipal: ePrincipal,
      ePublica: ePublica,
      tipo: tipo,
      field: field,
      descricao: descricao,
    );
  }

  @override
  Future<void> excluirReferenciaMidia({
    required int referenciaId,
    required int id,
  }) {
    return referenciaMidiasRemoteDataSource.excluirReferenciaMidia(
      referenciaId: referenciaId,
      id: id,
    );
  }

  @override
  Future<List<ReferenciaMidia>> recuperarReferenciasMidias(int referenciaId) {
    return referenciaMidiasRemoteDataSource.recuperarReferenciasMidias(
      referenciaId,
    );
  }
}
