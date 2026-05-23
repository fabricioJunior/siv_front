import 'package:financeiro/domain/data/remote/i_sangrias_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_sangrias_repository.dart';
import 'package:financeiro/domain/models/sangria.dart';

class SangriasRepository implements ISangriasRepository {
  final ISangriasRemoteDataSource remoteDataSource;

  SangriasRepository({required this.remoteDataSource});

  @override
  Future<void> cancelarSangria({
    required int caixaId,
    required int sangriaId,
    required String motivo,
  }) {
    return remoteDataSource.cancelarSangria(
      sangriaId: sangriaId,
      caixaId: caixaId,
      motivo: motivo,
    );
  }

  @override
  Future<Sangria> criarSangria({
    required int caixaId,
    required double valor,
    required String descricao,
    required String origem,
  }) {
    return remoteDataSource.criarSangria(
      caixaId: caixaId,
      valor: valor,
      descricao: descricao,
      origem: origem,
    );
  }

  @override
  Future<Sangria> recuperarSangria({
    required int caixaId,
    required int sangriaId,
  }) {
    return remoteDataSource.recuperarSangria(
      sangriaId: sangriaId,
      caixaId: caixaId,
    );
  }

  @override
  Future<List<Sangria>> recuperarSangrias({required int caixaId}) {
    return remoteDataSource.recuperarSangrias(caixaId: caixaId);
  }
}
