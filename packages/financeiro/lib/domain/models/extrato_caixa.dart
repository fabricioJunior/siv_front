abstract class ExtratoCaixa {
  DateTime get criadoEm;
  DateTime get atualizadoEm;
  int get empresaId;
  DateTime get data;
  int get caixaId;
  int get documento;
  int get liquidacao;
  TipoDocumentoExtratoCaixa get tipoDocumento;
  TipoHistoricoExtratoCaixa get tipoHistorico;
  TipoMovimentoExtratoCaixa get tipoMovimento;
  double get valor;
  int? get faturaId;
  int? get faturaParcela;
  String? get observacao;
  bool get cancelado;
  String? get motivoCancelamento;
  int get operadorId;
}

enum TipoDocumentoExtratoCaixa {
  dinheiro,
}

enum TipoHistoricoExtratoCaixa {
  aberturaDeCaixa,
}

enum TipoMovimentoExtratoCaixa {
  debito,
  credito,
}
