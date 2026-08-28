import 'package:produtos/models.dart';

import '../data/repositorios/i_estampas_repository.dart';

class RecuperarEstampas {
  final IEstampasRepository _estampasRepository;

  RecuperarEstampas({required IEstampasRepository estampasRepository})
    : _estampasRepository = estampasRepository;

  Future<List<Estampa>> call({String? nome, bool? inativo}) {
    return _estampasRepository.obterEstampas(nome: nome, inativo: inativo);
  }
}
