import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque_por_referencia.dart';
import 'package:estoque/domain/models/saldo_do_estoque.dart';
import 'package:estoque/use_cases.dart';

part 'estoque_saldo_event.dart';
part 'estoque_saldo_state.dart';

class EstoqueSaldoBloc extends Bloc<EstoqueSaldoEvent, EstoqueSaldoState> {
  final RecuperarSaldoDoEstoque _recuperarSaldoDoEstoque;
  final AgruparSaldoPorReferencia _agruparSaldoPorReferencia;

  static const int _limiteParaRelatorio = 1000000;

  EstoqueSaldoBloc(
    this._recuperarSaldoDoEstoque,
    this._agruparSaldoPorReferencia,
  ) : super(const EstoqueSaldoState()) {
    // `restartable` cancela a busca anterior sempre que uma nova é
    // disparada (troca de filtro/ordenação/busca): evita que a resposta de
    // uma requisição antiga sobrescreva o estado com dados desatualizados
    // (ex: ordenação anterior) quando chega depois da mais recente.
    on<EstoqueSaldoIniciou>(_onEstoqueSaldoIniciou, transformer: restartable());
    on<EstoqueSaldoCarregarMaisSolicitado>(
      _onEstoqueSaldoCarregarMaisSolicitado,
      transformer: sequential(),
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
      disponibilidadeEstoque: event.disponibilidadeEstoque,
      atualizadoEmInicio: event.atualizadoEmInicio,
      atualizadoEmFim: event.atualizadoEmFim,
      corIds: event.corIds,
      tamanhoIds: event.tamanhoIds,
      ordenarPor: event.ordenarPor,
      ordenarDirecao: event.ordenarDirecao,
    );

    emit(
      state.copyWith(
        step: EstoqueSaldoStep.carregando,
        itens: const [],
        itensAgrupados: const [],
        erro: null,
        sincronizando: false,
        termoBusca: termoBusca,
        disponibilidadeEstoque: event.disponibilidadeEstoque,
        atualizadoEmInicio: event.atualizadoEmInicio,
        atualizadoEmFim: event.atualizadoEmFim,
        ordenarPor: event.ordenarPor,
        ordenarDirecao: event.ordenarDirecao,
        visualizarPorReferencia: event.visualizarPorReferencia,
        corIdsSelecionadas: event.corIds,
        tamanhoIdsSelecionados: event.tamanhoIds,
        page: 1,
        limit: event.limit,
        totalPages: 0,
        totalItems: 0,
      ),
    );

    try {
      if (event.visualizarPorReferencia) {
        final agrupado = await _carregarAgrupadoAcumulado(
          filtroBase: filtro,
          paginaAtual: 1,
          ordenarPor: event.ordenarPor,
          ordenarDirecao: event.ordenarDirecao,
        );
        emit(
          state.copyWith(
            step: EstoqueSaldoStep.carregado,
            itensAgrupados: agrupado.items,
            page: 1,
            totalPages: agrupado.totalPages,
            totalItems: agrupado.totalItems,
            sincronizando: true,
            erro: null,
          ),
        );
      } else {
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
      }
    } catch (e, s) {
      addError(e, s);
    }

    try {
      final saldoSincronizado = await _recuperarSaldoDoEstoque
          .sincronizarPagina(filtro: filtro);
      if (event.visualizarPorReferencia) {
        final agrupado = await _carregarAgrupadoAcumulado(
          filtroBase: filtro,
          paginaAtual: 1,
          ordenarPor: event.ordenarPor,
          ordenarDirecao: event.ordenarDirecao,
        );
        emit(
          state.copyWith(
            step: EstoqueSaldoStep.carregado,
            itensAgrupados: agrupado.items,
            page: 1,
            totalPages: agrupado.totalPages,
            totalItems: agrupado.totalItems,
            sincronizando: false,
            erro: null,
          ),
        );
      } else {
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
      }
    } catch (e, s) {
      emit(
        state.copyWith(
          step: state.itens.isEmpty && state.itensAgrupados.isEmpty
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
      disponibilidadeEstoque: state.disponibilidadeEstoque,
      atualizadoEmInicio: state.atualizadoEmInicio,
      atualizadoEmFim: state.atualizadoEmFim,
      corIds: state.corIdsSelecionadas,
      tamanhoIds: state.tamanhoIdsSelecionados,
      ordenarPor: state.ordenarPor,
      ordenarDirecao: state.ordenarDirecao,
    );

    emit(
      state.copyWith(
        step: EstoqueSaldoStep.carregandoMais,
        sincronizando: false,
        erro: null,
      ),
    );

    try {
      if (state.visualizarPorReferencia) {
        final agrupado = await _carregarAgrupadoAcumulado(
          filtroBase: filtro,
          paginaAtual: proximaPagina,
          ordenarPor: state.ordenarPor,
          ordenarDirecao: state.ordenarDirecao,
        );
        final avancouPagina =
            agrupado.items.length > state.itensAgrupados.length;
        emit(
          state.copyWith(
            step: EstoqueSaldoStep.carregandoMais,
            itensAgrupados: agrupado.items,
            page: avancouPagina ? proximaPagina : state.page,
            totalPages: _maiorValor(state.totalPages, agrupado.totalPages),
            totalItems: _maiorValor(state.totalItems, agrupado.totalItems),
            sincronizando: false,
            erro: null,
          ),
        );
      } else {
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
            totalPages: _maiorValor(
              state.totalPages,
              saldoLocal.meta.totalPages,
            ),
            totalItems: _maiorValor(
              state.totalItems,
              saldoLocal.meta.totalItems,
            ),
            sincronizando: false,
            erro: null,
          ),
        );
      }
    } catch (e, s) {
      addError(e, s);
    }

    try {
      final saldoSincronizado = await _recuperarSaldoDoEstoque
          .sincronizarPagina(filtro: filtro);
      if (state.visualizarPorReferencia) {
        final agrupado = await _carregarAgrupadoAcumulado(
          filtroBase: filtro,
          paginaAtual: proximaPagina,
          ordenarPor: state.ordenarPor,
          ordenarDirecao: state.ordenarDirecao,
        );
        emit(
          state.copyWith(
            step: EstoqueSaldoStep.carregado,
            itensAgrupados: agrupado.items,
            page: proximaPagina,
            totalPages: agrupado.totalPages,
            totalItems: agrupado.totalItems,
            sincronizando: false,
            erro: null,
          ),
        );
      } else {
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
      }
    } catch (e, s) {
      emit(
        state.copyWith(
          step: state.itens.isEmpty && state.itensAgrupados.isEmpty
              ? EstoqueSaldoStep.falha
              : EstoqueSaldoStep.carregado,
          sincronizando: false,
          erro: 'Erro ao carregar próxima página do estoque.',
        ),
      );
      addError(e, s);
    }
  }

