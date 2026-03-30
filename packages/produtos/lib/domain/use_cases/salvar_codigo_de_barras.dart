import 'package:produtos/repositorios.dart';

class SalvarCodigoDeBarras {
  final ICodigosRepository _codigoDeBarrasRepository;

  SalvarCodigoDeBarras({required ICodigosRepository codigoDeBarrasRepository})
    : _codigoDeBarrasRepository = codigoDeBarrasRepository;

  Future<void> call({required int produtoId, required String codigoDeBarras}) {
    return _codigoDeBarrasRepository.criarCodigo(
      produtoId: produtoId,
      codigo: codigoDeBarras,
    );
  }
}
