enum ListaPersonalizadaSituacao { ativa, agendada, cancelada, expirada }

enum ListaTipo { provador, catalogo }

enum ListaModo { manual, filtro }

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
  final int? tabelaPrecoId;
  final DateTime? dataInicio;
  final DateTime? dataExpiracao;
  final ListaPersonalizadaSituacao situacao;
  final String? titulo;
  final String? descricao;
  final String? icone;
  final ListaTipo tipo;
  final ListaModo modo;
  final ListaFiltro? filtro;
  final List<ListaPersonalizadaItem> itens;

  const ListaPersonalizada({
    required this.id,
    required this.hash,
    this.tabelaPrecoId,
    this.dataInicio,
    this.dataExpiracao,
    required this.situacao,
    this.titulo,
    this.descricao,
    this.icone,
    this.tipo = ListaTipo.provador,
    this.modo = ListaModo.manual,
    this.filtro,
    this.itens = const [],
  });
}

enum EstoqueOperador { igual, ate, aPartir }

class ListaFiltroEstoque {
  final EstoqueOperador operador;
  final int quantidade;

  const ListaFiltroEstoque({required this.operador, required this.quantidade});

  @override
  bool operator ==(Object other) =>
      other is ListaFiltroEstoque &&
      other.operador == operador &&
      other.quantidade == quantidade;

  @override
  int get hashCode => Object.hash(operador, quantidade);
}

/// Filtro dinâmico da lista: AND entre campos, OR dentro de cada lista.
class ListaFiltro {
  final List<int> categoriaIds;
  final List<int> subCategoriaIds;
  final List<int> tamanhoIds;
  final List<int> corIds;
  final ListaFiltroEstoque? estoque;
  final List<int> promocaoIds;
  final bool apenasEmPromocao;

  const ListaFiltro({
    this.categoriaIds = const [],
    this.subCategoriaIds = const [],
    this.tamanhoIds = const [],
    this.corIds = const [],
    this.estoque,
    this.promocaoIds = const [],
    this.apenasEmPromocao = false,
  });

  bool get vazio =>
      categoriaIds.isEmpty &&
      subCategoriaIds.isEmpty &&
      tamanhoIds.isEmpty &&
      corIds.isEmpty &&
      estoque == null &&
      promocaoIds.isEmpty &&
      !apenasEmPromocao;
}

/// Dados de criação/edição de uma lista (campos nulos = "não definido").
class ListaPersonalizadaInput {
  final String? titulo;
  final String? descricao;
  final ListaTipo tipo;
  final ListaModo modo;
  final DateTime? dataInicio;
  final DateTime? dataExpiracao;
  final int? tabelaPrecoId;
  final ListaFiltro? filtro;
  final List<int> referenciaIds;

  const ListaPersonalizadaInput({
    this.titulo,
    this.descricao,
    this.tipo = ListaTipo.provador,
    this.modo = ListaModo.manual,
    this.dataInicio,
    this.dataExpiracao,
    this.tabelaPrecoId,
    this.filtro,
    this.referenciaIds = const [],
  });
}

/// Adição em lote de referências por categoria/subcategoria.
class ListaItensLote {
  final List<int> categoriaIds;
  final List<int> subCategoriaIds;
  final bool apenasPublicadasNoEcommerce;
  final String? search;

  const ListaItensLote({
    this.categoriaIds = const [],
    this.subCategoriaIds = const [],
    this.apenasPublicadasNoEcommerce = false,
    this.search,
  });
}

class ListaItensLoteResultado {
  final int adicionadas;
  final int total;

  const ListaItensLoteResultado({required this.adicionadas, required this.total});
}

class ListaPreviaItem {
  final int id;
  final String nome;
  final num? preco;
  final String? imagemUrl;

  const ListaPreviaItem({
    required this.id,
    required this.nome,
    this.preco,
    this.imagemUrl,
  });
}

class ListaPrevia {
  final List<ListaPreviaItem> items;
  final int totalItems;
  final int page;
  final int totalPages;

  const ListaPrevia({
    this.items = const [],
    this.totalItems = 0,
    this.page = 1,
    this.totalPages = 0,
  });
}
