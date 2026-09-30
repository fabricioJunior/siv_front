import 'package:core/precos_portas.dart';
import 'package:precos/models.dart';
import 'package:precos/use_cases.dart';

class PortaListarPrecosDaReferenciaPorTabelaImpl
    implements PortaListarPrecosDaReferenciaPorTabela {
  final RecuperarTabelasDePreco _recuperarTabelasDePreco;
  final ObterPrecoDaReferencia _obterPrecoDaReferencia;

  PortaListarPrecosDaReferenciaPorTabelaImpl(
    this._recuperarTabelasDePreco,
    this._obterPrecoDaReferencia,
  );

  @override
  Future<List<PrecoDaReferenciaPorTabela>> call({
    required int referenciaId,
  }) async {
    final tabelas = await _recuperarTabelasDePreco.call();

    final resultado = <PrecoDaReferenciaPorTabela>[];
    for (final tabela in tabelas) {
      if (tabela.id == null) continue;

      PrecoDaReferencia? preco;
      try {
        preco = await _obterPrecoDaReferencia.call(
          tabelaDePrecoId: tabela.id!,
          referenciaId: referenciaId,
        );
      } catch (_) {
        // ponytail: sem preço cadastrado -> tabela sem valor. O
        // repositório não distingue 404 de outra falha aqui; se o
        // backend passar a expor um retorno tipado pra "sem preço",
        // trocar por checagem explícita em vez de catch genérico.
        preco = null;
      }

      resultado.add(
        PrecoDaReferenciaPorTabela(
          tabelaDePrecoId: tabela.id!,
          tabelaNome: tabela.nome,
          tabelaInativa: tabela.inativa,
          tabelaPadrao: tabela.padrao,
          terminador: tabela.terminador,
          valor: preco?.valor,
          atualizadoEm: preco?.atualizadoEm,
          operadorId: preco?.operadorId,
        ),
      );
    }

    return resultado;
  }
}
