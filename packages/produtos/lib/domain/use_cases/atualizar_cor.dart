import 'package:produtos/repositorios.dart';

class AtualizarCor {
  final ICoresRepository _coresRepository;

  AtualizarCor({required ICoresRepository coresRepository})
    : _coresRepository = coresRepository;

  Future<dynamic> call(int id, String nome) async {
    return _coresRepository.atualizarCor(id, nome);
  }
}
