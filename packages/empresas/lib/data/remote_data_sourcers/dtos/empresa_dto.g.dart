// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empresa_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmpresaDto _$EmpresaDtoFromJson(Map<String, dynamic> json) => EmpresaDto(
  cnpj: json['cnpj'] as String,
  codigoDeAtividade: json['codigoDeAtividade'] as String?,
  codigoDeNaturezaJuridica: json['codigoDeNaturezaJuridica'] as String?,
  email: json['email'] as String?,
  id: (json['id'] as num?)?.toInt(),
  inscricaoEstadual: json['inscricaoEstadual'] as String?,
  nome: json['nome'] as String,
  nomeFantasia: json['nomeFantasia'] as String,
  regime: EmpresaDto.tipoRegimeEmpresaFromJson(json['regime'] as String?),
  registroMunicipal: json['registroMunicipal'] as String?,
  substituicaoTributaria: EmpresaDto.tipoDeSubstituicaoTributariaFromJson(
    json['substituicaoTributaria'] as String?,
  ),
  telefone: json['telefone'] as String?,
  uf: json['uf'] as String?,
);

Map<String, dynamic> _$EmpresaDtoToJson(EmpresaDto instance) =>
    <String, dynamic>{
      'cnpj': instance.cnpj,
      'codigoDeAtividade': ?instance.codigoDeAtividade,
      'codigoDeNaturezaJuridica': ?instance.codigoDeNaturezaJuridica,
      'email': ?instance.email,
      'id': ?instance.id,
      'inscricaoEstadual': ?instance.inscricaoEstadual,
      'nome': instance.nome,
      'nomeFantasia': instance.nomeFantasia,
      'regime': ?EmpresaDto.tipoRegimeEmpresaToJson(instance.regime),
      'registroMunicipal': ?instance.registroMunicipal,
      'substituicaoTributaria': ?EmpresaDto.tipoDeSubstituicaoTributariaToJson(
        instance.substituicaoTributaria,
      ),
      'telefone': ?instance.telefone,
      'uf': ?instance.uf,
    };
