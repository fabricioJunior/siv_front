import 'package:produtos/repositorios.dart';

class SalvarCustoReferencia {
  final IReferenciasRepository _referenciasRepository;

  SalvarCustoReferencia({required IReferenciasRepository referenciasRepository})
    : _referenciasRepository = referenciasRepository;

  Future<void> call({required int id, double? custo}) {
    return _referenciasRepository.salvarCusto(id: id, custo: custo);
  }
}
