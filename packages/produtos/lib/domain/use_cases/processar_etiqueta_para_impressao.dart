class ProcessarEtiquetaParaImpressao {
  String call({
    required String templateZpl,
    required String titulo,
    required String cor,
    required String tamanho,
    required String codigoBarras,
    required double preco,
    required String descricao,
    // Limite de caracteres por campo dinamico (chave = nome do campo: titulo/cor/tamanho/
    // descricao/preco), configurado na edicao da etiqueta. Quando o dado real do produto for
    // maior que o limite, imprime so os N primeiros caracteres. codigoBarras nao trunca (quebraria
    // o EAN) mesmo se vier um limite configurado por engano.
    Map<String, int>? limitesCaracteres,
  }) {
    final tituloNormalizado = _truncar(_removerAcentos(titulo), limitesCaracteres?['titulo']);
    final corNormalizada = _truncar(_removerAcentos(cor), limitesCaracteres?['cor']);
    final tamanhoNormalizado = _truncar(_removerAcentos(tamanho), limitesCaracteres?['tamanho']);
    final codigoBarrasNormalizado = _removerAcentos(codigoBarras);
    final descricaoNormalizada = _truncar(_removerAcentos(descricao), limitesCaracteres?['descricao']);
    final precoFormatado = preco.toStringAsFixed(2).replaceAll('.', ',');
    final precoNormalizado = _truncar(_removerAcentos(precoFormatado), limitesCaracteres?['preco']);

    return templateZpl
        .replaceAll('{titulo}', tituloNormalizado)
        .replaceAll('{cor}', corNormalizada)
        .replaceAll('{tamanho}', tamanhoNormalizado)
        .replaceAll('{codigoBarras}', codigoBarrasNormalizado)
        .replaceAll('{preco}', precoNormalizado)
        .replaceAll('{descricao}', descricaoNormalizada);
  }

  String _truncar(String valor, int? limite) {
    if (limite == null || limite <= 0 || valor.length <= limite) {
      return valor;
    }
    return valor.substring(0, limite);
  }

  String _removerAcentos(String valor) {
    const comAcento = 'áàâãäåÁÀÂÃÄÅéèêëÉÈÊËíìîïÍÌÎÏóòôõöÓÒÔÕÖúùûüÚÙÛÜýÿÝçÇñÑ';
    const semAcento = 'aaaaaaAAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUyyYcCnN';

    final buffer = StringBuffer();
    for (final rune in valor.runes) {
      final caractere = String.fromCharCode(rune);
      final indice = comAcento.indexOf(caractere);
      if (indice >= 0) {
        buffer.write(semAcento[indice]);
      } else {
        buffer.write(caractere);
      }
    }

    return buffer.toString();
  }
}
