import 'package:produtos/domain/data/remote/i_codigo_de_barras_remotedatasource.dart';
import 'package:produtos/domain/data/repositorios/i_codigo_de_barras_repository.dart';

class CodigoDeBarrasRepository implements ICodigosRepository {
  final ICodigoDeBarrasRemoteDatasource _codigoDeBarrasRemoteDatasource;

  CodigoDeBarrasRepository({
    required ICodigoDeBarrasRemoteDatasource codigoDeBarrasRemoteDatasource,
  }) : _codigoDeBarrasRemoteDatasource = codigoDeBarrasRemoteDatasource;

  @override
  Future<void> criarCodigo({required int produtoId, required String codigo}) {
    return _codigoDeBarrasRemoteDatasource.salvarCodigo(
      produtoId: produtoId,
      codigoDeBarras: codigo,
    );
  }

  @override
  Future<void> deletarCodigo({required int produtoId, required String codigo}) {
    return _codigoDeBarrasRemoteDatasource.deletarCodigo(
      produtoId: produtoId,
      codigoDeBarras: codigo,
    );
  }
}
