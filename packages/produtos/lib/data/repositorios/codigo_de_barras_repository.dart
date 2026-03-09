import 'package:produtos/domain/data/remote/i_codigo_de_barras_remotedatasource.dart';
import 'package:produtos/domain/data/repositorios/i_codigo_de_barras_repository.dart';

class CodigoDeBarrasRepository implements ICodigoDeBarrasRepository {
  final ICodigoDeBarrasRemoteDatasource _codigoDeBarrasRemoteDatasource;

  CodigoDeBarrasRepository({
    required ICodigoDeBarrasRemoteDatasource codigoDeBarrasRemoteDatasource,
  }) : _codigoDeBarrasRemoteDatasource = codigoDeBarrasRemoteDatasource;

  @override
  Future<void> criarCodigoDeBarras({
    required int produtoId,
    required String codigoDeBarras,
  }) {
    return _codigoDeBarrasRemoteDatasource.salvarCodigoDeBarras(
      produtoId: produtoId,
      codigoDeBarras: codigoDeBarras,
    );
  }

  @override
  Future<void> deletarCodigoDeBarras({
    required int produtoId,
    required String codigoDeBarras,
  }) {
    return _codigoDeBarrasRemoteDatasource.deletarCodigoDeBarras(
      produtoId: produtoId,
      codigoDeBarras: codigoDeBarras,
    );
  }
}
