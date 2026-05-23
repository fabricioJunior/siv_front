import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'sangria_event.dart';
part 'sangria_state.dart';

class SangriaBloc extends Bloc<SangriaEvent, SangriaState> {
  final CriarSangria _criarSangria;

  SangriaBloc(this._criarSangria) : super(const SangriaState.initial()) {
    on<SangriaIniciou>(_onIniciou);
    on<SangriaCampoAlterado>(_onCampoAlterado);
    on<SangriaSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    SangriaIniciou event,
    Emitter<SangriaState> emit,
  ) {
    emit(
      state.copyWith(
        caixaId: event.caixaId,
        step: SangriaStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onCampoAlterado(
    SangriaCampoAlterado event,
    Emitter<SangriaState> emit,
  ) {
    emit(
      state.copyWith(
        valor: event.valor ?? state.valor,
        descricao: event.descricao ?? state.descricao,
        step: SangriaStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    SangriaSalvou event,
    Emitter<SangriaState> emit,
  ) async {
    final caixaId = state.caixaId;
    final valor = _parseValor(state.valor);
    final descricao = state.descricao.trim();

    if (caixaId == null) {
      emit(
        state.copyWith(
          step: SangriaStep.validacaoInvalida,
          erro: 'Não foi possível identificar o caixa da sangria.',
        ),
      );
      return;
    }

    if (valor == null || valor <= 0) {
      emit(
        state.copyWith(
          step: SangriaStep.validacaoInvalida,
          erro: 'Informe um valor válido para a sangria.',
        ),
      );
      return;
    }

    if (descricao.isEmpty) {
      emit(
        state.copyWith(
          step: SangriaStep.validacaoInvalida,
          erro: 'A descrição da sangria é obrigatória.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: SangriaStep.salvando, erro: null));

      final sangria = await _criarSangria.call(
        caixaId: caixaId,
        valor: valor,
        descricao: descricao,
        origem: 'externa',
      );

      emit(
        state.copyWith(
          sangria: sangria,
          step: SangriaStep.criado,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: SangriaStep.falha,
          erro: 'Falha ao criar a sangria. Tente novamente.',
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
