import 'package:core/empresas_portas.dart';
import 'package:empresas/domain/usecases/recuperar_empresa.dart';

class PortaVerificarExigeClienteNaVendaImpl
    implements PortaVerificarExigeClienteNaVenda {
  final RecuperarEmpresa _recuperarEmpresa;

  PortaVerificarExigeClienteNaVendaImpl(this._recuperarEmpresa);

  @override
  Future<bool> call({required int empresaId}) async {
    final empresa = await _recuperarEmpresa.call(empresaId);
    return empresa?.exigeClienteNaVenda ?? false;
  }
}
