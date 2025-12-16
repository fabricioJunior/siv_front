import 'package:produtos/domain/models/tamanho.dart';
import 'package:produtos/repositorios.dart';

class RecuperarTamanho {
  final ITamanhosRepository _tamanhosRepository;

  RecuperarTamanho({required ITamanhosRepository tamanhosRepository})
    : _tamanhosRepository = tamanhosRepository;

  Future<Tamanho?> call(int id) {
    return _tamanhosRepository.obterTamanho(id);
  }
}
