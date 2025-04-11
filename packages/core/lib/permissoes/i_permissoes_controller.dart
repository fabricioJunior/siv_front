abstract class IPermissoesController {
  Future<bool> acessoPermitido({
    String? nomeDoComponente,
    int? idComponente,
    String? grupo,
  });
}
