import 'package:financeiro/domain/data/repositories/i_contagem_do_caixa_repository.dart';
import 'package:financeiro/domain/models/contagem_do_caixa.dart';

class RecuperarContagemDoCaixa {
  final IContagemDoCaixaRepository _repository;

  RecuperarContagemDoCaixa({required IContagemDoCaixaRepository repository})
      : _repository = repository;

  Future<ContagemDoCaixa?> call({required int caixaId}) {
    return _repository.recuperarContagemDoCaixa(caixaId: caixaId);
  }
}
