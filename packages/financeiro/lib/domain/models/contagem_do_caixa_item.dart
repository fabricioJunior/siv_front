abstract class ContagemDoCaixaItem {
  double get valor;
  TipoContagemDoCaixaItem get tipo;
}

enum TipoContagemDoCaixaItem {
  dinheiro,
  pix,
  cartao,
  fatura,
  cheque,
  troco,
  voucher,
  tedDoc,
  adiantamento,
  creditoDeDevolucao
}
