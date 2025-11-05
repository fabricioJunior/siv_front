part of 'pessoa_bloc.dart';

abstract class PessoaEvent {}

class PessoaIniciou extends PessoaEvent {
  final int? idPessoa;
  final TipoPessoa tipoPessoa;

  PessoaIniciou({
    required this.idPessoa,
    required this.tipoPessoa,
  });
}

class PessoaEditou extends PessoaEvent {
  final bool? bloqueado;

  final String? contato;

  final String? documento;

  final bool? eCliente;

  final bool? eFornecedor;

  final bool? eFuncionario;

  final String? email;

  final String? inscricaoEstadual;

  final String? nome;

  final TipoContato? tipoContato;

  final TipoPessoa? tipoPessoa;

  final String? uf;

  final DateTime? dataDeNascimento;

  PessoaEditou({
    this.bloqueado,
    this.contato,
    this.documento,
    this.eCliente,
    this.eFornecedor,
    this.eFuncionario,
    this.email,
    this.inscricaoEstadual,
    this.nome,
    this.tipoContato,
    this.tipoPessoa,
    this.uf,
    this.dataDeNascimento,
  });
}

class PessoaSalvou extends PessoaEvent {}
