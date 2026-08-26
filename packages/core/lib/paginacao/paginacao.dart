class Paginacao<E> {
  final String key;
  final int paginaAtual;
  final int totalPaginas;
  final int itensPorPagina;
  final int itensProcessadosNaPagina;
  final int totalItens;
  final DateTime? dataAtualizacao;
  final bool ended;
  final List<E>? items;

  Paginacao({
    required this.paginaAtual,
    required this.totalPaginas,
    required this.itensPorPagina,
    this.itensProcessadosNaPagina = 0,
    required this.totalItens,
    required this.key,
    required this.dataAtualizacao,
    this.ended = false,
    this.items,
  });

  Paginacao copyWith({
    String? key,
    int? paginaAtual,
    int? totalPaginas,
    int? itensPorPagina,
    int? itensProcessadosNaPagina,
    int? totalItens,
    DateTime? dataAtualizacao,
    bool? ended,
  }) {
    return Paginacao(
      key: key ?? this.key,
      paginaAtual: paginaAtual ?? this.paginaAtual,
      totalPaginas: totalPaginas ?? this.totalPaginas,
      itensPorPagina: itensPorPagina ?? this.itensPorPagina,
      itensProcessadosNaPagina:
          itensProcessadosNaPagina ?? this.itensProcessadosNaPagina,
      totalItens: totalItens ?? this.totalItens,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      ended: ended ?? this.ended,
    );
  }
}
