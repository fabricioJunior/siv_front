import 'package:sistema/domain/models/info_dispositivo.dart';

abstract class IDispositivoLocalDataSource {
  Future<InfoDispositivo> obterInfo();

  Future<void> apagarDadosLocais();
}
