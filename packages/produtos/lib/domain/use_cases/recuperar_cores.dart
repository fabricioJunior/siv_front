import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class RecuperarCores {
  final ICoresRepository _coresRepository;

  RecuperarCores({required ICoresRepository coresRepository})
    : _coresRepository = coresRepository;

  Future<List<Cor>> call({String? nome, bool? inativo}) async {
    final cores = await _coresRepository.obterCores(
      nome: nome,
      inativo: inativo,
    );
    cores.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return cores;
  }
}
