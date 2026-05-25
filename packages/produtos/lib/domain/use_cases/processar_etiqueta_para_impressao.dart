class ProcessarEtiquetaParaImpressao {
  String call({
    required String templateZpl,
    required String titulo,
    required String cor,
    required String tamanho,
    required String codigoBarras,
    required double preco,
    required String descricao,
  }) {
    final tituloNormalizado = _removerAcentos(titulo);
    final corNormalizada = _removerAcentos(cor);
    final tamanhoNormalizado = _removerAcentos(tamanho);
    final codigoBarrasNormalizado = _removerAcentos(codigoBarras);
    final descricaoNormalizada = _removerAcentos(descricao);
    final precoFormatado = preco.toStringAsFixed(2).replaceAll('.', ',');
    final precoNormalizado = _removerAcentos(precoFormatado);

    return templateZpl
        .replaceAll('{titulo}', tituloNormalizado)
        .replaceAll('{cor}', corNormalizada)
        .replaceAll('{tamanho}', tamanhoNormalizado)
        .replaceAll('{codigoBarras}', codigoBarrasNormalizado)
        .replaceAll('{preco}', precoNormalizado)
        .replaceAll('{descricao}', descricaoNormalizada);
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
