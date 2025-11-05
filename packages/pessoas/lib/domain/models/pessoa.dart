// ignore_for_file: overridden_fields, must_be_immutable

import 'package:core/equals.dart';

mixin Pessoa implements Equatable {
  int? get id;
  String get nome;
  TipoPessoa get tipoPessoa;
  String get documento;
  String? get uf;
  String? get inscricaoEstadual;
  DateTime? dataDeNascimento;
  String? get email;
  TipoContato get tipoContato;
  String get contato;
  bool get eCliente;
  bool get eFornecedor;
  bool get eFuncionario;
  bool get bloqueado;

  static Pessoa instance(
          {required int id,
          bool bloqueado = false,
          required String contato,
          required String documento,
          required bool eCliente,
          required bool eFornecedor,
          required bool eFuncionario,
          required String email,
          required String nome,
          required TipoContato tipoContato,
          required TipoPessoa tipoPessoa,
          String? inscricaoEstadual,
          required String uf,
          DateTime? dataDeNascimento}) =>
      _Pessoa(
        id: id,
        bloqueado: bloqueado,
        contato: contato,
        documento: documento,
        eCliente: eCliente,
        eFornecedor: eFornecedor,
        eFuncionario: eFuncionario,
        email: email,
        nome: nome,
        tipoContato: tipoContato,
        tipoPessoa: tipoPessoa,
        inscricaoEstadual: inscricaoEstadual,
        uf: uf,
        dataDeNascimento: dataDeNascimento,
      );

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
  }) {
    return _Pessoa(
      id: id ?? this.id ?? 0,
      bloqueado: bloqueado ?? this.bloqueado,
      contato: contato ?? this.contato,
      documento: documento ?? this.documento,
      eCliente: eCliente ?? this.eCliente,
      eFornecedor: eFornecedor ?? this.eFornecedor,
      eFuncionario: eFuncionario ?? this.eFuncionario,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      tipoContato: tipoContato ?? this.tipoContato,
      tipoPessoa: tipoPessoa ?? this.tipoPessoa,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      uf: uf ?? this.uf,
      dataDeNascimento: dataDeNascimento ?? this.dataDeNascimento,
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
      ];

  @override
  bool? get stringify => true;
}

class _Pessoa with Pessoa {
  @override
  final bool bloqueado;

  @override
  final String contato;

  @override
  final String documento;

  @override
  final bool eCliente;

  @override
  final bool eFornecedor;

  @override
  final bool eFuncionario;

  @override
  final String? email;

  @override
  final int id;

  @override
  final String? inscricaoEstadual;

  @override
  final String nome;

  @override
  final TipoContato tipoContato;

  @override
  final TipoPessoa tipoPessoa;

  @override
  final String? uf;

  @override
  final DateTime? dataDeNascimento;

  _Pessoa({
    required this.id,
    required this.bloqueado,
    required this.contato,
    required this.documento,
    required this.eCliente,
    required this.eFornecedor,
    required this.eFuncionario,
    required this.email,
    required this.nome,
    required this.tipoContato,
    required this.tipoPessoa,
    required this.inscricaoEstadual,
    required this.uf,
    this.dataDeNascimento,
  });
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
