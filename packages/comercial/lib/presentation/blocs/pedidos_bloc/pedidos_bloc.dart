import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'pedidos_event.dart';
part 'pedidos_state.dart';

// 'pago' e' um chip de situacaoPagamento (PedidoFilter.situacoesPagamento), dimensao separada
// de situacao (PedidoFilter.situacoes) -- os demais chips da UI mapeiam pra situacao.
const _situacoesBackend = {
  'em_andamento',
  'conferido',
  'faturado',
  'encerrado',
  'cancelado',
};

class PedidosBloc extends Bloc<PedidosEvent, PedidosState> {
  // Busca um item a mais que o solicitado so pra saber se existe proxima pagina, sem precisar
  // de endpoint de count separado -- mesmo truque ja usado no backend (getMeusPedidos).
  static const _itensPorPagina = 30;

  final RecuperarPedidos _recuperarPedidos;
  final CancelarPedido _cancelarPedido;
  final ListarItensPedido _listarItensPedido;
  final ContarPedidosPorSituacao _contarPedidosPorSituacao;

  PedidosBloc(
    this._recuperarPedidos,
    this._cancelarPedido,
    this._listarItensPedido,
    this._contarPedidosPorSituacao,
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
    await Future.wait([_carregarPrimeiraPagina(emit), _recuperarContagem(emit)]);
  }

  FutureOr<void> _onBuscaAlterada(
    PedidosBuscaAlterada event,
    Emitter<PedidosState> emit,
  ) async {
    emit(state.copyWith(busca: event.busca));
    await Future.wait([_carregarPrimeiraPagina(emit), _recuperarContagem(emit)]);
  }

  FutureOr<void> _onFiltroSituacaoAlterado(
    PedidosFiltroSituacaoAlterado event,
    Emitter<PedidosState> emit,
  ) async {
    emit(state.copyWith(situacoesFiltro: event.situacoes));
    await _carregarPrimeiraPagina(emit);
  }

  FutureOr<void> _onFiltroPeriodoAlterado(
    PedidosFiltroPeriodoAlterado event,
    Emitter<PedidosState> emit,
  ) async {
    emit(state.copyWith(
      dataInicial: event.dataInicial,
      dataFinal: event.dataFinal,
    ));
    await Future.wait([_carregarPrimeiraPagina(emit), _recuperarContagem(emit)]);
  }

  Future<void> _carregarPrimeiraPagina(Emitter<PedidosState> emit) async {
    try {
      emit(state.copyWith(step: PedidosStep.carregando, erro: null));
      final pedidos = await _buscarPagina(1);
      emit(
        state.copyWith(
          pedidos: pedidos.itens,
          step: PedidosStep.sucesso,
          erro: null,
          paginaAtual: 1,
          temMaisPaginas: pedidos.temMais,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidosStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar pedidos.')));
      addError(e, s);
    }
  }

  Future<void> _recuperarContagem(Emitter<PedidosState> emit) async {
    try {
      final busca = state.busca.trim();
      final contagem = await _contarPedidosPorSituacao.call(
        searchTerm: busca.isEmpty ? null : busca,
        dataInicial: state.dataInicial,
        dataFinal: state.dataFinal,
      );
      emit(state.copyWith(contagem: contagem));
    } catch (e, s) {
      // Falha na contagem nao pode derrubar a tela -- chips so ficam sem numero atualizado.
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
      final pedidos = await _buscarPagina(proximaPagina);

      emit(
        state.copyWith(
          pedidos: [...state.pedidos, ...pedidos.itens],
          paginaAtual: proximaPagina,
          temMaisPaginas: pedidos.temMais,
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

  Future<({List<Pedido> itens, bool temMais})> _buscarPagina(int page) async {
    final busca = state.busca.trim();
    final temPago = state.situacoesFiltro.contains('pago');
    final situacoesBackend =
        state.situacoesFiltro.where(_situacoesBackend.contains).toList();

    final encontrados = await _recuperarPedidos.call(
      page: page,
      limit: _itensPorPagina + 1,
      searchTerm: busca.isEmpty ? null : busca,
      situacoes: situacoesBackend.isEmpty ? null : situacoesBackend,
      situacoesPagamento: temPago ? const ['pago'] : null,
      dataInicial: state.dataInicial,
      dataFinal: state.dataFinal,
    );

    final temMais = encontrados.length > _itensPorPagina;
    final itens = encontrados.take(_itensPorPagina).toList();
    return (itens: itens, temMais: temMais);
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
      await _carregarPrimeiraPagina(emit);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidosStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao cancelar pedido.')));
      addError(e, s);
    }
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
