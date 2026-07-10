import 'package:pessoas/domain/data/data_sourcers/remote/i_pessoa_extrato_remote_data_source.dart';
import 'package:pessoas/domain/data/repositories/i_pessoa_extrato_repository.dart';
import 'package:pessoas/domain/models/pessoa_extrato_movimentacao.dart';

class PessoaExtratoRepository implements IPessoaExtratoRepository {
  final IPessoaExtratoRemoteDataSource remoteDataSource;

  PessoaExtratoRepository({required this.remoteDataSource});

  @override
  Future<List<PessoaExtratoMovimentacao>> buscarExtrato({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return remoteDataSource.buscarExtrato(
      pessoaId: pessoaId,
      empresaIds: empresaIds,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }
}
