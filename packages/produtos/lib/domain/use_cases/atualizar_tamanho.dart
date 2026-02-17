import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class AtualizarTamanho {
  final ITamanhosRepository _tamanhosRepository;

  AtualizarTamanho({required ITamanhosRepository tamanhosRepository})
    : _tamanhosRepository = tamanhosRepository;

  Future<Tamanho> call(int id, String nome) async {
    return await _tamanhosRepository.atualizarTamanho(id, nome);
  }
}
