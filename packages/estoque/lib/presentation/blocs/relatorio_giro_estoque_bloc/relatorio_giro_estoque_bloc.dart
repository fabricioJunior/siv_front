import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/domain/usecases/get_relatorio_giro_estoque.dart';
import 'package:estoque/domain/usecases/get_resumo_giro_estoque.dart';
import 'package:estoque/domain/usecases/get_variacoes_giro_estoque.dart';
import 'package:estoque/presentation/relatorios/csv/estoque_relatorio_csv_exporter.dart';
import 'package:estoque/presentation/relatorios/pdf/estoque_relatorio_pdf_exporter.dart';

part 'relatorio_giro_estoque_event.dart';
part 'relatorio_giro_estoque_state.dart';

/// Ordem padrão de cada aba (trocar de aba restaura).
(String, String) ordenacaoPadraoGiro(AbaGiro aba) => switch (aba) {
      AbaGiro.ranking => ('score', 'desc'),
      AbaGiro.reposicao => ('diasParaEsgotar', 'asc'),
      AbaGiro.parado => ('valorParado', 'desc'),
    };

const _ascPrimeiro = {'nome', 'dataEntrada', 'diasParaEsgotar', 'classificacao'};

class RelatorioGiroEstoqueBloc
    extends Bloc<RelatorioGiroEstoqueEvent, RelatorioGiroEstoqueState> {
  final GetRelatorioGiroEstoque _lista;
  final GetResumoGiroEstoque _resumo;
  final GetVariacoesGiroEstoque _variacoes;

  static const limitePagina = 20;
  static const limiteExportacao = 500;

  RelatorioGiroEstoqueBloc(this._lista, this._resumo, this._variacoes)
      : super(const RelatorioGiroEstoqueState()) {
    on<GiroEstoqueIniciou>((e, emit) => _recarregarTudo(emit, state),
        transformer: restartable());
    on<GiroPeriodoAlterado>(_onPeriodo, transformer: restartable());
    on<GiroFiltroAlterado>(
      (e, emit) => _aplicarFiltro(emit, e.filtro),
      transformer: restartable(),
    );
    on<GiroVisaoAlterada>(
      (e, emit) => _aplicarFiltro(
        emit,
        state.filtro.copyWith(visualizacao: e.visualizacao),
      ),
      transformer: restartable(),
    );
    on<GiroClassificacaoSelecionada>(_onClassificacao, transformer: restartable());
    on<GiroClassificacaoLimpa>(
      (e, emit) => _soLista(
        emit,
        state.copyWith(
          filtro: state.filtro.copyWith(classificacoes: const {}),
          page: 1,
        ),
      ),
      transformer: restartable(),
    );
    on<GiroAbaAlterada>(_onAba, transformer: restartable());
    on<GiroOrdenacaoAlterada>(_onOrdenacao, transformer: restartable());
    on<GiroPaginaAlterada>(
      (e, emit) => _soLista(emit, state.copyWith(page: e.page)),
      transformer: restartable(),
    );
    on<GiroLinhaExpandida>(_onExpandida);
    on<GiroCriteriosAlternados>(
      (e, emit) =>
          emit(state.copyWith(criteriosAbertos: !state.criteriosAbertos)),
    );
    on<GiroExportarSolicitado>(_onExportar, transformer: droppable());
  }

  List<int>? get _empresaIds {
    final id = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    return id == null ? null : [id];
  }

  /// Mudança de filtro/período/visão: recarrega resumo + página 1 e zera o
  /// cache de variações.
  Future<void> _aplicarFiltro(
    Emitter<RelatorioGiroEstoqueState> emit,
    FiltroGiroEstoque filtro,
  ) => _recarregarTudo(
        emit,
        state.copyWith(
          filtro: filtro,
          page: 1,
          variacoes: const {},
          abertos: const {},
        ),
      );

  Future<void> _onPeriodo(
    GiroPeriodoAlterado e,
    Emitter<RelatorioGiroEstoqueState> emit,
  ) => _aplicarFiltro(
        emit,
        state.filtro.copyWith(
          periodo: e.periodo,
          dataInicio: e.dataInicio,
          dataFim: e.dataFim,
        ),
      );

  Future<void> _onClassificacao(
    GiroClassificacaoSelecionada e,
    Emitter<RelatorioGiroEstoqueState> emit,
  ) {
    final ativa = state.filtro.classificacoes;
    final nova = ativa.length == 1 && ativa.contains(e.classificacao)
        ? <ClassificacaoGiro>{}
        : {e.classificacao};
    final (ord, dir) = ordenacaoPadraoGiro(AbaGiro.ranking);
    // O resumo ignora a classificação: só a lista recarrega.
    return _soLista(
      emit,
      state.copyWith(
        filtro: state.filtro.copyWith(classificacoes: nova),
        aba: AbaGiro.ranking,
        ordenarPor: ord,
        ordem: dir,
        page: 1,
      ),
    );
  }

  Future<void> _onAba(
    GiroAbaAlterada e,
    Emitter<RelatorioGiroEstoqueState> emit,
  ) {
    final (ord, dir) = ordenacaoPadraoGiro(e.aba);
    return _soLista(
      emit,
      state.copyWith(aba: e.aba, ordenarPor: ord, ordem: dir, page: 1),
    );
  }

  Future<void> _onOrdenacao(
    GiroOrdenacaoAlterada e,
    Emitter<RelatorioGiroEstoqueState> emit,
  ) {
    final mesma = e.coluna == state.ordenarPor;
    final ordem = mesma
        ? (state.ordem == 'asc' ? 'desc' : 'asc')
        : (_ascPrimeiro.contains(e.coluna) ? 'asc' : 'desc');
    return _soLista(
      emit,
      state.copyWith(ordenarPor: e.coluna, ordem: ordem, page: 1),
    );
  }

  Future<void> _recarregarTudo(
    Emitter<RelatorioGiroEstoqueState> emit,
    RelatorioGiroEstoqueState base,
  ) async {
    emit(base.copyWith(
      listaStep: GiroSecaoStep.carregando,
      resumoStep: GiroSecaoStep.carregando,
    ));
    await Future.wait([_buscarLista(emit), _buscarResumo(emit)]);
  }

  Future<void> _soLista(
    Emitter<RelatorioGiroEstoqueState> emit,
    RelatorioGiroEstoqueState base,
  ) async {
    emit(base.copyWith(listaStep: GiroSecaoStep.carregando));
    await _buscarLista(emit);
  }

  Future<void> _buscarLista(Emitter<RelatorioGiroEstoqueState> emit) async {
    final empresas = _empresaIds;
    if (empresas == null) return;
    final s = state;
    try {
      final pagina = await _lista(
        empresaIds: empresas,
        filtro: s.filtro,
        aba: s.aba,
        ordenarPor: s.ordenarPor,
        ordem: s.ordem,
        page: s.page,
        limit: limitePagina,
      );
      emit(state.copyWith(listaStep: GiroSecaoStep.sucesso, pagina: pagina));
    } catch (e, st) {
      emit(state.copyWith(listaStep: GiroSecaoStep.falha));
      addError(e, st);
    }
  }

  Future<void> _buscarResumo(Emitter<RelatorioGiroEstoqueState> emit) async {
    final empresas = _empresaIds;
    if (empresas == null) return;
    try {
      final resumo = await _resumo(empresaIds: empresas, filtro: state.filtro);
      emit(state.copyWith(resumoStep: GiroSecaoStep.sucesso, resumo: resumo));
    } catch (e, st) {
      emit(state.copyWith(resumoStep: GiroSecaoStep.falha));
      addError(e, st);
    }
  }

  Future<void> _onExpandida(
    GiroLinhaExpandida e,
    Emitter<RelatorioGiroEstoqueState> emit,
  ) async {
    final id = e.referenciaId;
    if (state.abertos.contains(id)) {
      emit(state.copyWith(abertos: {...state.abertos}..remove(id)));
      return;
    }
    emit(state.copyWith(abertos: {...state.abertos, id}));
    final empresas = _empresaIds;
    if (empresas == null ||
        state.variacoes.containsKey(id) ||
        state.carregandoVariacoes.contains(id)) {
      return;
    }
    emit(state.copyWith(carregandoVariacoes: {...state.carregandoVariacoes, id}));
    try {
      final v = await _variacoes(
        referenciaId: id,
        empresaIds: empresas,
        filtro: state.filtro,
      );
      emit(state.copyWith(
        variacoes: {...state.variacoes, id: v},
        carregandoVariacoes: {...state.carregandoVariacoes}..remove(id),
      ));
    } catch (err, st) {
      emit(state.copyWith(
        abertos: {...state.abertos}..remove(id),
        carregandoVariacoes: {...state.carregandoVariacoes}..remove(id),
      ));
      addError(err, st);
    }
  }

  /// Exporta a aba ativa, com filtros e ordenação, percorrendo todas as páginas.
  Future<void> _onExportar(
    GiroExportarSolicitado e,
    Emitter<RelatorioGiroEstoqueState> emit,
  ) async {
    final empresas = _empresaIds;
    if (empresas == null) return;
    final s = state;
    emit(s.copyWith(exportando: true));
    try {
      final linhas = <GiroEstoqueLinha>[];
      var page = 1;
      while (true) {
        final p = await _lista(
          empresaIds: empresas,
          filtro: s.filtro,
          aba: s.aba,
          ordenarPor: s.ordenarPor,
          ordem: s.ordem,
          page: page,
          limit: limiteExportacao,
        );
        linhas.addAll(p.items);
        if (page >= p.meta.totalPages || p.items.isEmpty) break;
        page++;
      }
      switch (e.formato) {
        case FormatoExportacaoGiro.csv:
          await EstoqueRelatorioCsvExporter.exportarGiro(
              linhas: linhas, aba: s.aba, filtro: s.filtro);
        case FormatoExportacaoGiro.pdf:
          await EstoqueRelatorioPdfExporter.exportarGiro(
              linhas: linhas, aba: s.aba, filtro: s.filtro);
      }
      emit(state.copyWith(exportando: false));
    } catch (err, st) {
      emit(state.copyWith(
        exportando: false,
        erroExportacao: 'Falha ao exportar o relatório.',
      ));
      addError(err, st);
    }
  }
}
