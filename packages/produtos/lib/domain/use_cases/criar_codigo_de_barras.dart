import 'package:produtos/repositorios.dart';

class CriarCodigoDeBarras {
  final ICodigoDeBarrasRepository _codigoDeBarrasRepository;

  CriarCodigoDeBarras({
    required ICodigoDeBarrasRepository codigoDeBarrasRepository,
  }) : _codigoDeBarrasRepository = codigoDeBarrasRepository;

  Future<void> call({required int produtoId, required String codigoDeBarras}) {
    return _codigoDeBarrasRepository.criarCodigoDeBarras(
      produtoId: produtoId,
      codigoDeBarras: codigoDeBarras,
    );
  }
}
