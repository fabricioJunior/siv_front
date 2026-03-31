import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/use_cases.dart';

part 'forma_de_pagamento_event.dart';
part 'forma_de_pagamento_state.dart';

class FormaDePagamentoBloc
    extends Bloc<FormaDePagamentoEvent, FormaDePagamentoState> {
  final RecuperarFormaDePagamento _recuperarFormaDePagamento;
  final CriarFormaDePagamento _criarFormaDePagamento;
  final AtualizarFormaDePagamento _atualizarFormaDePagamento;

  FormaDePagamentoBloc(
    this._recuperarFormaDePagamento,
    this._criarFormaDePagamento,
    this._atualizarFormaDePagamento,
  ) : super(const FormaDePagamentoState(step: FormaDePagamentoStep.inicial)) {
    on<FormaDePagamentoIniciou>(_onIniciou);
    on<FormaDePagamentoCampoAlterado>(_onCampoAlterado);
    on<FormaDePagamentoSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    FormaDePagamentoIniciou event,
    Emitter<FormaDePagamentoState> emit,
  ) async {
    try {
      emit(state.copyWith(step: FormaDePagamentoStep.carregando));

      if (event.idFormaDePagamento != null) {
        final forma = await _recuperarFormaDePagamento.call(
          event.idFormaDePagamento!,
        );

        if (forma == null) {
          emit(state.copyWith(step: FormaDePagamentoStep.falha));
          return;
        }

        emit(FormaDePagamentoState.fromModel(forma));
        return;
      }

      emit(
        const FormaDePagamentoState(
          descricao: '',
          inicio: 0,
          parcelas: 1,
          tipo: 'Dinheiro',
          inativa: false,
          step: FormaDePagamentoStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: FormaDePagamentoStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    FormaDePagamentoCampoAlterado event,
    Emitter<FormaDePagamentoState> emit,
  ) {
    emit(
      state.copyWith(
        descricao: event.descricao,
        inicio: event.inicio,
        parcelas: event.parcelas,
        tipo: event.tipo,
        inativa: event.inativa,
        step: FormaDePagamentoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    FormaDePagamentoSalvou event,
    Emitter<FormaDePagamentoState> emit,
  ) async {
    try {
      final descricao = state.descricao?.trim() ?? '';
      final inicio = state.inicio ?? 0;
      final parcelas = state.parcelas ?? 0;
      final tipo = state.tipo?.trim() ?? '';

      if (descricao.isEmpty || tipo.isEmpty || parcelas <= 0) {
        emit(
          state.copyWith(
            step: FormaDePagamentoStep.validacaoInvalida,
            erro: 'Preencha descricao, tipo e quantidade de parcelas.',
          ),
        );
        return;
      }

      if (inicio < 0) {
        emit(
          state.copyWith(
            step: FormaDePagamentoStep.validacaoInvalida,
            erro: 'O numero inicial nao pode ser negativo.',
          ),
        );
        return;
      }

      emit(state.copyWith(step: FormaDePagamentoStep.salvando, erro: null));

      final forma = FormaDePagamento.create(
        id: state.id,
        criadoEm: state.formaDePagamento?.criadoEm,
        atualizadoEm: state.formaDePagamento?.atualizadoEm,
        descricao: descricao,
        inicio: inicio,
        parcelas: parcelas,
        tipo: tipo,
        inativa: state.inativa ?? false,
      );

      final salvo = state.id == null
          ? await _criarFormaDePagamento.call(forma)
          : await _atualizarFormaDePagamento.call(forma);

      emit(
        FormaDePagamentoState.fromModel(
          salvo,
          step: state.id == null
              ? FormaDePagamentoStep.criado
              : FormaDePagamentoStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: FormaDePagamentoStep.falha,
          erro: 'Falha ao salvar forma de pagamento.',
        ),
      );
      addError(e, s);
    }
  }
}
