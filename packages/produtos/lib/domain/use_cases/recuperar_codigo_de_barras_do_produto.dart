import 'package:produtos/repositorios.dart';

class RecuperarCodigoDeBarrasDoProduto {
  final ICodigosRepository _codigosRepository;

  RecuperarCodigoDeBarrasDoProduto({
    required ICodigosRepository codigosRepository,
  }) : _codigosRepository = codigosRepository;

  Future<String?> call({required int produtoId}) {
    return _codigosRepository.recuperarCodigoPorProdutoId(produtoId);
  }
}