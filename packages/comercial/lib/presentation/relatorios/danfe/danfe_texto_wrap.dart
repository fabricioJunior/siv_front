/// Funcoes puras de quebra/alinhamento de texto em colunas fixas (fonte
/// monoespacada), usadas pelo renderer ESC/POS -- extraidas em arquivo a
/// parte pra serem testadas isoladamente, sem depender do stream de bytes
/// ESC/POS gerado.
library;

/// Quebra [texto] em linhas de no maximo [largura] colunas, sem cortar
/// palavra no meio (palavra maior que a largura e forcada a quebrar).
List<String> quebrarLinhaDanfe(String texto, int largura) {
  if (texto.isEmpty) return [''];
  final palavras = texto.split(' ');
  final linhas = <String>[];
  var atual = StringBuffer();

  for (final palavra in palavras) {
    final candidata = atual.isEmpty ? palavra : '${atual.toString()} $palavra';
    if (candidata.length <= largura) {
      atual = StringBuffer(candidata);
      continue;
    }
    if (atual.isNotEmpty) {
      linhas.add(atual.toString());
      atual = StringBuffer();
    }
    var restante = palavra;
    while (restante.length > largura) {
      linhas.add(restante.substring(0, largura));
      restante = restante.substring(largura);
    }
    atual = StringBuffer(restante);
  }
  if (atual.isNotEmpty) linhas.add(atual.toString());
  return linhas.isEmpty ? [''] : linhas;
}

/// Monta linha(s) com texto a esquerda e valor a direita. Quando cabem na
/// mesma linha, preenche com espacos; senao, o valor vai pra ultima linha
/// do texto (a esquerda, ja quebrado), alinhado a direita.
List<String> linhaComValorDireitaDanfe(String esquerda, String direita, int largura) {
  final linhasEsquerda = quebrarLinhaDanfe(esquerda, largura);
  final ultimaLinha = linhasEsquerda.removeLast();

  final espacoDisponivel = largura - ultimaLinha.length - direita.length;
  if (espacoDisponivel >= 1) {
    linhasEsquerda.add('$ultimaLinha${' ' * espacoDisponivel}$direita');
  } else {
    linhasEsquerda.add(ultimaLinha);
    linhasEsquerda.add(direita.padLeft(largura));
  }
  return linhasEsquerda;
}
