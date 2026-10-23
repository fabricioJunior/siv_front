import 'package:core/empresas_portas.dart';
import 'package:empresas/domain/usecases/recuperar_parametros_empresa.dart';

class PortaDescontoMaximoVendedorImpl implements PortaDescontoMaximoVendedor {
  final RecuperarParametrosEmpresa _recuperarParametros;

  PortaDescontoMaximoVendedorImpl(this._recuperarParametros);

  @override
  Future<double> call({required int empresaId}) async {
    final parametros = await _recuperarParametros.call(empresaId);
    final valor = parametros
        .where((p) => p.chave == 'DESCONTO_MAXIMO_VENDEDOR')
        .map((p) => p.valorTexto)
        .firstOrNull;
    return double.tryParse(valor?.replaceAll(',', '.') ?? '') ?? 0;
  }
}
