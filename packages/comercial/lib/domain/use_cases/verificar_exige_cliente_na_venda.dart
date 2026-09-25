import 'package:core/empresas_portas.dart';

class VerificarExigeClienteNaVenda {
  final PortaVerificarExigeClienteNaVenda _porta;

  VerificarExigeClienteNaVenda(this._porta);

  Future<bool> call({required int empresaId}) {
    return _porta(empresaId: empresaId);
  }
}
