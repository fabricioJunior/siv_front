import 'package:core/equals.dart';
import 'package:produtos/domain/models/referencia.dart';

/// Linha da lista de Referências: a referência e o nome da marca (a API só guarda o marcaId).
class ItemListaReferencia extends Equatable {
  final Referencia referencia;
  final String? marcaNome;

  const ItemListaReferencia({required this.referencia, this.marcaNome});

  @override
  List<Object?> get props => [referencia, marcaNome];
}

/// Categoria do resumo: `total` é quantas referências dela casam com a busca e as pendências atuais (pode ser 0).
class CategoriaDoResumo extends Equatable {
  final int id;
  final String nome;
  final int total;

  const CategoriaDoResumo({
    required this.id,
    required this.nome,
    required this.total,
  });

  @override
  List<Object?> get props => [id, nome, total];
}

/// Números dos chips, calculados no servidor. As pendências contam sobre busca + categoria; as categorias sobre
/// busca + pendências (cada chip ignora a si mesmo, para escolher um não zerar os outros).
class ResumoReferencias extends Equatable {
  final int semNcm;
  final int semPeso;
  final List<CategoriaDoResumo> categorias;

  const ResumoReferencias({
    this.semNcm = 0,
    this.semPeso = 0,
    this.categorias = const [],
  });

  @override
  List<Object?> get props => [semNcm, semPeso, categorias];
}

class ReferenciasBuscaResultado extends Equatable {
  final List<ItemListaReferencia> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final ResumoReferencias resumo;

  const ReferenciasBuscaResultado({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.resumo,
  });

  @override
  List<Object?> get props => [
    items,
    totalItems,
    totalPages,
    currentPage,
    resumo,
  ];
}
