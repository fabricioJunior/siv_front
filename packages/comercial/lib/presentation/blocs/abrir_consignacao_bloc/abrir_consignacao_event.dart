part of 'abrir_consignacao_bloc.dart';

abstract class AbrirConsignacaoEvent extends Equatable {
  const AbrirConsignacaoEvent();

  @override
  List<Object?> get props => [];
}

class AbrirConsignacaoPessoaSelecionada extends AbrirConsignacaoEvent {
  final SelectData? pessoaSelecionada;

  const AbrirConsignacaoPessoaSelecionada({this.pessoaSelecionada});

  @override
  List<Object?> get props => [pessoaSelecionada];
}

class AbrirConsignacaoFuncionarioSelecionado extends AbrirConsignacaoEvent {
  final SelectData? funcionarioSelecionado;

  const AbrirConsignacaoFuncionarioSelecionado({this.funcionarioSelecionado});

  @override
  List<Object?> get props => [funcionarioSelecionado];
}

class AbrirConsignacaoTabelaSelecionada extends AbrirConsignacaoEvent {
  final SelectData? tabelaSelecionada;

  const AbrirConsignacaoTabelaSelecionada({this.tabelaSelecionada});

  @override
  List<Object?> get props => [tabelaSelecionada];
}

class AbrirConsignacaoObservacaoAlterada extends AbrirConsignacaoEvent {
  final String observacao;

  const AbrirConsignacaoObservacaoAlterada({required this.observacao});

  @override
  List<Object?> get props => [observacao];
}

class AbrirConsignacaoConfirmarSolicitado extends AbrirConsignacaoEvent {
  const AbrirConsignacaoConfirmarSolicitado();
}
