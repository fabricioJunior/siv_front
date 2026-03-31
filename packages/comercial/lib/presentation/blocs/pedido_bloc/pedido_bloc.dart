import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'pedido_event.dart';
part 'pedido_state.dart';

class PedidoBloc extends Bloc<PedidoEvent, PedidoState> {
  final RecuperarPedido _recuperarPedido;
  final CriarPedido _criarPedido;
  final AtualizarPedido _atualizarPedido;
  final ConferirPedido _conferirPedido;
  final FaturarPedido _faturarPedido;
  final CancelarPedido _cancelarPedido;

  PedidoBloc(
    this._recuperarPedido,
    this._criarPedido,
    this._atualizarPedido,
    this._conferirPedido,
    this._faturarPedido,
    this._cancelarPedido,
  ) : super(const PedidoState.initial()) {
    on<PedidoIniciou>(_onIniciou);
    on<PedidoCampoAlterado>(_onCampoAlterado);
    on<PedidoSalvou>(_onSalvou);
    on<PedidoConferiu>(_onConferiu);
    on<PedidoFaturou>(_onFaturou);
    on<PedidoCancelou>(_onCancelou);
  }

  FutureOr<void> _onIniciou(
    PedidoIniciou event,
    Emitter<PedidoState> emit,
  ) async {
    try {
      emit(state.copyWith(step: PedidoStep.carregando, erro: null));

      if (event.idPedido != null) {
        final pedido = await _recuperarPedido.call(event.idPedido!);
        emit(PedidoState.fromModel(pedido));
        return;
      }

      emit(
        const PedidoState.initial().copyWith(
          dataBasePagamento: _dateOnly(DateTime.now()),
          previsaoDeFaturamento: _dateOnly(DateTime.now()),
          previsaoDeEntrega: _dateOnly(DateTime.now()),
          step: PedidoStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha, erro: 'Falha ao carregar pedido.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    PedidoCampoAlterado event,
    Emitter<PedidoState> emit,
  ) {
    emit(
      state.copyWith(
        pessoaId: event.pessoaId,
        funcionarioId: event.funcionarioId,
        tabelaPrecoId: event.tabelaPrecoId,
        parcelas: event.parcelas,
        intervalo: event.intervalo,
        dataBasePagamento: event.dataBasePagamento,
        previsaoDeFaturamento: event.previsaoDeFaturamento,
        previsaoDeEntrega: event.previsaoDeEntrega,
        tipo: event.tipo,
        fiscal: event.fiscal,
        observacao: event.observacao,
        step: PedidoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    PedidoSalvou event,
    Emitter<PedidoState> emit,
  ) async {
    final erro = _validar(state);
    if (erro != null) {
      emit(state.copyWith(step: PedidoStep.validacaoInvalida, erro: erro));
      return;
    }

    try {
      emit(state.copyWith(step: PedidoStep.salvando, erro: null));

      final pedido = _toModel(state);
      final salvo = state.id == null
          ? await _criarPedido.call(pedido)
          : await _atualizarPedido.call(pedido);

      emit(
        PedidoState.fromModel(
          salvo,
          step: state.id == null ? PedidoStep.criado : PedidoStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha, erro: 'Falha ao salvar pedido.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onConferiu(
    PedidoConferiu event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _conferirPedido.call(state.id!);
      final pedido = await _recuperarPedido.call(state.id!);
      emit(PedidoState.fromModel(pedido, step: PedidoStep.conferido));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha, erro: 'Falha ao conferir pedido.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onFaturou(
    PedidoFaturou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _faturarPedido.call(state.id!);
      final pedido = await _recuperarPedido.call(state.id!);
      emit(PedidoState.fromModel(pedido, step: PedidoStep.faturado));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha, erro: 'Falha ao faturar pedido.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onCancelou(
    PedidoCancelou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    final motivo = event.motivoCancelamento.trim();
    if (motivo.isEmpty) {
      emit(
        state.copyWith(
          step: PedidoStep.validacaoInvalida,
          erro: 'Informe o motivo do cancelamento.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _cancelarPedido.call(state.id!, motivoCancelamento: motivo);
      final pedido = await _recuperarPedido.call(state.id!);
      emit(PedidoState.fromModel(pedido, step: PedidoStep.cancelado));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha, erro: 'Falha ao cancelar pedido.'));
      addError(e, s);
    }
  }

  String? _validar(PedidoState state) {
    if ((state.pessoaId ?? '').trim().isEmpty ||
        (state.funcionarioId ?? '').trim().isEmpty ||
        (state.tabelaPrecoId ?? '').trim().isEmpty ||
        (state.dataBasePagamento ?? '').trim().isEmpty ||
        (state.previsaoDeFaturamento ?? '').trim().isEmpty ||
        (state.previsaoDeEntrega ?? '').trim().isEmpty ||
        (state.observacao ?? '').trim().isEmpty) {
      return 'Preencha os campos obrigatorios.';
    }

    if (int.tryParse(state.parcelas ?? '') == null ||
        int.tryParse(state.intervalo ?? '') == null) {
      return 'Parcelas e intervalo devem ser numericos.';
    }

    if (DateTime.tryParse(state.dataBasePagamento ?? '') == null ||
        DateTime.tryParse(state.previsaoDeFaturamento ?? '') == null ||
        DateTime.tryParse(state.previsaoDeEntrega ?? '') == null) {
      return 'As datas devem estar no formato YYYY-MM-DD.';
    }

    return null;
  }

  Pedido _toModel(PedidoState state) {
    return Pedido.create(
      id: state.id,
      pessoaId: int.tryParse(state.pessoaId ?? ''),
      funcionarioId: int.tryParse(state.funcionarioId ?? ''),
      tabelaPrecoId: int.tryParse(state.tabelaPrecoId ?? ''),
      parcelas: int.tryParse(state.parcelas ?? ''),
      intervalo: int.tryParse(state.intervalo ?? ''),
      dataBasePagamento: DateTime.tryParse(state.dataBasePagamento ?? ''),
      previsaoDeFaturamento:
          DateTime.tryParse(state.previsaoDeFaturamento ?? ''),
      previsaoDeEntrega: DateTime.tryParse(state.previsaoDeEntrega ?? ''),
      tipo: state.tipo,
      fiscal: state.fiscal,
      observacao: state.observacao?.trim(),
      criadoEm: state.pedido?.criadoEm,
      atualizadoEm: state.pedido?.atualizadoEm,
      situacao: state.pedido?.situacao,
      motivoCancelamento: state.pedido?.motivoCancelamento,
    );
  }

  String _dateOnly(DateTime value) {
    return value.toIso8601String().split('T').first;
  }
}
