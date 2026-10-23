import 'package:empresas/domain/data/remote_data_sourcers/i_descontos_fidelidade_remote_data_source.dart';
import 'package:empresas/domain/data/repositories/i_descontos_fidelidade_repository.dart';
import 'package:empresas/domain/entities/desconto_fidelidade.dart';

class DescontosFidelidadeRepository implements IDescontosFidelidadeRepository {
  final IDescontosFidelidadeRemoteDataSource remoteDataSource;

  DescontosFidelidadeRepository({required this.remoteDataSource});

  @override
  Future<List<DescontoFidelidade>> listar(int empresaId) =>
      remoteDataSource.listar(empresaId);

  @override
  Future<void> salvar(int empresaId, DescontoFidelidade desconto) =>
      remoteDataSource.salvar(empresaId, desconto);

  @override
  Future<void> excluir(int empresaId, int id) =>
      remoteDataSource.excluir(empresaId, id);
}
