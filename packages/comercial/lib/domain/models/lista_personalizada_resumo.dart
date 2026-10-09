import 'package:comercial/domain/models/lista_personalizada.dart';

class ListaPersonalizadaResumo {
  final int id;
  final String hash;
  final ListaPersonalizadaSituacao situacao;
  final DateTime? dataExpiracao;
  final int quantidadeItens;
  final DateTime criadoEm;
  final String? titulo;
  final String? icone;
  final ListaTipo tipo;
  final ListaModo modo;

  const ListaPersonalizadaResumo({
    required this.id,
    required this.hash,
    required this.situacao,
    this.dataExpiracao,
    required this.quantidadeItens,
    required this.criadoEm,
    this.titulo,
    this.icone,
    this.tipo = ListaTipo.provador,
    this.modo = ListaModo.manual,
  });
}

class MetaListasPersonalizadas {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const MetaListasPersonalizadas({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });
}

class PaginaListasPersonalizadas {
  final MetaListasPersonalizadas meta;
  final List<ListaPersonalizadaResumo> items;

  const PaginaListasPersonalizadas({required this.meta, required this.items});
}
