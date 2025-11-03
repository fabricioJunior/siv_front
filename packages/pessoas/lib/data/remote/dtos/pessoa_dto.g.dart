// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pessoa_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PessoaDto _$PessoaDtoFromJson(Map<String, dynamic> json) => PessoaDto(
      bloqueado: json['bloqueado'] as bool,
      contato: json['contato'] as String,
      documento: json['documento'] as String,
      eCliente: json['cliente'] as bool,
      eFornecedor: json['fornecedor'] as bool,
      eFuncionario: json['funcionario'] as bool,
      email: json['email'] as String,
      id: (json['id'] as num?)?.toInt(),
      inscricaoEstadual: json['inscricaoEstadual'] as String?,
      nome: json['nome'] as String,
      tipoPessoa: tipoPessoaFromJson(json['tipo']),
      tipoContato: tipoContatoFromJson(json['tipoContato']),
      uf: json['ufInscricaoEstadual'] as String,
      nascimento: json['nascimento'] == null
          ? null
          : DateTime.parse(json['nascimento'] as String),
    )..dataDeNascimento = json['dataDeNascimento'] == null
        ? null
        : DateTime.parse(json['dataDeNascimento'] as String);

Map<String, dynamic> _$PessoaDtoToJson(PessoaDto instance) => <String, dynamic>{
      'dataDeNascimento': instance.dataDeNascimento?.toIso8601String(),
      'bloqueado': instance.bloqueado,
      'contato': instance.contato,
      'documento': instance.documento,
      'cliente': instance.eCliente,
      'fornecedor': instance.eFornecedor,
      'funcionario': instance.eFuncionario,
      'email': instance.email,
      'id': instance.id,
      'inscricaoEstadual': instance.inscricaoEstadual,
      'nome': instance.nome,
      'tipo': tipoPessoaToJson(instance.tipoPessoa),
      'tipoContato': tipoContatoToJson(instance.tipoContato),
      'ufInscricaoEstadual': instance.uf,
      'nascimento': instance.nascimento?.toIso8601String(),
    };
