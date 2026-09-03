import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'pedidos_event.dart';
part 'pedidos_state.dart';

class PedidosBloc extends Bloc<PedidosEvent, PedidosState> {
  // Busca um item a mais que o solicitado so pra saber se existe proxima pagina, sem precisar
  // de endpoint de count separado -- mesmo truque ja usado no backend (getMeusPedidos).
  static const _itensPorPagina = 30;

  final RecuperarPedidos _recuperarPedidos;
  final CancelarPedido _cancelarPedido;
  final ListarItensPedido _listarItensPedido;

  PedidosBloc(
    this._recuperarPedidos,
    this._cancelarPedido,
    this._listarItensPedido,
  ) : super(const PedidosState.initial()) {
    on<PedidosIniciou>(_onIniciou);
    on<PedidosBuscaAlterada>(_onBuscaAlterada);
    on<PedidosFiltroSituacaoAlterado>(_onFiltroSituacaoAlterado);
    on<PedidosFiltroPeriodoAlterado>(_onFiltroPeriodoAlterado);
    on<PedidosPedidoCancelou>(_onPedidoCancelou);
    on<PedidosCarregarMais>(_onCarregarMais);
    on<PedidosPedidoSelecionou>(_onPedidoSelecionou);
  }

  FutureOr<void> _onIniciou(
    PedidosIniciou event,
    Emitter<PedidosState> emit,
  ) async {
    try {
      emit(state.copyWith(step: PedidosStep.carregando, erro: null));

      final encontrados = await _recuperarPedidos.call(
        page: 1,
        limit: _itensPorPagina + 1,
      );
      final temMais = encontrados.length > _itensPorPagina;
      final pedidos = encontrados.take(_itensPorPagina).toList();

      emit(
        state.copyWith(
          pedidos: pedidos,
          filtrados: _filtrar(pedidos, state.busca, state.situacoesFiltro, state.dataInicial, state.dataFinal),
          step: PedidosStep.sucesso,
          erro: null,
          paginaAtual: 1,
          temMaisPaginas: temMais,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidosStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar pedidos.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onCarregarMais(
    PedidosCarregarMais event,
    Emitter<PedidosState> emit,
  ) async {
    if (!state.temMaisPaginas || state.carregandoMais) {
      return;
    }

    try {
      emit(state.copyWith(carregandoMais: true));

      final proximaPagina = state.paginaAtual + 1;
      final encontrados = await _recuperarPedidos.call(
        page: proximaPagina,
        limit: _itensPorPagina + 1,
      );
      final temMais = encontrados.length > _itensPorPagina;
      final novosPedidos = encontrados.take(_itensPorPagina).toList();
      final pedidos = [...state.pedidos, ...novosPedidos];

      emit(
        state.copyWith(
          pedidos: pedidos,
          filtrados: _filtrar(pedidos, state.busca, state.situacoesFiltro, state.dataInicial, state.dataFinal),
          paginaAtual: proximaPagina,
          temMaisPaginas: temMais,
          carregandoMais: false,
        ),
      );
    } catch (e, s) {
      // Falha ao carregar mais nao derruba a lista ja exibida -- so para de tentar, usuario
      // pode rolar de novo ou dar refresh (PedidosIniciou) pra tentar do zero.
      emit(state.copyWith(carregandoMais: false));
      addError(e, s);
    }
  }

  FutureOr<void> _onBuscaAlterada(
    PedidosBuscaAlterada event,
    Emitter<PedidosState> emit,
  ) {
    emit(
      state.copyWith(
        busca: event.busca,
        filtrados: _filtrar(state.pedidos, event.busca, state.situacoesFiltro, state.dataInicial, state.dataFinal),
      ),
    );
  }

  FutureOr<void> _onFiltroSituacaoAlterado(
    PedidosFiltroSituacaoAlterado event,
    Emitter<PedidosState> emit,
  ) {
    emit(
      state.copyWith(
        situacoesFiltro: event.situacoes,
        filtrados: _filtrar(state.pedidos, state.busca, event.situacoes, state.dataInicial, state.dataFinal),
      ),
    );
  }

  FutureOr<void> _onPedidoCancelou(
    PedidosPedidoCancelou event,
    Emitter<PedidosState> emit,
  ) async {
    try {
      await _cancelarPedido.call(
        event.pedidoId,
        motivoCancelamento: event.motivoCancelamento,
      );

      final encontrados = await _recuperarPedidos.call(
        page: 1,
        limit: _itensPorPagina + 1,
      );
      final temMais = encontrados.length > _itensPorPagina;
      final pedidos = encontrados.take(_itensPorPagina).toList();

      emit(
        state.copyWith(
          pedidos: pedidos,
          filtrados: _filtrar(pedidos, state.busca, state.situacoesFiltro, state.dataInicial, state.dataFinal),
          step: PedidosStep.sucesso,
          erro: null,
          paginaAtual: 1,
          temMaisPaginas: temMais,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidosStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao cancelar pedido.')));
      addError(e, s);
    }
  }

  // 'pago' e um chip a mais que checa situacaoPagamento, os demais checam situacao -- Set com
  // qualquer um marcado entra no resultado (OR), nao AND (pedido nao pode ser em_andamento E
  // encerrado ao mesmo tempo).
  bool _bateSituacaoFiltro(Pedido pedido, Set<String> situacoesFiltro) {
    if (situacoesFiltro.isEmpty) return true;
    return situacoesFiltro.any((filtro) {
      if (filtro == 'pago') {
        return (pedido.situacaoPagamento ?? '').toLowerCase() == 'pago';
      }
      return (pedido.situacao ?? '').toLowerCase() == filtro;
    });
  }

  bool _bateuPeriodo(
    Pedido pedido,
    DateTime? dataInicial,
    DateTime? dataFinal,
  ) {
    if (dataInicial == null && dataFinal == null) return true;
    final criadoEm = pedido.criadoEm;
    if (criadoEm == null) return false;
    if (dataInicial != null && criadoEm.isBefore(dataInicial)) return false;
    if (dataFinal != null && criadoEm.isAfter(dataFinal)) return false;
    return true;
  }

  List<Pedido> _filtrar(
    List<Pedido> pedidos,
    String busca,
    Set<String> situacoesFiltro, [
    DateTime? dataInicial,
    DateTime? dataFinal,
  ]) {
    final filtro = busca.trim().toLowerCase();
    final lista = pedidos.where((pedido) {
      if (!_bateSituacaoFiltro(pedido, situacoesFiltro)) return false;
      if (!_bateuPeriodo(pedido, dataInicial, dataFinal)) return false;
      if (filtro.isEmpty) return true;

      final id = (pedido.id ?? 0).toString();
      final pessoaId = (pedido.pessoaId ?? 0).toString();
      final pessoaNome = (pedido.pessoaNome ?? '').toLowerCase();
      final situacao = (pedido.situacao ?? '').toLowerCase();
      return id.contains(filtro) ||
          pessoaId.contains(filtro) ||
          pessoaNome.contains(filtro) ||
          situacao.contains(filtro);
    }).toList();

    lista.sort((a, b) => (b.criadoEm ?? DateTime(0))
        .compareTo(a.criadoEm ?? DateTime(0)));
    return lista;
  }

  FutureOr<void> _onFiltroPeriodoAlterado(
    PedidosFiltroPeriodoAlterado event,
    Emitter<PedidosState> emit,
  ) {
    emit(
      state.copyWith(
        dataInicial: event.dataInicial,
        dataFinal: event.dataFinal,
        filtrados: _filtrar(
          state.pedidos,
          state.busca,
          state.situacoesFiltro,
          event.dataInicial,
          event.dataFinal,
        ),
      ),
    );
  }

  FutureOr<void> _onPedidoSelecionou(
    PedidosPedidoSelecionou event,
    Emitter<PedidosState> emit,
  ) async {
    if (event.id == null) {
      emit(state.copyWith(
        pedidoSelecionadoId: null,
        itensDoPedidoSelecionado: const [],
      ));
      return;
    }

    emit(state.copyWith(
      pedidoSelecionadoId: event.id,
      itensDoPedidoSelecionado: const [],
      carregandoItensDoPedidoSelecionado: true,
    ));

    try {
      final itens = await _listarItensPedido.call(event.id!);
      if (state.pedidoSelecionadoId != event.id) return;
      emit(state.copyWith(
        itensDoPedidoSelecionado: itens,
        carregandoItensDoPedidoSelecionado: false,
      ));
    } catch (e, s) {
      if (state.pedidoSelecionadoId != event.id) return;
      emit(state.copyWith(carregandoItensDoPedidoSelecionado: false));
      addError(e, s);
    }
  }
}
