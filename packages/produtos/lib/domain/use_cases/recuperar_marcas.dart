import 'package:produtos/models.dart';
import 'package:produtos/repositorios.dart';

class RecuperarMarcas {
  final IMarcasRepository _marcasRepository;

  RecuperarMarcas({required IMarcasRepository marcasRepository})
    : _marcasRepository = marcasRepository;

  Future<List<Marca>> call({String? nome, bool? inativa}) async {
    final marcas = await _marcasRepository.obterMarcas(
      nome: nome,
      inativa: inativa,
    );
    marcas.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return marcas;
  }
}
