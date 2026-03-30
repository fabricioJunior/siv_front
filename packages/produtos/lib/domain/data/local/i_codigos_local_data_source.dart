import 'package:produtos/domain/models/codigo.dart';

abstract class ICodigosLocalDataSource {
  Future<void> salvarCodigosDeBarras(List<Codigo> codigos);

  Future<Codigo?> recuperarCodigo(String codigo);
}
