/// Situação de uma linha no modo conferência do `LeitorWidget`.
enum SituacaoEsperado { pendente, parcial, conferido, excedente }

/// Produto esperado numa conferência (modo conferência do `LeitorWidget`).
/// [esperado] = quantidade contada; [lido] = quantidade já lida/atendida
/// (autoridade do chamador: ele atualiza a lista a cada leitura confirmada).
class ProdutoEsperado {
  final int id;
  final String codigoDeBarras;
  final String descricao;
  final int idReferencia;
  final String cor;
  final String tamanho;
  final int esperado;
  final int lido;

  const ProdutoEsperado({
    required this.id,
    required this.codigoDeBarras,
    required this.descricao,
    this.idReferencia = 0,
    this.cor = '',
    this.tamanho = '',
    required this.esperado,
    this.lido = 0,
  });

  SituacaoEsperado get situacao {
    if (lido <= 0) return SituacaoEsperado.pendente;
    if (lido < esperado) return SituacaoEsperado.parcial;
    if (lido == esperado) return SituacaoEsperado.conferido;
    return SituacaoEsperado.excedente;
  }

  String get grade => [cor, tamanho].where((e) => e.isNotEmpty).join(' · ');
}
