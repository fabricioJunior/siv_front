/// Resultado de uma operação em lote (publicação de referências ou
/// disponibilidade de produtos). Usado tanto quando o endpoint de lote
/// existe quanto no fallback de laço sequencial -- a UI não sabe qual dos
/// dois foi usado.
class EcommerceLoteResultado {
  final int atualizados;
  final List<EcommerceLoteFalha> falharam;

  const EcommerceLoteResultado({
    required this.atualizados,
    this.falharam = const [],
  });
}

class EcommerceLoteFalha {
  final int id;
  final List<String> motivos;

  const EcommerceLoteFalha({required this.id, this.motivos = const []});
}
