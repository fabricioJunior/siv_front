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

  const VendaFinalizarSolicitada({required this.itens});

  @override
  List<Object?> get props => [itens];
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
