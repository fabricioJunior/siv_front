part of 'relatorio_giro_estoque_bloc.dart';

enum GiroSecaoStep { inicial, carregando, sucesso, falha }

class RelatorioGiroEstoqueState {
  final FiltroGiroEstoque filtro;
  final AbaGiro aba;
  final String ordenarPor;
  final String ordem;
  final int page;
  final GiroEstoqueResumo? resumo;
  final PaginaGiroEstoque? pagina;
  final Map<int, GiroEstoqueVariacoes> variacoes;
  final Set<int> abertos;
  final Set<int> carregandoVariacoes;
  final GiroSecaoStep resumoStep;
  final GiroSecaoStep listaStep;
  final bool criteriosAbertos;
  final bool exportando;
  final String? erroExportacao;

  const RelatorioGiroEstoqueState({
    this.filtro = const FiltroGiroEstoque(),
    this.aba = AbaGiro.ranking,
    this.ordenarPor = 'score',
    this.ordem = 'desc',
    this.page = 1,
    this.resumo,
    this.pagina,
    this.variacoes = const {},
    this.abertos = const {},
    this.carregandoVariacoes = const {},
    this.resumoStep = GiroSecaoStep.inicial,
    this.listaStep = GiroSecaoStep.inicial,
    this.criteriosAbertos = false,
    this.exportando = false,
    this.erroExportacao,
  });

  RelatorioGiroEstoqueState copyWith({
    FiltroGiroEstoque? filtro,
    AbaGiro? aba,
    String? ordenarPor,
    String? ordem,
    int? page,
    GiroEstoqueResumo? resumo,
    PaginaGiroEstoque? pagina,
    Map<int, GiroEstoqueVariacoes>? variacoes,
    Set<int>? abertos,
    Set<int>? carregandoVariacoes,
    GiroSecaoStep? resumoStep,
    GiroSecaoStep? listaStep,
    bool? criteriosAbertos,
    bool? exportando,
    String? erroExportacao,
  }) =>
      RelatorioGiroEstoqueState(
        filtro: filtro ?? this.filtro,
        aba: aba ?? this.aba,
        ordenarPor: ordenarPor ?? this.ordenarPor,
        ordem: ordem ?? this.ordem,
        page: page ?? this.page,
        resumo: resumo ?? this.resumo,
        pagina: pagina ?? this.pagina,
        variacoes: variacoes ?? this.variacoes,
        abertos: abertos ?? this.abertos,
        carregandoVariacoes: carregandoVariacoes ?? this.carregandoVariacoes,
        resumoStep: resumoStep ?? this.resumoStep,
        listaStep: listaStep ?? this.listaStep,
        criteriosAbertos: criteriosAbertos ?? this.criteriosAbertos,
        exportando: exportando ?? this.exportando,
        erroExportacao: erroExportacao,
      );
}
