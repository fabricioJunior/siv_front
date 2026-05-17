abstract class IAcessoGlobalSessao {
  int? get usuarioIdDaSessao;
  int? get empresaIdDaSessao;
  int? get terminalIdDaSessao;
  String? get terminalNomeDaSessao;
  int? get caixaIdDaSessao;
  bool get dadosSincronizados;
  Stream<bool> get sincronizandoDados;

  void atualizarCaixaIdDaSessao({required int terminalId, int? caixaId});
}
