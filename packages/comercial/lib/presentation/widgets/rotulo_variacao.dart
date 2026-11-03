/// Cor / estampa / tamanho de um item, só com o que não está vazio.
String rotuloVariacao({
  String? cor,
  String? estampa,
  String? tamanho,
  String tamanhoRotulo = 'Tamanho',
  String separador = '  •  ',
}) {
  String? v(String? s) => (s ?? '').trim().isEmpty ? null : s!.trim();
  return [
    if (v(cor) != null) 'Cor: ${v(cor)}',
    if (v(estampa) != null) 'Estampa: ${v(estampa)}',
    if (v(tamanho) != null) '$tamanhoRotulo: ${v(tamanho)}',
  ].join(separador);
}
