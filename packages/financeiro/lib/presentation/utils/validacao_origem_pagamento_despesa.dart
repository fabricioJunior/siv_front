/// Validação de dia de vencimento (1-31) do cadastro de origem de
/// pagamento -- reusada na página dedicada e na edição em linha de
/// Cadastros.
String? validarDiaVencimento(int? dia) {
  if (dia == null || dia <= 0 || dia > 31) return 'Informe um dia válido (1-31)';
  return null;
}

/// Validação do prazo de fechamento (1-30 dias antes do vencimento),
/// obrigatório só pra cartão de crédito.
String? validarPrazoFechamentoDias(int? dias) {
  if (dias == null || dias <= 0 || dias > 30) return 'Informe uma quantidade válida (1-30)';
  return null;
}
