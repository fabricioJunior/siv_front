/// Motivos de bloqueio (`motivosBloqueio`) e o texto exibido pra cada um.
/// Se o backend mandar um código fora deste mapa, mostra o próprio código.
/// Fonte única -- usada pela lista de referências e pela checklist de
/// publicação da tela de detalhe.
const Map<String, String> textoMotivoBloqueioEcommerce = {
  'SEM_PRECO': 'Falta preço na tabela do canal',
  'SEM_MIDIA': 'Falta mídia — sem imagem cadastrada',
  'SEM_SALDO': 'Sem saldo em estoque',
  'SEM_GRADE_ATIVA': 'Nenhum item da grade disponível',
};

/// `R$ 1.234,56` -- com separador de milhar, diferente do
/// `valor.toStringAsFixed(2)` que várias telas do módulo duplicavam.
String formatarMoedaEcommerce(double valor) {
  final negativo = valor < 0;
  final centavos = (valor.abs() * 100).round();
  final inteiro = (centavos ~/ 100).toString();
  final decimal = (centavos % 100).toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final restante = inteiro.length - i;
    if (i > 0 && restante % 3 == 0) buffer.write('.');
    buffer.write(inteiro[i]);
  }
  return 'R\$ ${negativo ? '-' : ''}$buffer,$decimal';
}

/// `1 referência` / `2 referências` -- plural sem parênteses.
String pluralizarEcommerce(int quantidade, String singular, String plural) =>
    quantidade == 1 ? '$quantidade $singular' : '$quantidade $plural';
