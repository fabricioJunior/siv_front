import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';
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
    final filtro = FiltroProdutoDoEstoque(
      page: 1,
      limit: event.limit,
      corIds: event.corIds,
      tamanhoIds: event.tamanhoIds,
      produtoIdExternos: event.termoBusca.isEmpty
          ? const []
          : [event.termoBusca],
      referenciaIdExternos: event.termoBusca.isEmpty
          ? const []
          : [event.termoBusca],
    );

    emit(
      state.copyWith(
        step: EstoqueSaldoStep.carregando,
        erro: null,
        termoBusca: event.termoBusca,
        corIdsSelecionadas: event.corIds,
        tamanhoIdsSelecionados: event.tamanhoIds,
        page: 1,
        limit: event.limit,
      ),
    );

    try {
      final saldo = await _recuperarSaldoDoEstoque(filtro: filtro);
      emit(
        state.copyWith(
          step: EstoqueSaldoStep.carregado,
          itens: saldo.items,
          page: saldo.meta.currentPage,
          totalPages: saldo.meta.totalPages,
          totalItems: saldo.meta.totalItems,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EstoqueSaldoStep.falha,
          erro: 'Erro ao carregar saldo de estoque.',
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onEstoqueSaldoCarregarMaisSolicitado(
    EstoqueSaldoCarregarMaisSolicitado event,
    Emitter<EstoqueSaldoState> emit,
  ) async {
    if (state.step == EstoqueSaldoStep.carregandoMais) return;
    if (!state.temMaisPaginas) return;

    final proximaPagina = state.page + 1;
    final filtro = FiltroProdutoDoEstoque(
      page: proximaPagina,
      limit: state.limit,
      corIds: state.corIdsSelecionadas,
      tamanhoIds: state.tamanhoIdsSelecionados,
      produtoIdExternos: state.termoBusca.isEmpty
          ? const []
          : [state.termoBusca],
      referenciaIdExternos: state.termoBusca.isEmpty
          ? const []
          : [state.termoBusca],
    );

    emit(state.copyWith(step: EstoqueSaldoStep.carregandoMais, erro: null));

    try {
      final saldo = await _recuperarSaldoDoEstoque(filtro: filtro);
      emit(
        state.copyWith(
          step: EstoqueSaldoStep.carregado,
          itens: [...state.itens, ...saldo.items],
          page: saldo.meta.currentPage,
          totalPages: saldo.meta.totalPages,
          totalItems: saldo.meta.totalItems,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EstoqueSaldoStep.falha,
          erro: 'Erro ao carregar próxima página do estoque.',
        ),
      );
      addError(e, s);
    }
  }
}
