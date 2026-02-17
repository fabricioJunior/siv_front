import 'package:produtos/repositorios.dart';

class DesativarCor {
  final ICoresRepository _coresRepository;

  DesativarCor({required ICoresRepository coresRepository})
    : _coresRepository = coresRepository;

  Future<void> call(int id) {
    return _coresRepository.desativarCor(id);
  }
}
