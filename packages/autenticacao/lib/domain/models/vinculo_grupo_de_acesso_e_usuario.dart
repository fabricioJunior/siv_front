import 'package:autenticacao/domain/models/empresa.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';

mixin VinculoGrupoDeAcessoEUsuario {
  int? get idUsuario;
  int? get idEmpresa;
  Empresa? get empresa;
  GrupoDeAcesso? get grupoDeAcesso;

  VinculoGrupoDeAcessoEUsuario copyWith({
    int? idUsuario,
    int? idEmpresa,
    Empresa? empresa,
    GrupoDeAcesso? grupoDeAcesso,
  }) {
    return _VinculoGrupoDeAcessoEUsuarioImpl(
      idUsuario: idUsuario ?? this.idUsuario,
      empresa: empresa ?? this.empresa,
      grupoDeAcesso: grupoDeAcesso ?? this.grupoDeAcesso,
    );
  }

  static VinculoGrupoDeAcessoEUsuario instance({
    int? idUsuario,
    int? idEmpresa,
    Empresa? empresa,
    GrupoDeAcesso? grupoDeAcesso,
  }) =>
      _VinculoGrupoDeAcessoEUsuarioImpl(
        idUsuario: idUsuario,
        empresa: empresa,
        grupoDeAcesso: grupoDeAcesso,
      );
}

class _VinculoGrupoDeAcessoEUsuarioImpl with VinculoGrupoDeAcessoEUsuario {
  @override
  final Empresa? empresa;

  @override
  final GrupoDeAcesso? grupoDeAcesso;

  _VinculoGrupoDeAcessoEUsuarioImpl({
    required this.idUsuario,
    required this.empresa,
    required this.grupoDeAcesso,
  });

  @override
  int? get idEmpresa => empresa?.id;

  @override
  final int? idUsuario;
}
