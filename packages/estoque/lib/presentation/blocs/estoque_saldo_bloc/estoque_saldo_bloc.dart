import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';
import 'package:estoque/domain/models/saldo_do_estoque.dart';
import 'package:estoque/use_cases.dart';

part 'estoque_saldo_event.dart';
part 'estoque_saldo_state.dart';

class EstoqueSaldoBloc extends Bloc<EstoqueSaldoEvent, EstoqueSaldoState> {
  final RecuperarSaldoDoEstoque _recuperarSaldoDoEstoque;

  EstoqueSaldoBloc(this._recuperarSaldoDoEstoque)
    : super(const EstoqueSaldoState()) {
    on<EstoqueSaldoIniciou>(_onEstoqueSaldoIniciou);
    on<EstoqueSaldoCarregarMaisSolicitado>(
      _onEstoqueSaldoCarregarMaisSolicitado,
    );
  }

  Future<void> _onEstoqueSaldoIniciou(
    EstoqueSaldoIniciou event,
    Emitter<EstoqueSaldoState> emit,
  ) async {
    final termoBusca = event.termoBusca.trim();
    final filtro = _criarFiltro(
      page: 1,
      limit: event.limit,
      termoBusca: termoBusca,
      corIds: event.corIds,
      tamanhoIds: event.tamanhoIds,
    );

    emit(
      state.copyWith(
        step: EstoqueSaldoStep.carregando,
        itens: const [],
        erro: null,
        sincronizando: false,
        termoBusca: termoBusca,
        corIdsSelecionadas: event.corIds,
        tamanhoIdsSelecionados: event.tamanhoIds,
        page: 1,
        limit: event.limit,
        totalPages: 0,
        totalItems: 0,
      ),
    );

    try {
      final saldoLocal = await _carregarSaldoLocalAcumulado(
        filtroBase: filtro,
        paginaAtual: 1,
      );
      emit(
        state.copyWith(
          step: EstoqueSaldoStep.carregado,
          itens: saldoLocal.items,
          page: 1,
          totalPages: saldoLocal.meta.totalPages,
          totalItems: saldoLocal.meta.totalItems,
          sincronizando: true,
          erro: null,
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }

    try {
      final saldoSincronizado = await _recuperarSaldoDoEstoque
          .sincronizarPagina(filtro: filtro);
      final saldoLocalAtualizado = await _carregarSaldoLocalAcumulado(
        filtroBase: filtro,
        paginaAtual: 1,
      );
      emit(
        state.copyWith(
          step: EstoqueSaldoStep.carregado,
          itens: saldoLocalAtualizado.items,
          page: saldoSincronizado.meta.currentPage,
          totalPages: saldoSincronizado.meta.totalPages,
          totalItems: saldoSincronizado.meta.totalItems,
          sincronizando: false,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: state.itens.isEmpty
              ? EstoqueSaldoStep.falha
              : EstoqueSaldoStep.carregado,
          sincronizando: false,
          erro: 'Erro ao sincronizar saldo de estoque.',
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onEstoqueSaldoCarregarMaisSolicitado(
    EstoqueSaldoCarregarMaisSolicitado event,
    Emitter<EstoqueSaldoState> emit,
  ) async {
    if (state.step == EstoqueSaldoStep.carregandoMais || state.sincronizando) {
      return;
    }
    if (!state.temMaisPaginas) return;

    final proximaPagina = state.page + 1;
    final filtro = _criarFiltro(
      page: proximaPagina,
      limit: state.limit,
      termoBusca: state.termoBusca,
      corIds: state.corIdsSelecionadas,
      tamanhoIds: state.tamanhoIdsSelecionados,
    );

    emit(
      state.copyWith(
        step: EstoqueSaldoStep.carregandoMais,
        sincronizando: false,
        erro: null,
      ),
    );

    try {
      final saldoLocal = await _carregarSaldoLocalAcumulado(
        filtroBase: filtro,
        paginaAtual: proximaPagina,
      );
      final avancouPagina = saldoLocal.items.length > state.itens.length;
      emit(
        state.copyWith(
          step: EstoqueSaldoStep.carregandoMais,
          itens: saldoLocal.items,
          page: avancouPagina ? proximaPagina : state.page,
          totalPages: _maiorValor(state.totalPages, saldoLocal.meta.totalPages),
          totalItems: _maiorValor(state.totalItems, saldoLocal.meta.totalItems),
          sincronizando: false,
          erro: null,
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }

    try {
      final saldoSincronizado = await _recuperarSaldoDoEstoque
          .sincronizarPagina(filtro: filtro);
      final saldoLocalAtualizado = await _carregarSaldoLocalAcumulado(
        filtroBase: filtro,
        paginaAtual: proximaPagina,
      );
      emit(
        state.copyWith(
          step: EstoqueSaldoStep.carregado,
          itens: saldoLocalAtualizado.items,
          page: proximaPagina,
          totalPages: saldoSincronizado.meta.totalPages,
          totalItems: saldoSincronizado.meta.totalItems,
          sincronizando: false,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: state.itens.isEmpty
              ? EstoqueSaldoStep.falha
              : EstoqueSaldoStep.carregado,
          sincronizando: false,
          erro: 'Erro ao carregar próxima página do estoque.',
        ),
      );
      addError(e, s);
    }
  }

  Future<SaldoDoEstoque> _carregarSaldoLocalAcumulado({
    required FiltroProdutoDoEstoque filtroBase,
    required int paginaAtual,
  }) {
    return _recuperarSaldoDoEstoque(
      filtro: filtroBase.copyWith(
        page: 1,
        limit: filtroBase.limit * paginaAtual,
      ),
    );
  }

  FiltroProdutoDoEstoque _criarFiltro({
    required int page,
    required int limit,
    required String termoBusca,
    required List<int> corIds,
    required List<int> tamanhoIds,
  }) {
    return FiltroProdutoDoEstoque(
      page: page,
      limit: limit,
      corIds: corIds,
      tamanhoIds: tamanhoIds,
      produtoIdExternos: termoBusca.isEmpty ? const [] : [termoBusca],
      referenciaIdExternos: termoBusca.isEmpty ? const [] : [termoBusca],
    );
  }

  int _maiorValor(int atual, int novo) {
    return atual > novo ? atual : novo;
  }
}
