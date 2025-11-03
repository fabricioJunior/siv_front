// ...existing code...
import 'package:core/equals.dart';
import 'package:pessoas/models.dart';

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
  });

  PessoaState.fromModel(Pessoa pessoa)
      : bloqueado = pessoa.bloqueado,
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
        documento = pessoa.documento;

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
    );
  }

  @override
  List<Object?> get props => [
        bloqueado,
        contato,
        documento,
        eCliente,
        eFornecedor,
        eFuncionario,
        email,
        id,
        inscricaoEstadual,
        nome,
        tipoContato,
        tipoPessoa,
        uf,
        dataDeNascimento,
      ];
}
// ...existing code...
