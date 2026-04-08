part of 'entrada_manual_de_produtos_bloc.dart';

abstract class EntradaManualDeProdutosEvent extends Equatable {
  const EntradaManualDeProdutosEvent();

  @override
  List<Object?> get props => [];
}

class EntradaManualFuncionarioSelecionado extends EntradaManualDeProdutosEvent {
  final SelectData? funcionarioSelecionado;

  const EntradaManualFuncionarioSelecionado({this.funcionarioSelecionado});

  @override
  List<Object?> get props => [funcionarioSelecionado];
}

class EntradaManualTabelaDePrecoSelecionada
    extends EntradaManualDeProdutosEvent {
  final SelectData? tabelaDePrecoSelecionada;

  const EntradaManualTabelaDePrecoSelecionada({this.tabelaDePrecoSelecionada});

  @override
  List<Object?> get props => [tabelaDePrecoSelecionada];
}

class EntradaManualLeituraSolicitada extends EntradaManualDeProdutosEvent {
  const EntradaManualLeituraSolicitada();
}

class EntradaManualEdicaoSolicitada extends EntradaManualDeProdutosEvent {
  const EntradaManualEdicaoSolicitada();
}

class EntradaManualSalvarSolicitado extends EntradaManualDeProdutosEvent {
  const EntradaManualSalvarSolicitado();
}
