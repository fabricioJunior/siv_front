enum SituacaoChaveMcp { ativa, expirada, revogada }

/// Escopo aceito pelas tools do MCP de vendas. [escrita] = cria registros no SIV.
class EscopoMcp {
  final String id;
  final String rotulo;
  final String descricao;
  final bool escrita;

  const EscopoMcp(this.id, this.rotulo, this.descricao, {this.escrita = false});
}

const escoposMcp = <EscopoMcp>[
  EscopoMcp('identidade', 'Identificar cliente',
      'Reconhecer o cliente pelo Instagram, por documento, nome ou telefone'),
  EscopoMcp('catalogo', 'Consultar produtos', 'Buscar produtos publicados e preços'),
  EscopoMcp('estoque', 'Consultar estoque', 'Ver disponibilidade por cor e tamanho'),
  EscopoMcp('pedido_consulta', 'Consultar pedido',
      'Ver status e pagamento de pedidos do cliente'),
  EscopoMcp('atendimento', 'Chamar atendente', 'Pedir ajuda a uma pessoa da equipe'),
  EscopoMcp('carrinho', 'Montar carrinho', 'Adicionar e remover itens', escrita: true),
  EscopoMcp('pedido', 'Criar pedido',
      'Criar o pedido a partir do carrinho (reserva estoque)',
      escrita: true),
  EscopoMcp('pagamento', 'Gerar pagamento',
      'Listar formas de pagamento e gerar a cobrança',
      escrita: true),
];

class EcommerceChaveMcp {
  final int id;
  final String nome;
  final String chaveMascarada;
  final List<String> escopos;
  final DateTime? criadoEm;
  final DateTime? expiraEm;
  final DateTime? ultimoAcessoEm;
  final DateTime? revogadaEm;

  const EcommerceChaveMcp({
    required this.id,
    required this.nome,
    required this.chaveMascarada,
    this.escopos = const [],
    this.criadoEm,
    this.expiraEm,
    this.ultimoAcessoEm,
    this.revogadaEm,
  });

  SituacaoChaveMcp get situacao => situacaoEm(DateTime.now());

  SituacaoChaveMcp situacaoEm(DateTime agora) {
    if (revogadaEm != null) return SituacaoChaveMcp.revogada;
    if (expiraEm != null && expiraEm!.isBefore(agora)) return SituacaoChaveMcp.expirada;
    return SituacaoChaveMcp.ativa;
  }
}

/// Resposta do POST: [chave] em claro só existe aqui, nunca é guardada.
class CriarChaveMcpResultado {
  final EcommerceChaveMcp registro;
  final String chave;

  const CriarChaveMcpResultado({required this.registro, required this.chave});
}
