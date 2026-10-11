import 'package:entregas/domain/data/repositories/i_frete_repository.dart';

class SalvarTransportadorasFrete {
  final IFreteRepository _repository;

  SalvarTransportadorasFrete({required IFreteRepository repository})
      : _repository = repository;

  Future<void> call({
    required bool ativo,
    required List<String> transportadoras,
  }) =>
      _repository.salvarTransportadoras(
        ativo: ativo,
        transportadoras: transportadoras,
      );
}
