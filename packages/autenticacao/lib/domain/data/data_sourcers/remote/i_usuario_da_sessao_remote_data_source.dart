import 'package:autenticacao/domain/models/usuario.dart';

abstract class IUsuarioDaSessaoRemoteDataSource {
  Future<Usuario> getUsuario();
}
