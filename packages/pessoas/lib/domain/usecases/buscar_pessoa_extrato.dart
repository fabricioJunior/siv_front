import 'package:pessoas/domain/data/repositories/i_pessoa_extrato_repository.dart';
import 'package:pessoas/domain/models/pessoa_extrato_movimentacao.dart';

class BuscarPessoaExtrato {
  final IPessoaExtratoRepository repository;

  BuscarPessoaExtrato({required this.repository});

  Future<List<PessoaExtratoMovimentacao>> call({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return repository.buscarExtrato(
      pessoaId: pessoaId,
      empresaIds: empresaIds,
      dataInicio: dataInicio,
      dataFim: dataFim,
    );
  }
}
