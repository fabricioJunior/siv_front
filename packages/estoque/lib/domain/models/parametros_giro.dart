/// Parâmetros de classificação do giro (§3 do handoff). Vêm do backend em
/// `/giro/resumo`; a tela monta o texto de "Critérios" a partir deles.
class ParametrosGiro {
  final double excepcionalPctMin;
  final double excepcionalDiasMax;
  final double rapidoPctMin;
  final double rapidoDiasMax;
  final double paradoDiasMin;
  final double paradoPctMax;
  final double lentoDiasMin;
  final double lentoPctMax;
  final double reposicaoEsgotaEmAte;
  final double reposicaoCoberturaDias;
  final double reposicaoLimiteLotes;

  const ParametrosGiro({
    this.excepcionalPctMin = 80,
    this.excepcionalDiasMax = 3,
    this.rapidoPctMin = 70,
    this.rapidoDiasMax = 7,
    this.paradoDiasMin = 30,
    this.paradoPctMax = 15,
    this.lentoDiasMin = 14,
    this.lentoPctMax = 40,
    this.reposicaoEsgotaEmAte = 7,
    this.reposicaoCoberturaDias = 14,
    this.reposicaoLimiteLotes = 2,
  });

  factory ParametrosGiro.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const ParametrosGiro();
    const d = ParametrosGiro();
    double n(String grupo, String campo, double padrao) =>
        ((j[grupo] as Map<String, dynamic>?)?[campo] as num?)?.toDouble() ??
        padrao;
    return ParametrosGiro(
      excepcionalPctMin: n('excepcional', 'pctMin', d.excepcionalPctMin),
      excepcionalDiasMax: n('excepcional', 'diasMax', d.excepcionalDiasMax),
      rapidoPctMin: n('rapido', 'pctMin', d.rapidoPctMin),
      rapidoDiasMax: n('rapido', 'diasMax', d.rapidoDiasMax),
      paradoDiasMin: n('parado', 'diasMin', d.paradoDiasMin),
      paradoPctMax: n('parado', 'pctMax', d.paradoPctMax),
      lentoDiasMin: n('lento', 'diasMin', d.lentoDiasMin),
      lentoPctMax: n('lento', 'pctMax', d.lentoPctMax),
      reposicaoEsgotaEmAte: n('reposicao', 'esgotaEmAte', d.reposicaoEsgotaEmAte),
      reposicaoCoberturaDias:
          n('reposicao', 'coberturaDias', d.reposicaoCoberturaDias),
      reposicaoLimiteLotes: n('reposicao', 'limiteLotes', d.reposicaoLimiteLotes),
    );
  }
}
