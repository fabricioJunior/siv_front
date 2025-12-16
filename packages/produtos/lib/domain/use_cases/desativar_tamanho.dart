import 'package:produtos/repositorios.dart';

class DesativarTamanho {
  final ITamanhosRepository _tamanhosRepository;

  DesativarTamanho({required ITamanhosRepository tamanhosRepository})
    : _tamanhosRepository = tamanhosRepository;

  Future<void> call(int id) {
    return _tamanhosRepository.desativarTamanho(id);
  }
}
