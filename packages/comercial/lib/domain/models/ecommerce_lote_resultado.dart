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

  /// Mensagem devolvida pela API (ex.: referência já adicionada), quando houver.
  final String? mensagem;

  /// Preenchido quando [id] é o id da REFERÊNCIA (adicionar ao e-commerce), e não o do
  /// registro do e-commerce, que é o que a publicação em lote usa.
  final int? referenciaId;

  const EcommerceLoteFalha({
    required this.id,
    this.motivos = const [],
    this.mensagem,
    this.referenciaId,
  });
}
