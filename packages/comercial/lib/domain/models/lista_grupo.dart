class ListaGrupoLista {
  final int listaId;
  final String nome;
  final String? icone;
  final int ordem;

  const ListaGrupoLista({
    required this.listaId,
    required this.nome,
    this.icone,
    this.ordem = 0,
  });
}

class ListaGrupo {
  final int id;
  final String nome;
  final String? descricao;
  final String? icone;
  final bool ativo;
  final List<ListaGrupoLista> listas;

  const ListaGrupo({
    required this.id,
    required this.nome,
    this.descricao,
    this.icone,
    this.ativo = true,
    this.listas = const [],
  });
}

class PaginaListasGrupos {
  final List<ListaGrupo> items;
  final int totalPages;

  const PaginaListasGrupos({this.items = const [], this.totalPages = 1});
}
