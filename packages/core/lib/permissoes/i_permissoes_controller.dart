abstract class IPermissoesController {
  Future<bool> acessoPermitido({
    String? idComponente,
    int? grupoId,
  });

  bool temAcesso({
    String? idComponente,
    int? grupoId,
  });
}
