import 'package:core/empresas_portas.dart';

class RecuperarDescontoMaximoVendedor {
  final PortaDescontoMaximoVendedor _porta;

  RecuperarDescontoMaximoVendedor(this._porta);

  Future<double> call({required int empresaId}) {
    return _porta(empresaId: empresaId);
  }
}
