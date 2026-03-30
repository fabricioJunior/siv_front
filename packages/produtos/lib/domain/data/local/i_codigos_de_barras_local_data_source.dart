import 'package:produtos/domain/models/codigo.dart';

abstract class ICodigosDeBarrasLocalDataSource {
  Future<void> salvarCodigosDeBarras(List<Codigo> codigos);

  Future<Codigo?> recuperarCodigo(String codigo);
}
