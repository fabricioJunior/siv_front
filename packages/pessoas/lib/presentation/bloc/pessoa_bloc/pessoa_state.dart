// ...existing code...

part of 'pessoa_bloc.dart';

class PessoaState extends Equatable {
  final bool? bloqueado;

  final String? contato;

  final String? documento;

  final bool? eCliente;

  final bool? eFornecedor;

  final bool? eFuncionario;

  final String? email;

  final int? id;

  final String? inscricaoEstadual;

  final String? nome;

  final TipoContato? tipoContato;

  final TipoPessoa? tipoPessoa;

  final String? uf;

  final DateTime? dataDeNascimento;

  final PessoaStep pessoaStep;

  final Pessoa? pessoa;

  final TipoFuncionario? tipoFuncionario;

  final String? funcionarioNome;

  final int? funcionarioEmpresaId;

  final String? funcionarioEmpresaNome;

  final bool funcionarioInativo;

  final String? erro;

  final String? enderecoCep;

  final String? enderecoLogradouro;

  final String? enderecoNumero;

  final String? enderecoComplemento;

  final String? enderecoBairro;

  final String? enderecoMunicipio;

  final String? enderecoUf;

  final bool enderecoBuscandoCep;

  final String? enderecoErroCep;

  final String? avisoEndereco;

  const PessoaState({
    this.bloqueado,
    this.contato,
    this.documento,
    this.eCliente,
    this.eFornecedor,
    this.eFuncionario,
    this.email,
    this.id,
    this.inscricaoEstadual,
    this.nome,
    this.tipoContato,
    this.tipoPessoa,
    this.uf,
    this.dataDeNascimento,
    this.pessoa,
    this.tipoFuncionario,
    this.funcionarioNome,
    this.funcionarioEmpresaId,
    this.funcionarioEmpresaNome,
    this.funcionarioInativo = false,
    this.erro,
    this.enderecoCep,
    this.enderecoLogradouro,
    this.enderecoNumero,
    this.enderecoComplemento,
    this.enderecoBairro,
    this.enderecoMunicipio,
    this.enderecoUf,
    this.enderecoBuscandoCep = false,
    this.enderecoErroCep,
    this.avisoEndereco,
    required this.pessoaStep,
  });

  PessoaState.fromModel(
    this.pessoa, {
    PessoaStep? step,
  })  : bloqueado = pessoa!.bloqueado,
        contato = pessoa.contato,
        eCliente = pessoa.eCliente,
        eFornecedor = pessoa.eFornecedor,
        eFuncionario = pessoa.eFuncionario,
        email = pessoa.email,
        id = pessoa.id,
        inscricaoEstadual = pessoa.inscricaoEstadual,
        nome = pessoa.nome,
        tipoContato = pessoa.tipoContato,
        tipoPessoa = pessoa.tipoPessoa,
        uf = pessoa.uf,
        dataDeNascimento = pessoa.dataDeNascimento,
        documento = pessoa.documento,
        tipoFuncionario = null,
        funcionarioNome = null,
        funcionarioEmpresaId = null,
        funcionarioEmpresaNome = null,
        funcionarioInativo = false,
        erro = null,
        enderecoCep = null,
        enderecoLogradouro = null,
        enderecoNumero = null,
        enderecoComplemento = null,
        enderecoBairro = null,
        enderecoMunicipio = null,
        enderecoUf = null,
        enderecoBuscandoCep = false,
        enderecoErroCep = null,
        avisoEndereco = null,
        pessoaStep = step ?? PessoaStep.carregado;

