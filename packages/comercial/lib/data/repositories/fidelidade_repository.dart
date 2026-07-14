import 'package:comercial/domain/data/remote/i_fidelidade_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_fidelidade_repository.dart';

class FidelidadeRepository implements IFidelidadeRepository {
  final IFidelidadeRemoteDataSource remoteDataSource;

  FidelidadeRepository({required this.remoteDataSource});

  @override
  Future<bool> verificarElegibilidade({required int pessoaId}) {
    return remoteDataSource.verificarElegibilidade(pessoaId: pessoaId);
  }
}
