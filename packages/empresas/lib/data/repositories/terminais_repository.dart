import 'package:empresas/domain/data/remote_data_sourcers/i_terminais_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_terminais_repository.dart';
import 'package:empresas/domain/entities/terminal.dart';

class TerminaisRepository implements ITerminaisRepository {
  final ITerminaisRemoteDataSource remoteDataSource;

  TerminaisRepository({required this.remoteDataSource});

  @override
  Future<Terminal> atualizarTerminal({
    required int empresaId,
    required int id,
    required String nome,
  }) {
    return remoteDataSource.atualizarTerminal(
      empresaId: empresaId,
      id: id,
      nome: nome,
    );
  }

  @override
  Future<Terminal> criarTerminal({
    required int empresaId,
    required String nome,
  }) {
    return remoteDataSource.criarTerminal(empresaId: empresaId, nome: nome);
  }

  @override
  Future<void> desativarTerminal({required int empresaId, required int id}) {
    return remoteDataSource.desativarTerminal(empresaId: empresaId, id: id);
  }

  @override
  Future<Terminal?> recuperarTerminal({
    required int empresaId,
    required int id,
  }) {
    return remoteDataSource.recuperarTerminal(empresaId: empresaId, id: id);
  }

  @override
  Future<List<Terminal>> recuperarTerminais({
    required int empresaId,
    String? nome,
    bool? inativo,
  }) {
    return remoteDataSource.recuperarTerminais(
      empresaId: empresaId,
      nome: nome,
      inativo: inativo,
    );
  }
}
