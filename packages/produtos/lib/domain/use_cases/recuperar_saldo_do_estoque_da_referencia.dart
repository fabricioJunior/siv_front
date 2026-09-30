import 'package:core/estoque_portas.dart';

class RecuperarSaldoDoEstoqueDaReferencia {
  final PortaRecuperarSaldoDoEstoque _porta;

  RecuperarSaldoDoEstoqueDaReferencia(this._porta);

  Future<List<SaldoPorCorETamanho>> call({
    required int referenciaId,
    int limit = 10000,
  }) {
    return _porta.sincronizarPorReferencia(
      referenciaId: referenciaId,
      limit: limit,
    );
  }
}
