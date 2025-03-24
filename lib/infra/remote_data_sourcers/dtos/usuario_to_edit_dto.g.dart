// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_to_edit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsarioToEditDto _$UsarioToEditDtoFromJson(Map<String, dynamic> json) =>
    UsarioToEditDto(
      id: (json['id'] as num?)?.toInt(),
      login: json['usuario'] as String?,
      nome: json['nome'] as String,
      tipo: UsarioToEditDto._tipoUsuarioFromJson(json['tipo'] as String),
      situacao: json['situacao'] as String,
      senha: json['senha'] as String?,
    );

Map<String, dynamic> _$UsarioToEditDtoToJson(UsarioToEditDto instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('usuario', instance.login);
  val['nome'] = instance.nome;
  val['tipo'] = UsarioToEditDto._tipoUsuarioToJson(instance.tipo);
  writeNotNull('senha', instance.senha);
  val['situacao'] = instance.situacao;
  return val;
}
