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
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final bool pontuarFidelidade;

  const VendaFinalizarSolicitada({
    required this.itens,
    required this.formasDePagamentoRealizadas,
    this.valorDesconto = 0,
    this.valorTaxaEntrega = 0,
    this.descontosItens = const [],
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
    this.pontuarFidelidade = false,
  });

  @override
  List<Object?> get props => [
        itens,
        formasDePagamentoRealizadas,
        valorDesconto,
        valorTaxaEntrega,
        descontosItens,
        incluirCpfNaNota,
        cpfNaNota,
        pontuarFidelidade,
      ];
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
