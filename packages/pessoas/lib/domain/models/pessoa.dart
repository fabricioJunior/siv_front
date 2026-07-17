// ignore_for_file: overridden_fields, must_be_immutable

import 'package:core/equals.dart';

abstract class Pessoa implements Equatable {
  int? get id;
  String get nome;
  TipoPessoa get tipoPessoa;
  String get documento;
  String? get uf;
  String? get inscricaoEstadual;
  DateTime? get dataDeNascimento;
  String? get email;
  TipoContato get tipoContato;
  String? get contato;
  bool get eCliente;
  bool get eFornecedor;
  bool get eFuncionario;
  bool get bloqueado;
  bool get generica;

  factory Pessoa.create({
    int? id,
    required String nome,
    required TipoPessoa tipoPessoa,
    required String documento,
    String? uf,
    String? inscricaoEstadual,
    DateTime? dataDeNascimento,
    String? email,
    required TipoContato tipoContato,
    required String? contato,
    required bool eCliente,
    required bool eFornecedor,
    required bool eFuncionario,
    required bool bloqueado,
    required bool generica,
  }) = _PessoaImpl;

  @override
  List<Object?> get props => [
        nome,
        tipoPessoa,
        documento,
        uf,
        inscricaoEstadual,
        dataDeNascimento,
        email,
        tipoContato,
        contato,
        eCliente,
        eFornecedor,
        eFuncionario,
        bloqueado,
        generica,
      ];

  @override
  bool? get stringify => true;
}

class _PessoaImpl implements Pessoa {
  @override
  final int? id;
  @override
  final String nome;
  @override
  final TipoPessoa tipoPessoa;
  @override
  final String documento;
  @override
  final String? uf;
  @override
  final String? inscricaoEstadual;
  @override
  final DateTime? dataDeNascimento;
  @override
  final String? email;
  @override
  final TipoContato tipoContato;
  @override
  final String? contato;
  @override
  final bool eCliente;
  @override
  final bool eFornecedor;
  @override
  final bool eFuncionario;
  @override
  final bool bloqueado;
  @override
  final bool generica;

  _PessoaImpl({
    this.id,
    required this.nome,
    required this.tipoPessoa,
    required this.documento,
    this.uf,
    this.inscricaoEstadual,
    this.dataDeNascimento,
    this.email,
    required this.tipoContato,
    required this.contato,
    required this.eCliente,
    required this.eFornecedor,
    required this.eFuncionario,
    required this.bloqueado,
    this.generica = false,
  });

  _PessoaImpl copyWith({
    int? id,
    String? nome,
    TipoPessoa? tipoPessoa,
    String? documento,
    String? uf,
    String? inscricaoEstadual,
    DateTime? dataDeNascimento,
    String? email,
    TipoContato? tipoContato,
    String? contato,
    bool? eCliente,
    bool? eFornecedor,
    bool? eFuncionario,
    bool? bloqueado,
    bool? generica,
  }) {
    return _PessoaImpl(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipoPessoa: tipoPessoa ?? this.tipoPessoa,
      documento: documento ?? this.documento,
      uf: uf ?? this.uf,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      dataDeNascimento: dataDeNascimento ?? this.dataDeNascimento,
      email: email ?? this.email,
      tipoContato: tipoContato ?? this.tipoContato,
      contato: contato ?? this.contato,
      eCliente: eCliente ?? this.eCliente,
      eFornecedor: eFornecedor ?? this.eFornecedor,
      eFuncionario: eFuncionario ?? this.eFuncionario,
      bloqueado: bloqueado ?? this.bloqueado,
      generica: generica ?? this.generica,
    );
  }

  @override
  List<Object?> get props => [
        nome,
        tipoPessoa,
        documento,
        uf,
        inscricaoEstadual,
        dataDeNascimento,
        email,
        tipoContato,
        contato,
        eCliente,
        eFornecedor,
        eFuncionario,
        bloqueado,
        generica,
      ];

  @override
  bool? get stringify => true;
}

extension PessoaCopyWith on Pessoa {
  Pessoa copyWith({
    int? id,
    String? nome,
    TipoPessoa? tipoPessoa,
    String? documento,
    String? uf,
    String? inscricaoEstadual,
    DateTime? dataDeNascimento,
    String? email,
    TipoContato? tipoContato,
    String? contato,
    bool? eCliente,
    bool? eFornecedor,
    bool? eFuncionario,
    bool? bloqueado,
    bool? generica,
  }) {
    if (this is _PessoaImpl) {
      return (this as _PessoaImpl).copyWith(
        id: id,
        nome: nome,
        tipoPessoa: tipoPessoa,
        documento: documento,
        uf: uf,
        inscricaoEstadual: inscricaoEstadual,
        dataDeNascimento: dataDeNascimento,
        email: email,
        tipoContato: tipoContato,
        contato: contato,
        eCliente: eCliente,
        eFornecedor: eFornecedor,
        eFuncionario: eFuncionario,
        bloqueado: bloqueado,
        generica: generica,
      );
    }
    return Pessoa.create(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipoPessoa: tipoPessoa ?? this.tipoPessoa,
      documento: documento ?? this.documento,
      uf: uf ?? this.uf,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      dataDeNascimento: dataDeNascimento ?? this.dataDeNascimento,
      email: email ?? this.email,
      tipoContato: tipoContato ?? this.tipoContato,
      contato: contato ?? this.contato,
      eCliente: eCliente ?? this.eCliente,
      eFornecedor: eFornecedor ?? this.eFornecedor,
      eFuncionario: eFuncionario ?? this.eFuncionario,
      bloqueado: bloqueado ?? this.bloqueado,
      generica: generica ?? this.generica,
    );
  }
}

enum TipoContato {
  telefone,
  celular,
  whatsApp,
  telegram,
}

enum TipoPessoa {
  fisica,
  juridica,
}
