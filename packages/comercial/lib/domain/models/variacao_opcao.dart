class VariacaoOpcao {
  final int id;
  final String nome;
  const VariacaoOpcao({required this.id, required this.nome});
}

class TamanhoOpcao {
  final int id;
  final String nome;
  const TamanhoOpcao({required this.id, required this.nome});

  /// Numérico = nome só com número (36, 38, 40,5); o resto é letras (P, M, GG).
  bool get numerico => RegExp(r'^\d+([.,]\d+)?$').hasMatch(nome.trim());
}
