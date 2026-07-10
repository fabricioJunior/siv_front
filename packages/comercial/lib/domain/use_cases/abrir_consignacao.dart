import 'package:comercial/domain/data/repositories/i_consignacoes_repository.dart';
import 'package:comercial/models.dart';

class AbrirConsignacao {
  final IConsignacoesRepository repository;

  AbrirConsignacao({required this.repository});

  Future<Consignacao> call({
    required int pessoaId,
    required int funcionarioId,
    required int tabelaPrecoId,
    required int caixaAbertura,
    String? observacao,
  }) {
    return repository.abrir(
      pessoaId: pessoaId,
      funcionarioId: funcionarioId,
      tabelaPrecoId: tabelaPrecoId,
      caixaAbertura: caixaAbertura,
      observacao: observacao,
    );
  }
}
