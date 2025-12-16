import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class CriarTamanho {
  final ITamanhosRepository _tamanhosRepository;

  CriarTamanho({required ITamanhosRepository tamanhosRepository})
    : _tamanhosRepository = tamanhosRepository;

  Future<Tamanho> call(String nome) async {
    return _tamanhosRepository.criarTamanho(nome);
  }
}
