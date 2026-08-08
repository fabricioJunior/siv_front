import 'package:financeiro/domain/data/repositories/i_contagem_do_caixa_repository.dart';
import 'package:financeiro/domain/models/faturamento_do_caixa.dart';

class RecuperarFaturamentoDoCaixa {
  final IContagemDoCaixaRepository _repository;

  RecuperarFaturamentoDoCaixa({required IContagemDoCaixaRepository repository})
      : _repository = repository;

  Future<FaturamentoDoCaixa> call({required int caixaId}) {
    return _repository.recuperarFaturamentoDoCaixa(caixaId: caixaId);
  }
}
