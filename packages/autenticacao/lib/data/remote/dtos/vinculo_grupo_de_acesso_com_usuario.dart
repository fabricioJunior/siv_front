import 'package:autenticacao/data/remote/dtos/grupo_de_acesso_dto.dart';
import 'package:autenticacao/domain/models/empresa.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/models/vinculo_grupo_de_acesso_e_usuario.dart';

part 'vinculo_grupo_de_acesso_com_usuario.g.dart';

@JsonSerializable()
class VinculoGrupoDeAcessoComUsuarioDto
    implements VinculoGrupoDeAcessoEUsuario {
  final int grupoId;
  final int empresaId;
  final int usuarioId;

  final GrupoDeAcessoDto grupo;

  VinculoGrupoDeAcessoComUsuarioDto({
    required this.grupoId,
    required this.grupo,
    required this.empresaId,
    required this.usuarioId,
  });

  factory VinculoGrupoDeAcessoComUsuarioDto.fromJson(
          Map<String, dynamic> json) =>
      _$VinculoGrupoDeAcessoComUsuarioDtoFromJson(json);
  @override
  Empresa? get empresa => null;

  @override
  GrupoDeAcesso? get grupoDeAcesso => grupo;

  @override
  int? get idEmpresa => empresaId;

  @override
  int? get idUsuario => usuarioId;

  VinculoGrupoDeAcessoComUsuarioDto copyWith({
    int? grupoId,
    int? empresaId,
    int? usuarioId,
    GrupoDeAcessoDto? grupo,
    Empresa? empresa,
  }) {
    return VinculoGrupoDeAcessoComUsuarioDto(
      grupoId: grupoId ?? this.grupoId,
      empresaId: empresaId ?? this.empresaId,
      usuarioId: usuarioId ?? this.usuarioId,
      grupo: grupo ?? this.grupo,
    );
  }
}
