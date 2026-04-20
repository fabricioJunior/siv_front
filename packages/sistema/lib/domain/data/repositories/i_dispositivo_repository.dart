import 'package:sistema/domain/models/info_dispositivo.dart';

abstract class IDispositivoRepository {
  Future<InfoDispositivo> obterInfo();

  Future<void> apagarDadosLocais();
}
