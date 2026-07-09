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

  final TipoFuncionario? tipoFuncionario;

  final int? funcionarioEmpresaId;

  final String? funcionarioEmpresaNome;

  final bool? funcionarioInativo;

  final String? enderecoCep;

  final String? enderecoLogradouro;

  final String? enderecoNumero;

  final String? enderecoComplemento;

  final String? enderecoBairro;

  final String? enderecoMunicipio;

  final String? enderecoUf;

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
    this.tipoFuncionario,
    this.funcionarioEmpresaId,
    this.funcionarioEmpresaNome,
    this.funcionarioInativo,
    this.enderecoCep,
    this.enderecoLogradouro,
    this.enderecoNumero,
    this.enderecoComplemento,
    this.enderecoBairro,
    this.enderecoMunicipio,
    this.enderecoUf,
  });
}

class PessoaSalvou extends PessoaEvent {}

class PessoaBuscarCepEndereco extends PessoaEvent {
  final String cep;

  PessoaBuscarCepEndereco({required this.cep});
}
