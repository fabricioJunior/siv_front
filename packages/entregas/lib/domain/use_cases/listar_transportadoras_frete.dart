import 'package:entregas/domain/data/repositories/i_frete_repository.dart';

class ListarTransportadorasFrete {
  final IFreteRepository _repository;

  ListarTransportadorasFrete({required IFreteRepository repository})
      : _repository = repository;

  Future<List<String>> call() => _repository.getTransportadoras();
}
