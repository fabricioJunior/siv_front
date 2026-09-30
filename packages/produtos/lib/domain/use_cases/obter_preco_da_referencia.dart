import 'package:core/precos_portas.dart';

class ObterPrecoDaReferencia {
  final PortaObterPrecoDaReferencia _porta;

  ObterPrecoDaReferencia(this._porta);

  Future<double> call({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) {
    return _porta(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
    );
  }
}
