import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class GetCreditosTransferiveis {
  final ICreditoDevolucaoRepository _repository;

  GetCreditosTransferiveis({required ICreditoDevolucaoRepository repository})
      : _repository = repository;

  Future<List<CreditoTransferivel>> call({required int pessoaId}) =>
      _repository.buscarTransferiveis(pessoaId: pessoaId);
}
