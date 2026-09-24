import 'package:core/precos_portas.dart';
import 'package:precos/domain/use_cases/obter_preco_da_referencia.dart';

class PortaObterPrecoDaReferenciaImpl implements PortaObterPrecoDaReferencia {
  final ObterPrecoDaReferencia _obterPrecoDaReferencia;

  PortaObterPrecoDaReferenciaImpl(this._obterPrecoDaReferencia);

  @override
  Future<double> call({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) async {
    final preco = await _obterPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
    );
    return preco.valor;
  }
}
