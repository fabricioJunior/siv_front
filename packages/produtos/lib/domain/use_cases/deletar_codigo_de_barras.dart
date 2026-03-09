import 'package:produtos/repositorios.dart';

class DeletarCodigoDeBarras {
  final ICodigoDeBarrasRepository _codigoDeBarrasRepository;

  DeletarCodigoDeBarras({
    required ICodigoDeBarrasRepository codigoDeBarrasRepository,
  }) : _codigoDeBarrasRepository = codigoDeBarrasRepository;

  Future<void> call({required int produtoId, required String codigoDeBarras}) {
    return _codigoDeBarrasRepository.deletarCodigoDeBarras(
      produtoId: produtoId,
      codigoDeBarras: codigoDeBarras,
    );
  }
}
