import 'package:promocoes/domain/data/remote/i_cupons_remote_data_source.dart';
import 'package:promocoes/domain/data/repositories/i_cupons_repository.dart';
import 'package:promocoes/domain/models/cupom.dart';

class CuponsRepository implements ICuponsRepository {
  final ICuponsRemoteDataSource remoteDataSource;

  CuponsRepository({required this.remoteDataSource});

  @override
  Future<Cupom> atualizarCupom(Cupom cupom) {
    return remoteDataSource.atualizarCupom(cupom);
  }

  @override
  Future<Cupom> criarCupom(Cupom cupom) {
    return remoteDataSource.criarCupom(cupom);
  }

  @override
  Future<Cupom?> recuperarCupom(int id) {
    return remoteDataSource.recuperarCupom(id);
  }

  @override
  Future<List<Cupom>> recuperarCupons({
    String? codigo,
    bool? ativa,
    bool? vigente,
  }) {
    return remoteDataSource.recuperarCupons(
      codigo: codigo,
      ativa: ativa,
      vigente: vigente,
    );
  }
}
