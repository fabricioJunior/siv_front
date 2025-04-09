import 'package:core/equals.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:json_annotation/json_annotation.dart';

part 'empresa_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class EmpresaDto with Empresa, EquatableMixin {
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
  });

  Map<String, dynamic> toJson() => _$EmpresaDtoToJson(this);

  factory EmpresaDto.fromJson(Map<String, dynamic> json) =>
      _$EmpresaDtoFromJson(json);

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
