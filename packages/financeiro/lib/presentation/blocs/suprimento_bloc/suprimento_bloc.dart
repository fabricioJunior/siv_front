import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'suprimento_event.dart';
part 'suprimento_state.dart';

class SuprimentoBloc extends Bloc<SuprimentoEvent, SuprimentoState> {
  final CriarSuprimento _criarSuprimento;

  SuprimentoBloc(this._criarSuprimento)
      : super(const SuprimentoState.initial()) {
    on<SuprimentoIniciou>(_onIniciou);
    on<SuprimentoCampoAlterado>(_onCampoAlterado);
    on<SuprimentoSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    SuprimentoIniciou event,
    Emitter<SuprimentoState> emit,
  ) {
    emit(
      state.copyWith(
        caixaId: event.caixaId,
        step: SuprimentoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onCampoAlterado(
    SuprimentoCampoAlterado event,
    Emitter<SuprimentoState> emit,
  ) {
    emit(
      state.copyWith(
        valor: event.valor ?? state.valor,
        descricao: event.descricao ?? state.descricao,
        step: SuprimentoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    SuprimentoSalvou event,
    Emitter<SuprimentoState> emit,
  ) async {
    final caixaId = state.caixaId;
    final valor = _parseValor(state.valor);
    final descricao = state.descricao.trim();

    if (caixaId == null) {
      emit(
        state.copyWith(
          step: SuprimentoStep.validacaoInvalida,
          erro: 'Não foi possível identificar o caixa do suprimento.',
        ),
      );
      return;
    }

    if (valor == null || valor <= 0) {
      emit(
        state.copyWith(
          step: SuprimentoStep.validacaoInvalida,
          erro: 'Informe um valor válido para o suprimento.',
        ),
      );
      return;
    }

    if (descricao.isEmpty) {
      emit(
        state.copyWith(
          step: SuprimentoStep.validacaoInvalida,
          erro: 'A descrição do suprimento é obrigatória.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: SuprimentoStep.salvando, erro: null));

      final suprimento = await _criarSuprimento.call(
        caixaId: caixaId,
        valor: valor,
        descricao: descricao,
      );

      emit(
        state.copyWith(
          suprimento: suprimento,
          step: SuprimentoStep.criado,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: SuprimentoStep.falha,
          erro: 'Falha ao criar o suprimento. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  double? _parseValor(String texto) {
    final valor = texto.trim();
    if (valor.isEmpty) {
      return null;
    }

    final normalizado = valor.contains(',') && valor.contains('.')
        ? valor.replaceAll('.', '').replaceAll(',', '.')
        : valor.replaceAll(',', '.');

    return double.tryParse(normalizado);
  }
}
