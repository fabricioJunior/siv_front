import 'package:produtos/repositorios.dart';

class AtualizarCategoria {
  final ICategoriasRepository _categoriasRepository;

  AtualizarCategoria({required ICategoriasRepository categoriasRepository})
    : _categoriasRepository = categoriasRepository;

  Future<dynamic> call(int id, String nome) async {
    return _categoriasRepository.atualizarCategoria(id, nome);
  }
}
