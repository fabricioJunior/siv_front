import 'package:autenticacao/domain/models/permissao_do_usuario.dart';

class PermissaoDoUsuarioDto implements PermissaoDoUsuario {
  @override
  final int id;

  @override
  final int empresaId;

  @override
  final int grupoId;

  @override
  final String grupoNome;

  @override
  final String componenteId;

  @override
  final String componenteNome;

  @override
  final int descontinuado;

  const PermissaoDoUsuarioDto({
    required this.id,
    required this.empresaId,
    required this.grupoId,
    required this.grupoNome,
    required this.componenteId,
    required this.componenteNome,
    required this.descontinuado,
  });

  factory PermissaoDoUsuarioDto.fromJson(Map<String, dynamic> json) {
    return PermissaoDoUsuarioDto(
      id: (json['id'] as num).toInt(),
      empresaId: (json['empresaId'] as num).toInt(),
      grupoId: (json['grupoId'] as num).toInt(),
      grupoNome: json['grupoNome'] as String,
      componenteId: json['componenteId'] as String,
      componenteNome: json['componenteNome'] as String,
      descontinuado: (json['descontinuado'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresaId': empresaId,
      'grupoId': grupoId,
      'grupoNome': grupoNome,
      'componenteId': componenteId,
      'componenteNome': componenteNome,
      'descontinuado': descontinuado,
    };
  }

  @override
  bool get estaDescontinuado => descontinuado == 1;

  @override
  List<Object?> get props => [
        id,
        empresaId,
        grupoId,
        grupoNome,
        componenteId,
        componenteNome,
        descontinuado,
      ];

  @override
  bool? get stringify => true;
}
