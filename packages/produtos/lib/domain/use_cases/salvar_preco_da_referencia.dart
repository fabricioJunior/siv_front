import 'package:core/precos_portas.dart';

class SalvarPrecoDaReferencia {
  final PortaSalvarPrecoDaReferencia _porta;

  SalvarPrecoDaReferencia(this._porta);

  Future<PrecoDaReferenciaPorTabela> call({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
    required bool precoJaExiste,
  }) {
    return _porta(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
      valor: valor,
      precoJaExiste: precoJaExiste,
    );
  }
}
