import 'package:core/impressoras/printers/tipo_impressora.dart';

abstract class IImpressoraPreferidaRepository {
  Future<String?> obterUltimaImpressora(TipoImpressora tipo);
  Future<void> salvarUltimaImpressora(TipoImpressora tipo, String nomeImpressora);
}