  PessoaState copyWith({
    bool? bloqueado,
    String? contato,
    String? documento,
    bool? eCliente,
    bool? eFornecedor,
    bool? eFuncionario,
    String? email,
    int? id,
    String? inscricaoEstadual,
    String? nome,
    TipoContato? tipoContato,
    TipoPessoa? tipoPessoa,
    String? uf,
    DateTime? dataDeNascimento,
    PessoaStep? pessoaStep,
    Pessoa? pessoa,
    TipoFuncionario? tipoFuncionario,
    String? funcionarioNome,
    int? funcionarioEmpresaId,
    String? funcionarioEmpresaNome,
    bool? funcionarioInativo,
    String? erro,
    String? enderecoCep,
    String? enderecoLogradouro,
    String? enderecoNumero,
    String? enderecoComplemento,
    String? enderecoBairro,
    String? enderecoMunicipio,
    String? enderecoUf,
    bool? enderecoBuscandoCep,
    String? enderecoErroCep,
    String? avisoEndereco,
    bool limparAvisoEndereco = false,
    bool limparErroCep = false,
  }) {
    return PessoaState(
      bloqueado: bloqueado ?? this.bloqueado,
      contato: contato ?? this.contato,
      documento: documento ?? this.documento,
      eCliente: eCliente ?? this.eCliente,
      eFornecedor: eFornecedor ?? this.eFornecedor,
      eFuncionario: eFuncionario ?? this.eFuncionario,
      email: email ?? this.email,
      id: id ?? this.id,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      nome: nome ?? this.nome,
      tipoContato: tipoContato ?? this.tipoContato,
      tipoPessoa: tipoPessoa ?? this.tipoPessoa,
      uf: uf ?? this.uf,
      dataDeNascimento: dataDeNascimento ?? this.dataDeNascimento,
      pessoaStep: pessoaStep ?? this.pessoaStep,
      pessoa: pessoa ?? this.pessoa,
      tipoFuncionario: tipoFuncionario ?? this.tipoFuncionario,
      funcionarioNome: funcionarioNome ?? this.funcionarioNome,
      funcionarioEmpresaId: funcionarioEmpresaId ?? this.funcionarioEmpresaId,
      funcionarioEmpresaNome:
          funcionarioEmpresaNome ?? this.funcionarioEmpresaNome,
      funcionarioInativo: funcionarioInativo ?? this.funcionarioInativo,
      erro: erro ?? this.erro,
      enderecoCep: enderecoCep ?? this.enderecoCep,
      enderecoLogradouro: enderecoLogradouro ?? this.enderecoLogradouro,
      enderecoNumero: enderecoNumero ?? this.enderecoNumero,
      enderecoComplemento: enderecoComplemento ?? this.enderecoComplemento,
      enderecoBairro: enderecoBairro ?? this.enderecoBairro,
      enderecoMunicipio: enderecoMunicipio ?? this.enderecoMunicipio,
      enderecoUf: enderecoUf ?? this.enderecoUf,
      enderecoBuscandoCep: enderecoBuscandoCep ?? this.enderecoBuscandoCep,
      enderecoErroCep:
          limparErroCep ? null : (enderecoErroCep ?? this.enderecoErroCep),
      avisoEndereco:
          limparAvisoEndereco ? null : (avisoEndereco ?? this.avisoEndereco),
    );
  }

  @override
  List<Object?> get props => [
        bloqueado,
        contato,
        documento,
        eCliente,
        eFuncionario,
        eFornecedor,
        email,
        inscricaoEstadual,
        nome,
        tipoContato,
        tipoPessoa,
        uf,
        dataDeNascimento,
        tipoFuncionario,
        funcionarioNome,
        funcionarioEmpresaId,
        funcionarioEmpresaNome,
        funcionarioInativo,
        pessoaStep,
        erro,
        enderecoCep,
        enderecoLogradouro,
        enderecoNumero,
        enderecoComplemento,
        enderecoBairro,
        enderecoMunicipio,
        enderecoUf,
        enderecoBuscandoCep,
        enderecoErroCep,
        avisoEndereco,
      ];
}
// ...existing code...

enum PessoaStep {
  inicial,
  carregando,
  carregado,
  editando,
  salva,
  criada,
  falha,
}
