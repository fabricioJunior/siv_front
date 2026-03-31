import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'pedidos_event.dart';
part 'pedidos_state.dart';

class PedidosBloc extends Bloc<PedidosEvent, PedidosState> {
  final RecuperarPedidos _recuperarPedidos;

  PedidosBloc(this._recuperarPedidos) : super(const PedidosState.initial()) {
    on<PedidosIniciou>(_onIniciou);
    on<PedidosBuscaAlterada>(_onBuscaAlterada);
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
          filtrados: _filtrar(pedidos, state.busca),
          step: PedidosStep.sucesso,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidosStep.falha, erro: 'Falha ao carregar pedidos.'));
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
        filtrados: _filtrar(state.pedidos, event.busca),
      ),
    );
  }

  List<Pedido> _filtrar(List<Pedido> pedidos, String busca) {
    final filtro = busca.trim().toLowerCase();
    if (filtro.isEmpty) return pedidos;

    return pedidos.where((pedido) {
      final id = (pedido.id ?? 0).toString();
      final pessoa = (pedido.pessoaId ?? 0).toString();
      final situacao = (pedido.situacao ?? '').toLowerCase();
      return id.contains(filtro) ||
          pessoa.contains(filtro) ||
          situacao.contains(filtro);
    }).toList();
  }
}
