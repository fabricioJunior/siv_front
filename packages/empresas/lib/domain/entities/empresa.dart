import 'package:core/equals.dart';

abstract class Empresa implements Equatable {
  int? get id;
  String get cnpj;
  String get nome;
  String get nomeFantasia;
  String? get uf;
  String? get inscricaoEstadual;
  String? get codigoDeAtividade;
  String? get codigoDeNaturezaJuridica;
  TipoRegimeEmpresa? get regime;
  TipoDeSubstituicaoTributaria? get substituicaoTributaria;
  String? get registroMunicipal;
  String? get telefone;
  String? get email;

  factory Empresa.create({
    int? id,
    required String cnpj,
    required String nome,
    required String nomeFantasia,
    String? uf,
    String? inscricaoEstadual,
    String? codigoDeAtividade,
    String? codigoDeNaturezaJuridica,
    TipoRegimeEmpresa? regime,
    TipoDeSubstituicaoTributaria? substituicaoTributaria,
    String? registroMunicipal,
    String? telefone,
    String? email,
  }) = _EmpresaImpl;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        cnpj,
        codigoDeAtividade,
        codigoDeNaturezaJuridica,
        email,
        id,
        inscricaoEstadual,
        nome,
        nomeFantasia,
        regime,
        registroMunicipal,
        substituicaoTributaria,
        telefone,
        uf,
      ];
}

class _EmpresaImpl implements Empresa {
  @override
  final int? id;
  @override
  final String cnpj;
  @override
  final String nome;
  @override
  final String nomeFantasia;
  @override
  final String? uf;
  @override
  final String? inscricaoEstadual;
  @override
  final String? codigoDeAtividade;
  @override
  final String? codigoDeNaturezaJuridica;
  @override
  final TipoRegimeEmpresa? regime;
  @override
  final TipoDeSubstituicaoTributaria? substituicaoTributaria;
  @override
  final String? registroMunicipal;
  @override
  final String? telefone;
  @override
  final String? email;

  _EmpresaImpl({
    this.id,
    required this.cnpj,
    required this.nome,
    required this.nomeFantasia,
    this.uf,
    this.inscricaoEstadual,
    this.codigoDeAtividade,
    this.codigoDeNaturezaJuridica,
    this.regime,
    this.substituicaoTributaria,
    this.registroMunicipal,
    this.telefone,
    this.email,
  });

  _EmpresaImpl copyWith({
    int? id,
    String? cnpj,
    String? nome,
    String? nomeFantasia,
    String? uf,
    String? inscricaoEstadual,
    String? codigoDeAtividade,
    String? codigoDeNaturezaJuridica,
    TipoRegimeEmpresa? regime,
    TipoDeSubstituicaoTributaria? substituicaoTributaria,
    String? registroMunicipal,
    String? telefone,
    String? email,
  }) {
    return _EmpresaImpl(
      id: id ?? this.id,
      cnpj: cnpj ?? this.cnpj,
      nome: nome ?? this.nome,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      uf: uf ?? this.uf,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      codigoDeAtividade: codigoDeAtividade ?? this.codigoDeAtividade,
      codigoDeNaturezaJuridica:
          codigoDeNaturezaJuridica ?? this.codigoDeNaturezaJuridica,
      regime: regime ?? this.regime,
      substituicaoTributaria:
          substituicaoTributaria ?? this.substituicaoTributaria,
      registroMunicipal: registroMunicipal ?? this.registroMunicipal,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
    );
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        cnpj,
        codigoDeAtividade,
        codigoDeNaturezaJuridica,
        email,
        id,
        inscricaoEstadual,
        nome,
        nomeFantasia,
        regime,
        registroMunicipal,
        substituicaoTributaria,
        telefone,
        uf,
      ];
}

extension EmpresaCopyWith on Empresa {
  Empresa copyWith({
    int? id,
    String? cnpj,
    String? nome,
    String? nomeFantasia,
    String? uf,
    String? inscricaoEstadual,
    String? codigoDeAtividade,
    String? codigoDeNaturezaJuridica,
    TipoRegimeEmpresa? regime,
    TipoDeSubstituicaoTributaria? substituicaoTributaria,
    String? registroMunicipal,
    String? telefone,
    String? email,
  }) {
    if (this is _EmpresaImpl) {
      return (this as _EmpresaImpl).copyWith(
        id: id,
        cnpj: cnpj,
        nome: nome,
        nomeFantasia: nomeFantasia,
        uf: uf,
        inscricaoEstadual: inscricaoEstadual,
        codigoDeAtividade: codigoDeAtividade,
        codigoDeNaturezaJuridica: codigoDeNaturezaJuridica,
        regime: regime,
        substituicaoTributaria: substituicaoTributaria,
        registroMunicipal: registroMunicipal,
        telefone: telefone,
        email: email,
      );
    }
    // If it's not _EmpresaImpl, create new instance from current values
    return Empresa.create(
      id: id ?? this.id,
      cnpj: cnpj ?? this.cnpj,
      nome: nome ?? this.nome,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      uf: uf ?? this.uf,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      codigoDeAtividade: codigoDeAtividade ?? this.codigoDeAtividade,
      codigoDeNaturezaJuridica:
          codigoDeNaturezaJuridica ?? this.codigoDeNaturezaJuridica,
      regime: regime ?? this.regime,
      substituicaoTributaria:
          substituicaoTributaria ?? this.substituicaoTributaria,
      registroMunicipal: registroMunicipal ?? this.registroMunicipal,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
    );
  }
}

enum TipoRegimeEmpresa {
  normal,
  microEmpresa,
  epp,
  lucroReal,
  lucroPresumido,
  mei,
  eireli,
  outros,
}

enum TipoDeSubstituicaoTributaria {
  calcula,
  naoCalcula,
}
