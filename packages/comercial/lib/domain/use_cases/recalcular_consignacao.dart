import 'package:comercial/domain/data/repositories/i_consignacoes_repository.dart';

class RecalcularConsignacao {
  final IConsignacoesRepository repository;

  RecalcularConsignacao({required this.repository});

  Future<void> call(int id) {
    return repository.recalcular(id);
  }
}
