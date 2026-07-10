import 'package:comercial/domain/data/repositories/i_consignacoes_repository.dart';

class FecharConsignacao {
  final IConsignacoesRepository repository;

  FecharConsignacao({required this.repository});

  Future<void> call(int id) {
    return repository.fechar(id);
  }
}
