import 'package:comercial/domain/data/repositories/i_consignacoes_repository.dart';
import 'package:comercial/models.dart';

class AtualizarConsignacao {
  final IConsignacoesRepository repository;

  AtualizarConsignacao({required this.repository});

  Future<Consignacao> call({
    required int id,
    int? funcionarioId,
    String? observacao,
  }) {
    return repository.atualizar(
      id: id,
      funcionarioId: funcionarioId,
      observacao: observacao,
    );
  }
}
