/// Combinação cor/tamanho de uma referência a ser criada em lote (uma única
/// requisição pra N combinações, em vez de 1 requisição por combinação --
/// ver [CriarProdutosEmLote]/`ProdutoBloc._onProdutoSalvouCombinacoes`).
class NovoProdutoCombinacao {
  final int referenciaId;
  final String? idExterno;
  final int corId;
  final int tamanhoId;
  final String? codigoDeBarras;

  const NovoProdutoCombinacao({
    required this.referenciaId,
    this.idExterno,
    required this.corId,
    required this.tamanhoId,
    this.codigoDeBarras,
  });
}
