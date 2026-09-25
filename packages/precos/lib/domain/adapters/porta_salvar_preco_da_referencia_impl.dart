import 'package:core/precos_portas.dart';
import 'package:precos/use_cases.dart';

class PortaSalvarPrecoDaReferenciaImpl implements PortaSalvarPrecoDaReferencia {
  final AtualizarPrecoDaReferencia _atualizarPrecoDaReferencia;
  final CriarPrecoDaReferencia _criarPrecoDaReferencia;

  PortaSalvarPrecoDaReferenciaImpl(
    this._atualizarPrecoDaReferencia,
    this._criarPrecoDaReferencia,
  );

  @override
  Future<PrecoDaReferenciaPorTabela> call({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
    required bool precoJaExiste,
  }) async {
    final preco = precoJaExiste
        ? await _atualizarPrecoDaReferencia.call(
            tabelaDePrecoId: tabelaDePrecoId,
            referenciaId: referenciaId,
            valor: valor,
          )
        : await _criarPrecoDaReferencia.call(
            tabelaDePrecoId: tabelaDePrecoId,
            referenciaId: referenciaId,
            valor: valor,
          );

    return PrecoDaReferenciaPorTabela(
      tabelaDePrecoId: preco.tabelaDePrecoId,
      tabelaNome: '',
      tabelaInativa: false,
      tabelaPadrao: false,
      valor: preco.valor,
      atualizadoEm: preco.atualizadoEm,
      operadorId: preco.operadorId,
    );
  }
}
