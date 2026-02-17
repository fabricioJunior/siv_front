import 'package:produtos/domain/data/remote/i_referencias_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_referencias_repository.dart';
import 'package:produtos/models.dart';

class ReferenciasRepository implements IReferenciasRepository {
  final IReferenciasRemoteDataSource referenciasRemoteDataSource;

  ReferenciasRepository({required this.referenciasRemoteDataSource});

  @override
  Future<List<Referencia>> obterReferencias({String? nome, bool? inativo}) {
    return referenciasRemoteDataSource.fetchReferencias(
      nome: nome,
      inativo: inativo,
    );
  }
}
