abstract class Caixa {
  int get id;
  int get empresaId;
  DateTime get data;
  int get terminalId;
  DateTime get abertura;
  DateTime? get fechamento;
  double get valorAbertura;
  double? get valorFechamento;

  SituacaoCaixa get situacao;
}

enum SituacaoCaixa {
  aberto,
  fechado,
}
