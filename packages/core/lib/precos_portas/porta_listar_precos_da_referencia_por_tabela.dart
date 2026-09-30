import 'preco_da_referencia_por_tabela.dart';

/// Porta pra listar o preço da referência em TODAS as tabelas de preço
/// (com ou sem valor definido). Implementada em `precos`, consumida em
/// `produtos` pela aba "Tabela de preços" da tela de Referência.
abstract class PortaListarPrecosDaReferenciaPorTabela {
  Future<List<PrecoDaReferenciaPorTabela>> call({required int referenciaId});
}
