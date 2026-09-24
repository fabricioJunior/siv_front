import 'package:core/empresas_portas.dart';

class VerificarPermiteNotaFiscalEmail {
  final PortaVerificarPermiteNotaFiscalEmail _porta;

  VerificarPermiteNotaFiscalEmail(this._porta);

  Future<bool> call({required int empresaId}) {
    return _porta(empresaId: empresaId);
  }
}
