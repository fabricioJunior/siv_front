import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/use_cases.dart';

part 'origem_pagamento_despesa_event.dart';
part 'origem_pagamento_despesa_state.dart';

class OrigemPagamentoDespesaBloc
    extends Bloc<OrigemPagamentoDespesaEvent, OrigemPagamentoDespesaState> {
  final RecuperarOrigemPagamentoDespesa _recuperarOrigem;
  final CriarOrigemPagamentoDespesa _criarOrigem;
  final AtualizarOrigemPagamentoDespesa _atualizarOrigem;

  OrigemPagamentoDespesaBloc(
    this._recuperarOrigem,
    this._criarOrigem,
    this._atualizarOrigem,
  ) : super(
          const OrigemPagamentoDespesaState(
            step: OrigemPagamentoDespesaStep.inicial,
          ),
        ) {
    on<OrigemPagamentoDespesaIniciou>(_onIniciou);
    on<OrigemPagamentoDespesaCampoAlterado>(_onCampoAlterado);
    on<OrigemPagamentoDespesaSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    OrigemPagamentoDespesaIniciou event,
    Emitter<OrigemPagamentoDespesaState> emit,
  ) async {
    try {
      emit(state.copyWith(step: OrigemPagamentoDespesaStep.carregando));

      if (event.id != null) {
        final origem = await _recuperarOrigem.call(event.id!);
        if (origem == null) {
          emit(state.copyWith(step: OrigemPagamentoDespesaStep.falha));
          return;
        }
        emit(OrigemPagamentoDespesaState.fromModel(origem));
        return;
      }

      emit(
        OrigemPagamentoDespesaState(
          empresaId: event.empresaId,
          nome: '',
          tipo: TipoOrigemPagamentoDespesa.dinheiro,
          step: OrigemPagamentoDespesaStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: OrigemPagamentoDespesaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    OrigemPagamentoDespesaCampoAlterado event,
    Emitter<OrigemPagamentoDespesaState> emit,
  ) {
    emit(
      state.copyWith(
        nome: event.nome,
        tipo: event.tipo,
        diaVencimento: event.diaVencimento,
        step: OrigemPagamentoDespesaStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    OrigemPagamentoDespesaSalvou event,
    Emitter<OrigemPagamentoDespesaState> emit,
  ) async {
    try {
      final nome = state.nome?.trim() ?? '';
      final tipo = state.tipo ?? TipoOrigemPagamentoDespesa.dinheiro;

      if (nome.isEmpty) {
        emit(
          state.copyWith(
            step: OrigemPagamentoDespesaStep.validacaoInvalida,
            erro: 'Informe o nome da origem de pagamento.',
          ),
        );
        return;
      }

      if (tipo == TipoOrigemPagamentoDespesa.cartaoCredito &&
          (state.diaVencimento == null || state.diaVencimento! <= 0)) {
        emit(
          state.copyWith(
            step: OrigemPagamentoDespesaStep.validacaoInvalida,
            erro: 'Informe o dia de vencimento para cartão de crédito.',
          ),
        );
        return;
      }

      emit(state.copyWith(step: OrigemPagamentoDespesaStep.salvando, erro: null));

      final origem = OrigemPagamentoDespesa(
        id: state.id,
        empresaId: state.empresaId,
        nome: nome,
        tipo: tipo,
        diaVencimento:
            tipo == TipoOrigemPagamentoDespesa.cartaoCredito
                ? state.diaVencimento
                : null,
      );

      final salva = state.id == null
          ? await _criarOrigem.call(origem)
          : await _atualizarOrigem.call(origem);

      emit(
        OrigemPagamentoDespesaState.fromModel(
          salva,
          step: state.id == null
              ? OrigemPagamentoDespesaStep.criado
              : OrigemPagamentoDespesaStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: OrigemPagamentoDespesaStep.falha,
          erro: 'Falha ao salvar origem de pagamento.',
        ),
      );
      addError(e, s);
    }
  }
}
