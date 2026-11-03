part of 'consultar_produto_bloc.dart';

/// Resultado da última leitura de código de barras.
class LeituraCodigo extends Equatable {
  final String codigo;
  final bool encontrada;
  final int? referenciaId;
  final int? produtoId;
  final String descricao;
  final int saldo;

  const LeituraCodigo({
    required this.codigo,
    required this.encontrada,
    this.referenciaId,
    this.produtoId,
    this.descricao = '',
    this.saldo = 0,
  });

  @override
  List<Object?> get props => [codigo, encontrada, referenciaId, produtoId, descricao, saldo];
}

class ConsultarProdutoState extends Equatable {
  final String busca;
  final List<Cor> cores;
  final List<Tamanho> tamanhos;
  final List<Estampa> estampas;
  final List<SelectData> tabelaDePreco;
  final List<ConsultaReferenciaItem> itens;
  final int pagina;
  final int totalPaginas;
  final bool carregando;
  final bool carregandoMais;
  final String? erro;
  final int? referenciaAbertaId;
  final GradeDaReferencia? grade;
  final bool carregandoGrade;
  final String? erroGrade;
  final int? produtoIdLido;
  final LeituraCodigo? leitura;

  const ConsultarProdutoState({
    this.busca = '',
    this.cores = const [],
    this.tamanhos = const [],
    this.estampas = const [],
    this.tabelaDePreco = const [],
    this.itens = const [],
    this.pagina = 1,
    this.totalPaginas = 1,
    this.carregando = false,
    this.carregandoMais = false,
    this.erro,
    this.referenciaAbertaId,
    this.grade,
    this.carregandoGrade = false,
    this.erroGrade,
    this.produtoIdLido,
    this.leitura,
  });

  int? get tabelaDePrecoId => tabelaDePreco.firstOrNull?.id;
  List<int> get corIds => [for (final c in cores) ?c.id];
  List<int> get tamanhoIds => [for (final t in tamanhos) ?t.id];
  List<int> get estampaIds => [for (final e in estampas) ?e.id];
  bool get temFiltro => cores.isNotEmpty || tamanhos.isNotEmpty || estampas.isNotEmpty;
  bool get buscaValida => busca.trim().length >= 2 || temFiltro;
  bool get temMais => pagina < totalPaginas;

  ConsultarProdutoState copyWith({
    String? busca,
    List<Cor>? cores,
    List<Tamanho>? tamanhos,
    List<Estampa>? estampas,
    List<SelectData>? tabelaDePreco,
    List<ConsultaReferenciaItem>? itens,
    int? pagina,
    int? totalPaginas,
    bool? carregando,
    bool? carregandoMais,
    String? Function()? erro,
    int? Function()? referenciaAbertaId,
    GradeDaReferencia? Function()? grade,
    bool? carregandoGrade,
    String? Function()? erroGrade,
    int? Function()? produtoIdLido,
    LeituraCodigo? Function()? leitura,
  }) {
    return ConsultarProdutoState(
      busca: busca ?? this.busca,
      cores: cores ?? this.cores,
      tamanhos: tamanhos ?? this.tamanhos,
      estampas: estampas ?? this.estampas,
      tabelaDePreco: tabelaDePreco ?? this.tabelaDePreco,
      itens: itens ?? this.itens,
      pagina: pagina ?? this.pagina,
      totalPaginas: totalPaginas ?? this.totalPaginas,
      carregando: carregando ?? this.carregando,
      carregandoMais: carregandoMais ?? this.carregandoMais,
      erro: erro != null ? erro() : this.erro,
      referenciaAbertaId: referenciaAbertaId != null ? referenciaAbertaId() : this.referenciaAbertaId,
      grade: grade != null ? grade() : this.grade,
      carregandoGrade: carregandoGrade ?? this.carregandoGrade,
      erroGrade: erroGrade != null ? erroGrade() : this.erroGrade,
      produtoIdLido: produtoIdLido != null ? produtoIdLido() : this.produtoIdLido,
      leitura: leitura != null ? leitura() : this.leitura,
    );
  }

  @override
  List<Object?> get props => [
    busca, cores, tamanhos, estampas, tabelaDePreco, itens, pagina, totalPaginas, carregando,
    carregandoMais, erro, referenciaAbertaId, grade, carregandoGrade, erroGrade, produtoIdLido, leitura,
  ];
}
