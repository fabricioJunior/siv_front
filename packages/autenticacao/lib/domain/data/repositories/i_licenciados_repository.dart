import 'package:autenticacao/domain/models/licenciado.dart';

abstract class ILicenciadosRepository {
  Future<List<Licenciado>> recuperarLicenciados();

  Future<Licenciado?> recuperarLicenciadoDaSessao();

  Future<void> salvarLicenciadoDaSessao(Licenciado licenciado);

  Future<void> limparLicenciadoDaSessao();
}
