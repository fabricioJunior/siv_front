import 'package:produtos/models.dart';

import '../data/repositorios/i_tamanhos_repository.dart';

class RecuperarTamanhos {
  final ITamanhosRepository _tamanhosRepository;

  RecuperarTamanhos({required ITamanhosRepository tamanhosRepository})
    : _tamanhosRepository = tamanhosRepository;

  Future<List<Tamanho>> call({String? nome, bool? inativo}) {
    return _tamanhosRepository.obterTamanhos(nome: nome, inativo: inativo);
  }
}
