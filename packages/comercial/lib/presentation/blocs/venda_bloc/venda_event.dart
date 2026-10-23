part of 'venda_bloc.dart';

sealed class VendaEvent extends Equatable {
  const VendaEvent();

  @override
  List<Object?> get props => [];
}

class VendaClienteSelecionado extends VendaEvent {
  final SelectData? clienteSelecionado;

  const VendaClienteSelecionado({required this.clienteSelecionado});

  @override
  List<Object?> get props => [clienteSelecionado];
}

class VendaClienteNaoCadastradoSolicitado extends VendaEvent {
  const VendaClienteNaoCadastradoSolicitado();
}

class VendaVendedorSelecionado extends VendaEvent {
  final SelectData? vendedorSelecionado;

  const VendaVendedorSelecionado({required this.vendedorSelecionado});

  @override
  List<Object?> get props => [vendedorSelecionado];
}

class VendaTabelaDePrecoSelecionada extends VendaEvent {
  final SelectData? tabelaDePrecoSelecionada;

  const VendaTabelaDePrecoSelecionada({required this.tabelaDePrecoSelecionada});

  @override
  List<Object?> get props => [tabelaDePrecoSelecionada];
}

class VendaLeituraSolicitada extends VendaEvent {
  const VendaLeituraSolicitada();
}

class VendaEdicaoSolicitada extends VendaEvent {
  const VendaEdicaoSolicitada();
}

class VendaFinalizarSolicitada extends VendaEvent {
  final List<Map<String, dynamic>> itens;
  final List<Map<String, dynamic>> formasDePagamentoRealizadas;
  final double valorDesconto;
  final double valorTaxaEntrega;
  final List<Map<String, dynamic>> descontosItens;
  final List<Map<String, dynamic>> descontosPromocao;
  final List<Map<String, dynamic>>? cupons;
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final bool pontuarFidelidade;
  final bool enviarNotaPorEmail;
  final String emailNota;

  const VendaFinalizarSolicitada({
    required this.itens,
    required this.formasDePagamentoRealizadas,
    this.valorDesconto = 0,
    this.valorTaxaEntrega = 0,
    this.descontosItens = const [],
    this.descontosPromocao = const [],
    this.cupons,
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
    this.pontuarFidelidade = false,
    this.enviarNotaPorEmail = false,
    this.emailNota = '',
  });

  @override
  List<Object?> get props => [
        itens,
        formasDePagamentoRealizadas,
        valorDesconto,
        valorTaxaEntrega,
        descontosItens,
        descontosPromocao,
        cupons,
        incluirCpfNaNota,
        cpfNaNota,
        pontuarFidelidade,
        enviarNotaPorEmail,
        emailNota,
      ];
}

/// F9 na leitura: valida e abre a etapa de pagamento.
class VendaPagamentoSolicitado extends VendaEvent {
  final double subtotal;

  const VendaPagamentoSolicitado({required this.subtotal});

  @override
  List<Object?> get props => [subtotal];
}

/// Esc no pagamento: volta aos itens.
class VendaPagamentoVoltou extends VendaEvent {
  const VendaPagamentoVoltou();
}

/// F4 na leitura. `texto` em R$ ("20,00") ou percentual ("10%"); vazio remove.
class VendaDescontoAlterado extends VendaEvent {
  final String texto;
  final double subtotal;

  const VendaDescontoAlterado({required this.texto, required this.subtotal});

  @override
  List<Object?> get props => [texto, subtotal];
}

/// Enter na venda concluída: volta aos itens mantendo vendedor e tabela.
class VendaNovaVendaSolicitada extends VendaEvent {
  const VendaNovaVendaSolicitada();
}

/// Nota emitida: reenvia por e-mail; falha/rejeitada: reprocessa.
class VendaNotaReenviarSolicitada extends VendaEvent {
  final DocumentoFiscal documentoFiscal;

  const VendaNotaReenviarSolicitada(this.documentoFiscal);

  @override
  List<Object?> get props => [documentoFiscal];
}

class VendaCriarPedidoSolicitado extends VendaEvent {
  final List<Map<String, dynamic>> itens;
  final int quantidadeProdutos;
  final double valorTotal;

  const VendaCriarPedidoSolicitado({
    required this.itens,
    required this.quantidadeProdutos,
    required this.valorTotal,
  });

  @override
  List<Object?> get props => [itens, quantidadeProdutos, valorTotal];
}

class VendaResetSolicitado extends VendaEvent {
  const VendaResetSolicitado();
}

class VendaOrcamentoSalvarSolicitado extends VendaEvent {
  final List<Map<String, dynamic>> itens;

  const VendaOrcamentoSalvarSolicitado({required this.itens});

  @override
  List<Object?> get props => [itens];
}

class VendaOrcamentoCarregarSolicitado extends VendaEvent {
  final String hash;

  const VendaOrcamentoCarregarSolicitado({required this.hash});

  @override
  List<Object?> get props => [hash];
}

class VendaOrcamentoExcluirAposFinalizarSolicitado extends VendaEvent {
  final String hash;

  const VendaOrcamentoExcluirAposFinalizarSolicitado({required this.hash});

  @override
  List<Object?> get props => [hash];
}
