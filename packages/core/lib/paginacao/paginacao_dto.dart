import 'package:core/paginacao/paginacao.dart';

class PaginacaoDto<Dto> extends Paginacao<Dto> {
  final Meta meta;

  PaginacaoDto({
    super.items,
    required this.meta,
    required super.paginaAtual,
    required super.totalPaginas,
    required super.itensPorPagina,
    super.itensProcessadosNaPagina,
    required super.totalItens,
    required super.key,
    required super.dataAtualizacao,
  });

  factory PaginacaoDto.fromJson(
    Map<String, dynamic> json,
    Dto Function(Map<String, dynamic>) fromJsonDto,
    String key,
  ) {
    var meta = Meta.fromJson(json['meta']);
    var items =
        (json['items'] as List).map((item) => fromJsonDto(item)).toList();
    return PaginacaoDto(
      items: items,
      meta: meta,
      paginaAtual: meta.currentPage,
      totalPaginas: meta.totalPages,
      itensPorPagina: meta.itemsPerPage,
      itensProcessadosNaPagina: items.length,
      totalItens: meta.totalItems,
      key: key,
      dataAtualizacao: json['dataAtualizacao'] == null
          ? null
          : DateTime.parse(json['dataAtualizacao']),
    );
  }
}

class Meta {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  Meta(
      {required this.totalItems,
      required this.itemCount,
      required this.itemsPerPage,
      required this.totalPages,
      required this.currentPage});

  Meta.fromJson(Map<String, dynamic> json)
      : totalItems = json['totalItems'],
        itemCount = json['itemCount'],
        itemsPerPage = json['itemsPerPage'],
        totalPages = json['totalPages'],
        currentPage = json['currentPage'];
}
