/// Próxima data de pagamento de uma despesa lançada num cartão de crédito.
///
/// [diaVencimento] é o dia fixo do mês em que a fatura vence.
/// [prazoFechamentoDias], se informado, é quantos dias antes do vencimento a
/// fatura fecha: se hoje já está dentro desse prazo (fatura fechada), a
/// despesa cai na fatura seguinte e o pagamento avança pro próximo mês.
DateTime proximaDataVencimentoCartao(
  int diaVencimento, {
  int? prazoFechamentoDias,
  DateTime? hoje,
}) {
  final referencia = hoje ?? DateTime.now();
  final hojeSemHora = DateTime(referencia.year, referencia.month, referencia.day);

  DateTime vencimentoNoMes(int offsetMeses) {
    final mes = referencia.month + offsetMeses;
    final ultimoDiaDoMes = DateTime(referencia.year, mes + 1, 0).day;
    return DateTime(referencia.year, mes, diaVencimento.clamp(1, ultimoDiaDoMes));
  }

  var offset = 0;
  var vencimento = vencimentoNoMes(offset);
  if (vencimento.isBefore(hojeSemHora)) {
    offset++;
    vencimento = vencimentoNoMes(offset);
  }

  if (prazoFechamentoDias != null && prazoFechamentoDias > 0) {
    final fechamento = vencimento.subtract(Duration(days: prazoFechamentoDias));
    if (!hojeSemHora.isBefore(fechamento)) {
      offset++;
      vencimento = vencimentoNoMes(offset);
    }
  }

  return vencimento;
}
