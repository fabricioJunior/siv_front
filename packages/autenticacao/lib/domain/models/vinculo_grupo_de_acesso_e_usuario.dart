import 'package:autenticacao/data/remote/dtos/grupo_de_acesso_dto.dart';
import 'package:autenticacao/data/remote/dtos/vinculo_grupo_de_acesso_com_usuario.dart';
import 'package:autenticacao/domain/models/empresa.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';

abstract class VinculoGrupoDeAcessoEUsuario {
  int? get idUsuario;
  int? get idEmpresa;
  Empresa? get empresa;
  GrupoDeAcesso? get grupoDeAcesso;
}

extension VinculoGrupoDeAcessoEUsuarioCopyWith on VinculoGrupoDeAcessoEUsuario {
  VinculoGrupoDeAcessoEUsuario copyWith({
    int? idUsuario,
    int? idEmpresa,
    Empresa? empresa,
    GrupoDeAcesso? grupoDeAcesso,
  }) {
    // Import the DTO to create a new instance
    final grupoFinal =
        (grupoDeAcesso ?? this.grupoDeAcesso) as GrupoDeAcessoDto?;
    if (grupoFinal == null) {
      throw ArgumentError('grupoDeAcesso cannot be null');
    }

    return VinculoGrupoDeAcessoComUsuarioDto(
      grupoId: grupoFinal.id ?? 0,
      empresaId: (idEmpresa ?? this.idEmpresa) ?? 0,
      usuarioId: (idUsuario ?? this.idUsuario) ?? 0,
      grupo: grupoFinal,
    );
  }
}
