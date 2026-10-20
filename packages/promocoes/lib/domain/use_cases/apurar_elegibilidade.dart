import 'package:promocoes/domain/data/repositories/i_elegibilidade_repository.dart';
import 'package:promocoes/domain/models/elegibilidade.dart';

class ApurarElegibilidade {
  final IElegibilidadeRepository _repository;

  ApurarElegibilidade({required IElegibilidadeRepository repository})
      : _repository = repository;

  Future<ResultadoElegibilidade> call({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    List<String> codigosCupom = const [],
  }) {
    return _repository.apurar(
      clienteId: clienteId,
      itens: itens,
      codigosCupom: codigosCupom,
    );
  }
}
