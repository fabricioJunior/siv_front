import 'package:empresas/domain/entities/empresa.dart';
import 'package:json_annotation/json_annotation.dart';

part 'empresa_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class EmpresaDto implements Empresa {
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
  @JsonKey(
    fromJson: tipoRegimeEmpresaFromJson,
    toJson: tipoRegimeEmpresaToJson,
  )
  final TipoRegimeEmpresa? regime;

  @override
  final String? registroMunicipal;

  @override
  @JsonKey(
    fromJson: tipoDeSubstituicaoTributariaFromJson,
    toJson: tipoDeSubstituicaoTributariaToJson,
  )
  final TipoDeSubstituicaoTributaria? substituicaoTributaria;

  @override
  final String? telefone;

  @override
  final String? uf;

  @override
  final String? logradouro;

  @override
  final String? numero;

  @override
  final String? bairro;

  @override
  final String? codigoMunicipioIbge;

  @override
  final String? municipio;

  @override
  final String? cep;

  EmpresaDto({
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
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.codigoMunicipioIbge,
    required this.municipio,
    required this.cep,
  });

  Map<String, dynamic> toJson() => _$EmpresaDtoToJson(this);

  factory EmpresaDto.fromJson(Map<String, dynamic> json) =>
      _$EmpresaDtoFromJson(json);

  EmpresaDto copyWith({
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
    String? logradouro,
    String? numero,
    String? bairro,
    String? codigoMunicipioIbge,
    String? municipio,
    String? cep,
  }) {
    return EmpresaDto(
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
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      codigoMunicipioIbge: codigoMunicipioIbge ?? this.codigoMunicipioIbge,
      municipio: municipio ?? this.municipio,
      cep: cep ?? this.cep,
    );
  }

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
        logradouro,
        numero,
        bairro,
        codigoMunicipioIbge,
        municipio,
        cep,
      ];

  @override
  bool? get stringify => true;

  static String? tipoDeSubstituicaoTributariaToJson(
          TipoDeSubstituicaoTributaria? tipo) =>
      _$TipoDeSubstituicaoTributariaEnumMap[tipo];

  static TipoDeSubstituicaoTributaria? tipoDeSubstituicaoTributariaFromJson(
          String? json) =>
      json == null
          ? null
          : $enumDecode<TipoDeSubstituicaoTributaria, String>(
              _$TipoDeSubstituicaoTributariaEnumMap,
              json,
            );
  static TipoRegimeEmpresa? tipoRegimeEmpresaFromJson(String? json) =>
      json == null
          ? null
          : $enumDecode<TipoRegimeEmpresa, String>(
              _$TipoRegimeEmpresaEnumMap,
              json,
            );
  static String? tipoRegimeEmpresaToJson(TipoRegimeEmpresa? tipo) =>
      _$TipoRegimeEmpresaEnumMap[tipo];
}

const _$TipoRegimeEmpresaEnumMap = {
  TipoRegimeEmpresa.normal: 'Normal',
  TipoRegimeEmpresa.microEmpresa: 'MicroEmpresa',
  TipoRegimeEmpresa.epp: 'Epp',
  TipoRegimeEmpresa.lucroReal: 'LucroReal',
  TipoRegimeEmpresa.lucroPresumido: 'LucroPresumido',
  TipoRegimeEmpresa.mei: 'Mei',
  TipoRegimeEmpresa.eireli: 'Eireli',
  TipoRegimeEmpresa.outros: 'Outros',
};

const _$TipoDeSubstituicaoTributariaEnumMap = {
  TipoDeSubstituicaoTributaria.calcula: 'Calcula',
  TipoDeSubstituicaoTributaria.naoCalcula: 'NaoCalcula',
};
