import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'pedidos_event.dart';
part 'pedidos_state.dart';

class PedidosBloc extends Bloc<PedidosEvent, PedidosState> {
  final RecuperarPedidos _recuperarPedidos;
  final CancelarPedido _cancelarPedido;

  PedidosBloc(this._recuperarPedidos, this._cancelarPedido)
      : super(const PedidosState.initial()) {
    on<PedidosIniciou>(_onIniciou);
    on<PedidosBuscaAlterada>(_onBuscaAlterada);
    on<PedidosFiltroSituacaoAlterado>(_onFiltroSituacaoAlterado);
    on<PedidosPedidoCancelou>(_onPedidoCancelou);
  }

  FutureOr<void> _onIniciou(
    PedidosIniciou event,
    Emitter<PedidosState> emit,
  ) async {
    try {
      emit(state.copyWith(step: PedidosStep.carregando, erro: null));

      final pedidos = await _recuperarPedidos.call();

      emit(
        state.copyWith(
          pedidos: pedidos,
          filtrados: _filtrar(pedidos, state.busca, state.situacoesFiltro),
          step: PedidosStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidosStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar pedidos.')));
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
        filtrados: _filtrar(state.pedidos, event.busca, state.situacoesFiltro),
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
        filtrados: _filtrar(state.pedidos, state.busca, event.situacoes),
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

      final pedidos = await _recuperarPedidos.call();
      emit(
        state.copyWith(
          pedidos: pedidos,
          filtrados: _filtrar(pedidos, state.busca, state.situacoesFiltro),
          step: PedidosStep.sucesso,
          erro: null,
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

  List<Pedido> _filtrar(
    List<Pedido> pedidos,
    String busca,
    Set<String> situacoesFiltro,
  ) {
    final filtro = busca.trim().toLowerCase();
    final lista = pedidos.where((pedido) {
      if (!_bateSituacaoFiltro(pedido, situacoesFiltro)) return false;
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
}
