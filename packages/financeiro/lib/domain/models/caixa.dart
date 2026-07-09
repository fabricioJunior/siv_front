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
  ContagemDoCaixaInfo? get contagem;
}

enum SituacaoCaixa {
  aberto,
  contagem,
  fechado,
}

class ContagemDoCaixaInfo {
  final bool encerrada;

  const ContagemDoCaixaInfo({required this.encerrada});
}
