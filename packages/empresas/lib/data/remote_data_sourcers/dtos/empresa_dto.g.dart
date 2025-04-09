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
          json['substituicaoTributaria'] as String?),
      telefone: json['telefone'] as String?,
      uf: json['uf'] as String?,
    );

Map<String, dynamic> _$EmpresaDtoToJson(EmpresaDto instance) =>
    <String, dynamic>{
      'cnpj': instance.cnpj,
      if (instance.codigoDeAtividade case final value?)
        'codigoDeAtividade': value,
      if (instance.codigoDeNaturezaJuridica case final value?)
        'codigoDeNaturezaJuridica': value,
      if (instance.email case final value?) 'email': value,
      if (instance.id case final value?) 'id': value,
      if (instance.inscricaoEstadual case final value?)
        'inscricaoEstadual': value,
      'nome': instance.nome,
      'nomeFantasia': instance.nomeFantasia,
      if (EmpresaDto.tipoRegimeEmpresaToJson(instance.regime) case final value?)
        'regime': value,
      if (instance.registroMunicipal case final value?)
        'registroMunicipal': value,
      if (EmpresaDto.tipoDeSubstituicaoTributariaToJson(
              instance.substituicaoTributaria)
          case final value?)
        'substituicaoTributaria': value,
      if (instance.telefone case final value?) 'telefone': value,
      if (instance.uf case final value?) 'uf': value,
    };