  /// Retorna os itens (grão de SKU) do relatório de valor do estoque,
  /// sempre a partir do filtro e da ordenação vigentes no estado atual
  /// (o mesmo usado pela tela), garantindo que o PDF reflita a ordenação
  /// visível para o usuário no momento da geração.
  Future<List<ProdutoDoEstoque>> carregarTodosOsItensParaRelatorio() async {
    final filtro = _criarFiltro(
      page: 1,
      limit: _limiteParaRelatorio,
      termoBusca: state.termoBusca,
      disponibilidadeEstoque: state.disponibilidadeEstoque,
      atualizadoEmInicio: state.atualizadoEmInicio,
      atualizadoEmFim: state.atualizadoEmFim,
      corIds: state.corIdsSelecionadas,
      tamanhoIds: state.tamanhoIdsSelecionados,
      ordenarPor: state.ordenarPor,
      ordenarDirecao: state.ordenarDirecao,
    );
    final saldo = await _recuperarSaldoDoEstoque(filtro: filtro);
    return saldo.items;
  }

  /// Retorna os itens agregados por referência do relatório de valor do
  /// estoque, aplicando a mesma ordenação vigente no estado atual.
  Future<List<ProdutoDoEstoquePorReferencia>>
  carregarTodosOsItensAgrupadosParaRelatorio() async {
    final filtro = _criarFiltro(
      page: 1,
      limit: _limiteParaRelatorio,
      termoBusca: state.termoBusca,
      disponibilidadeEstoque: state.disponibilidadeEstoque,
      atualizadoEmInicio: state.atualizadoEmInicio,
      atualizadoEmFim: state.atualizadoEmFim,
      corIds: state.corIdsSelecionadas,
      tamanhoIds: state.tamanhoIdsSelecionados,
      ordenarPor: state.ordenarPor,
      ordenarDirecao: state.ordenarDirecao,
    );
    final todos = await _buscarTodosOsItensDoFiltro(filtro);
    final agrupado = _agruparSaldoPorReferencia(
      itens: todos,
      ordenarPor: state.ordenarPor,
      ordenarDirecao: state.ordenarDirecao,
      page: 1,
      limit: _limiteParaRelatorio,
    );
    return agrupado.items;
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

  Future<PaginaAgrupadaPorReferencia> _carregarAgrupadoAcumulado({
    required FiltroProdutoDoEstoque filtroBase,
    required int paginaAtual,
    CampoOrdenacaoEstoque? ordenarPor,
    DirecaoOrdenacaoEstoque ordenarDirecao = DirecaoOrdenacaoEstoque.asc,
  }) async {
    final todos = await _buscarTodosOsItensDoFiltro(filtroBase);
    return _agruparSaldoPorReferencia(
      itens: todos,
      ordenarPor: ordenarPor,
      ordenarDirecao: ordenarDirecao,
      page: 1,
      limit: filtroBase.limit * paginaAtual,
    );
  }

  Future<List<ProdutoDoEstoque>> _buscarTodosOsItensDoFiltro(
    FiltroProdutoDoEstoque filtroBase,
  ) async {
    final saldo = await _recuperarSaldoDoEstoque(
      filtro: filtroBase.copyWith(page: 1, limit: _limiteParaRelatorio),
    );
    return saldo.items;
  }

  FiltroProdutoDoEstoque _criarFiltro({
    required int page,
    required int limit,
    required String termoBusca,
    required FiltroDisponibilidadeEstoque disponibilidadeEstoque,
    required DateTime? atualizadoEmInicio,
    required DateTime? atualizadoEmFim,
    required List<int> corIds,
    required List<int> tamanhoIds,
    CampoOrdenacaoEstoque? ordenarPor,
    DirecaoOrdenacaoEstoque ordenarDirecao = DirecaoOrdenacaoEstoque.asc,
  }) {
    return FiltroProdutoDoEstoque(
      page: page,
      limit: limit,
      disponibilidadeEstoque: disponibilidadeEstoque,
      atualizadoEmInicio: atualizadoEmInicio,
      atualizadoEmFim: atualizadoEmFim,
      corIds: corIds,
      tamanhoIds: tamanhoIds,
      produtoIdExternos: termoBusca.isEmpty ? const [] : [termoBusca],
      referenciaIdExternos: termoBusca.isEmpty ? const [] : [termoBusca],
      ordenarPor: ordenarPor,
      ordenarDirecao: ordenarDirecao,
    );
  }

  int _maiorValor(int atual, int novo) {
    return atual > novo ? atual : novo;
  }
}
