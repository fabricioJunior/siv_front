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
        pessoaStep,
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
