import 'package:produtos/repositorios.dart';

class DeletarCodigoDeBarras {
  final ICodigosRepository _codigoDeBarrasRepository;

  DeletarCodigoDeBarras({required ICodigosRepository codigoDeBarrasRepository})
    : _codigoDeBarrasRepository = codigoDeBarrasRepository;

  Future<void> call({required int produtoId, required String codigoDeBarras}) {
    return _codigoDeBarrasRepository.deletarCodigo(
      produtoId: produtoId,
      codigo: codigoDeBarras,
    );
  }
}
