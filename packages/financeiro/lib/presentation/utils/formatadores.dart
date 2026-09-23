/// `R$ 6.982,27` — sem dependência de `intl` (não instalada no pacote).
String formatarReais(double valor) {
  final negativo = valor < 0;
  final fixo = valor.abs().toStringAsFixed(2);
  final partes = fixo.split('.');
  final inteiro = partes[0];
  final decimais = partes[1];

  final buffer = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final restante = inteiro.length - i;
    if (i > 0 && restante % 3 == 0) buffer.write('.');
    buffer.write(inteiro[i]);
  }

  return '${negativo ? '-' : ''}R\$ $buffer,$decimais';
}

/// `R$ 4,8k` acima de mil, `R$ 480` abaixo — usado em espaços compactos
/// (total do dia na grade do calendário).
String formatarReaisCompacto(double valor) {
  if (valor.abs() < 1000) return 'R\$ ${valor.abs().round()}';
  final milhar = valor.abs() / 1000;
  final texto = milhar.toStringAsFixed(1).replaceAll('.', ',');
  return 'R\$ ${texto}k';
}

/// `20,2%`, uma casa decimal, vírgula.
String formatarPercentual(double valor) {
  return '${valor.toStringAsFixed(1).replaceAll('.', ',')}%';
}
