/// Próxima data de pagamento de uma despesa lançada num cartão de crédito.
///
/// [diaVencimento] é o dia fixo do mês em que a fatura vence.
/// [prazoFechamentoDias], se informado, é quantos dias antes do vencimento a
/// fatura fecha: se hoje já está dentro desse prazo (fatura fechada), a
/// despesa cai na fatura seguinte e o pagamento avança pro próximo mês.
///
/// Retorna a data e se o avanço aconteceu por causa do fechamento da fatura
/// (usado pra escolher a mensagem exibida no lançamento).
(DateTime, bool) proximaDataVencimentoCartao(
  int diaVencimento, {
  int? prazoFechamentoDias,
  DateTime? hoje,
}) {
  final referencia = hoje ?? DateTime.now();
  final hojeSemHora = DateTime(referencia.year, referencia.month, referencia.day);

  DateTime baseComDia(int offsetMeses) {
    final mes = referencia.month + offsetMeses;
    final ultimoDiaDoMes = DateTime(referencia.year, mes + 1, 0).day;
    return DateTime(referencia.year, mes, diaVencimento.clamp(1, ultimoDiaDoMes));
  }

  var offset = 0;
  var vencimento = baseComDia(offset);
  if (vencimento.isBefore(hojeSemHora)) {
    offset++;
    vencimento = baseComDia(offset);
  }

  var pulouPorFechamento = false;
  if (prazoFechamentoDias != null && prazoFechamentoDias > 0) {
    final fechamento = vencimento.subtract(Duration(days: prazoFechamentoDias));
    if (!hojeSemHora.isBefore(fechamento)) {
      offset++;
      vencimento = baseComDia(offset);
      pulouPorFechamento = true;
    }
  }

  return (vencimento, pulouPorFechamento);
}

/// Mesmo dia-do-mês de [data], [offsetMeses] à frente, com clamp de fim de
/// mês (ex: dia 31 de janeiro + 1 mês vira 28/fev). Usado nas datas de
/// parcela e no cálculo de vencimento de cartão acima.
DateTime vencimentoNoMes(DateTime data, int offsetMeses) {
  final mes = data.month + offsetMeses;
  final ultimoDiaDoMes = DateTime(data.year, mes + 1, 0).day;
  return DateTime(data.year, mes, data.day.clamp(1, ultimoDiaDoMes));
}
