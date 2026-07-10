import 'package:comercial/domain/data/repositories/i_consignacoes_repository.dart';
import 'package:comercial/models.dart';

class RecuperarConsignacao {
  final IConsignacoesRepository repository;

  RecuperarConsignacao({required this.repository});

  Future<Consignacao> call(int id, {bool incluirItens = false}) {
    return repository.buscarPorId(id, incluirItens: incluirItens);
  }
}
