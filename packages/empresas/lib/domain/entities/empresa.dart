import 'package:core/equals.dart';

mixin Empresa implements Equatable {
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

  static Empresa instance({
    required String cnpj,
    required String? codigoDeAtividade,
    required String? codigoDeNaturezaJuridica,
    required String email,
    required int? id,
    required String? inscricaoEstadual,
    required String nome,
    required String nomeFantasia,
    required TipoRegimeEmpresa? regime,
    required String? registroMunicipal,
    required TipoDeSubstituicaoTributaria? substituicaoTributaria,
    required String? telefone,
    required String? uf,
  }) =>
      _Empresa(
        cnpj: cnpj,
        codigoDeAtividade: codigoDeAtividade,
        codigoDeNaturezaJuridica: codigoDeNaturezaJuridica,
        email: email,
        id: id,
        inscricaoEstadual: inscricaoEstadual,
        nome: nome,
        nomeFantasia: nomeFantasia,
        regime: regime,
        registroMunicipal: registroMunicipal,
        substituicaoTributaria: substituicaoTributaria,
        telefone: telefone,
        uf: uf,
      );

  Empresa copyWith({
    String? cnpj,
    String? codigoDeAtividade,
    String? codigoDeNaturezaJuridica,
    String? email,
    int? id,
    String? inscricaoEstadual,
    String? nome,
    String? nomeFantasia,
    TipoRegimeEmpresa? regime,
    String? registroMunicipal,
    TipoDeSubstituicaoTributaria? substituicaoTributaria,
    String? telefone,
    String? uf,
  }) {
    return _Empresa(
      cnpj: cnpj ?? this.cnpj,
      codigoDeAtividade: codigoDeAtividade ?? this.codigoDeAtividade,
      codigoDeNaturezaJuridica:
          codigoDeNaturezaJuridica ?? this.codigoDeNaturezaJuridica,
      email: email ?? this.email,
      id: id ?? this.id,
      inscricaoEstadual: inscricaoEstadual ?? this.inscricaoEstadual,
      nome: nome ?? this.nome,
      nomeFantasia: nomeFantasia ?? this.nomeFantasia,
      regime: regime ?? this.regime,
      registroMunicipal: registroMunicipal ?? this.registroMunicipal,
      substituicaoTributaria:
          substituicaoTributaria ?? this.substituicaoTributaria,
      telefone: telefone ?? this.telefone,
      uf: uf ?? this.uf,
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

class _Empresa with Empresa {
  @override
  final String cnpj;

  @override
  final String? codigoDeAtividade;

  @override
  final String? codigoDeNaturezaJuridica;

  @override
  final String? email;

  @override
  final int? id;

  @override
  final String? inscricaoEstadual;

  @override
  final String nome;

  @override
  final String nomeFantasia;

  @override
  final TipoRegimeEmpresa? regime;

  @override
  final String? registroMunicipal;

  @override
  final TipoDeSubstituicaoTributaria? substituicaoTributaria;

  @override
  final String? telefone;

  @override
  final String? uf;

  _Empresa({
    required this.cnpj,
    required this.codigoDeAtividade,
    required this.codigoDeNaturezaJuridica,
    required this.email,
    required this.id,
    required this.inscricaoEstadual,
    required this.nome,
    required this.nomeFantasia,
    required this.regime,
    required this.registroMunicipal,
    required this.substituicaoTributaria,
    required this.telefone,
    required this.uf,
  });
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
