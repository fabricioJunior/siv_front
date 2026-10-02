part of 'referencias_lista_bloc.dart';

enum ReferenciasListaEtapa { carregando, carregado, falha }

class ReferenciasListaState extends Equatable {
  final ReferenciasListaEtapa etapa;
  final ReferenciasFiltro filtro;
  final ReferenciasOrdenacao ordenacao;
  final List<ItemListaReferencia> itens;
  final int totalItens;
  final int paginaAtual;
  final int totalPaginas;
  final ResumoReferencias resumo;

  /// Nova busca em andamento com a lista anterior ainda na tela (evita piscar a cada letra digitada).
  final bool atualizando;
  final bool carregandoMais;

  const ReferenciasListaState({
    this.etapa = ReferenciasListaEtapa.carregando,
    this.filtro = const ReferenciasFiltro(),
    this.ordenacao = ReferenciasOrdenacao.nomeAsc,
    this.itens = const [],
    this.totalItens = 0,
    this.paginaAtual = 0,
    this.totalPaginas = 0,
    this.resumo = const ResumoReferencias(),
    this.atualizando = false,
    this.carregandoMais = false,
  });

  bool get temMais => paginaAtual < totalPaginas;

  ReferenciasListaState copyWith({
    ReferenciasListaEtapa? etapa,
    ReferenciasFiltro? filtro,
    ReferenciasOrdenacao? ordenacao,
    List<ItemListaReferencia>? itens,
    int? totalItens,
    int? paginaAtual,
    int? totalPaginas,
    ResumoReferencias? resumo,
    bool? atualizando,
    bool? carregandoMais,
  }) {
    return ReferenciasListaState(
      etapa: etapa ?? this.etapa,
      filtro: filtro ?? this.filtro,
      ordenacao: ordenacao ?? this.ordenacao,
      itens: itens ?? this.itens,
      totalItens: totalItens ?? this.totalItens,
      paginaAtual: paginaAtual ?? this.paginaAtual,
      totalPaginas: totalPaginas ?? this.totalPaginas,
      resumo: resumo ?? this.resumo,
      atualizando: atualizando ?? this.atualizando,
      carregandoMais: carregandoMais ?? this.carregandoMais,
    );
  }

  @override
  List<Object?> get props => [
    etapa,
    filtro,
    ordenacao,
    itens,
    totalItens,
    paginaAtual,
    totalPaginas,
    resumo,
    atualizando,
    carregandoMais,
  ];
}
