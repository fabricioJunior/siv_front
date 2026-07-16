import 'package:financeiro/domain/data/repositories/i_recibo_fechamento_caixa_repository.dart';
import 'package:financeiro/domain/models/recibo_fechamento_caixa.dart';

class RecuperarReciboFechamentoCaixa {
  final IReciboFechamentoCaixaRepository _repository;

  RecuperarReciboFechamentoCaixa({
    required IReciboFechamentoCaixaRepository repository,
  }) : _repository = repository;

  Future<ReciboFechamentoCaixa> call({required int caixaId}) {
    return _repository.recuperarReciboFechamento(caixaId: caixaId);
  }
}
