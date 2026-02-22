import 'package:autenticacao/domain/models/licenciado.dart';

abstract class ILicenciadosRemoteDataSource {
  Future<List<Licenciado>> recuperarLicenciados();
}
