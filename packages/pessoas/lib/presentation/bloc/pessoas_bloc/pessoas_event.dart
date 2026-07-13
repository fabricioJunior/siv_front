part of 'pessoas_bloc.dart';

abstract class PessoasEvent {}

class PessoasIniciou extends PessoasEvent {
  final String? busca;
  final int? idPessoaSelecionada;
  final bool? eCliente;
  final bool? eFornecedor;
  final bool? eFuncionario;
  final bool? clienteOuFuncionario;

  PessoasIniciou({
    this.busca,
    this.idPessoaSelecionada,
    this.eCliente,
    this.eFornecedor,
    this.eFuncionario,
    this.clienteOuFuncionario,
  });
}

class PessoasCarregouMais extends PessoasEvent {}
