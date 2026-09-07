enum ListaPersonalizadaSituacao { ativa, cancelada, expirada }

class ListaPersonalizadaItem {
  final int referenciaId;
  final String nome;
  final num valor;
  final String? imagemUrl;

  const ListaPersonalizadaItem({
    required this.referenciaId,
    required this.nome,
    required this.valor,
    this.imagemUrl,
  });
}

class ListaPersonalizada {
  final int id;
  final String hash;
  final int tabelaPrecoId;
  final DateTime dataExpiracao;
  final ListaPersonalizadaSituacao situacao;
  final List<ListaPersonalizadaItem> itens;

  const ListaPersonalizada({
    required this.id,
    required this.hash,
    required this.tabelaPrecoId,
    required this.dataExpiracao,
    required this.situacao,
    this.itens = const [],
  });
}
