import 'package:core/equals.dart';

class ConsultaVariacao extends Equatable {
  final int produtoId;
  final int corId;
  final String corNome;
  final int tamanhoId;
  final String tamanhoNome;
  final int? estampaId;
  final String? estampaNome;
  final int saldo;
  final bool bateFiltro;

  const ConsultaVariacao({
    required this.produtoId,
    required this.corId,
    required this.corNome,
    required this.tamanhoId,
    required this.tamanhoNome,
    this.estampaId,
    this.estampaNome,
    required this.saldo,
    required this.bateFiltro,
  });

  /// Estampa para exibição: liso quando não há estampa.
  String get estampaRotulo => estampaNome ?? 'Liso';

  String get descricao => '$corNome · $estampaRotulo · $tamanhoNome';

  @override
  List<Object?> get props => [
    produtoId, corId, corNome, tamanhoId, tamanhoNome, estampaId, estampaNome, saldo, bateFiltro,
  ];
}

class ConsultaReferenciaItem extends Equatable {
  final int referenciaId;
  final String? idExterno;
  final String nome;
  final String? capaUrl;
  final double? preco;
  final int saldoFiltrado;
  final List<ConsultaVariacao> variacoes;

  const ConsultaReferenciaItem({
    required this.referenciaId,
    this.idExterno,
    required this.nome,
    this.capaUrl,
    this.preco,
    required this.saldoFiltrado,
    required this.variacoes,
  });

  @override
  List<Object?> get props => [referenciaId, idExterno, nome, capaUrl, preco, saldoFiltrado, variacoes];
}

class ConsultaReferenciasPagina extends Equatable {
  final List<ConsultaReferenciaItem> items;
  final int? produtoIdLido;
  final int page;
  final int totalItems;
  final int totalPages;

  const ConsultaReferenciasPagina({
    required this.items,
    this.produtoIdLido,
    this.page = 1,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  @override
  List<Object?> get props => [items, produtoIdLido, page, totalItems, totalPages];
}
