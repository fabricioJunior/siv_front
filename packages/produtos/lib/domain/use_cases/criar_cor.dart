import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class CriarCor {
  final ICoresRepository _coresRepository;

  CriarCor({required ICoresRepository coresRepository})
    : _coresRepository = coresRepository;

  Future<Cor> call(String nome) async {
    return _coresRepository.criarCor(nome);
  }
}
