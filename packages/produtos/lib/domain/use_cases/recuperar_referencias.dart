import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class RecuperarReferencias {
  final IReferenciasRepository _referenciasRepository;

  RecuperarReferencias({required IReferenciasRepository referenciasRepository})
    : _referenciasRepository = referenciasRepository;

  Future<List<Referencia>> call({String? nome, bool? inativo}) async {
    final referencias = await _referenciasRepository.obterReferencias(
      nome: nome,
      inativo: inativo,
    );
    referencias.sort(
      (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );
    return referencias;
  }
}
