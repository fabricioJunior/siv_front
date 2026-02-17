import 'package:produtos/domain/models/cor.dart';
import 'package:produtos/repositorios.dart';

class RecuperarCor {
  final ICoresRepository _coresRepository;

  RecuperarCor({required ICoresRepository coresRepository})
    : _coresRepository = coresRepository;

  Future<Cor?> call(int id) {
    return _coresRepository.obterCor(id);
  }
}
