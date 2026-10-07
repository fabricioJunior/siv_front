import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class TransferirCreditosDevolucao {
  final ICreditoDevolucaoRepository _repository;

  TransferirCreditosDevolucao({required ICreditoDevolucaoRepository repository})
      : _repository = repository;

  Future<ResultadoTransferenciaCredito> call({
    required int pessoaId,
    required List<int> romaneioIds,
  }) =>
      _repository.transferir(pessoaId: pessoaId, romaneioIds: romaneioIds);
}
