import 'package:comercial/domain/data/repositories/i_consignacoes_repository.dart';

class CancelarConsignacao {
  final IConsignacoesRepository repository;

  CancelarConsignacao({required this.repository});

  Future<void> call({required int id, required String motivoCancelamento}) {
    return repository.cancelar(id: id, motivoCancelamento: motivoCancelamento);
  }
}
