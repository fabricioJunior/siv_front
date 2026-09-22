import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';
import 'package:financeiro/use_cases.dart';

part 'categoria_despesa_event.dart';
part 'categoria_despesa_state.dart';

class CategoriaDespesaBloc
    extends Bloc<CategoriaDespesaEvent, CategoriaDespesaState> {
  final RecuperarCategoriaDespesa _recuperarCategoria;
  final CriarCategoriaDespesa _criarCategoria;
  final AtualizarCategoriaDespesa _atualizarCategoria;

  CategoriaDespesaBloc(
    this._recuperarCategoria,
    this._criarCategoria,
    this._atualizarCategoria,
  ) : super(const CategoriaDespesaState(step: CategoriaDespesaStep.inicial)) {
    on<CategoriaDespesaIniciou>(_onIniciou);
    on<CategoriaDespesaCampoAlterado>(_onCampoAlterado);
    on<CategoriaDespesaSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    CategoriaDespesaIniciou event,
    Emitter<CategoriaDespesaState> emit,
  ) async {
    try {
      emit(state.copyWith(step: CategoriaDespesaStep.carregando));

      if (event.id != null) {
        final categoria = await _recuperarCategoria.call(event.id!);
        if (categoria == null) {
          emit(state.copyWith(step: CategoriaDespesaStep.falha));
          return;
        }
        emit(CategoriaDespesaState.fromModel(categoria));
        return;
      }

      emit(
        CategoriaDespesaState(
          empresaId: event.empresaId,
          nome: '',
          inativa: false,
          step: CategoriaDespesaStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: CategoriaDespesaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    CategoriaDespesaCampoAlterado event,
    Emitter<CategoriaDespesaState> emit,
  ) {
    emit(
      state.copyWith(
        nome: event.nome,
        inativa: event.inativa,
        step: CategoriaDespesaStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    CategoriaDespesaSalvou event,
    Emitter<CategoriaDespesaState> emit,
  ) async {
    try {
      final nome = state.nome?.trim() ?? '';
      if (nome.isEmpty) {
        emit(
          state.copyWith(
            step: CategoriaDespesaStep.validacaoInvalida,
            erro: 'Informe o nome da categoria.',
          ),
        );
        return;
      }

      emit(state.copyWith(step: CategoriaDespesaStep.salvando, erro: null));

      final categoria = CategoriaDespesa(
        id: state.id,
        empresaId: state.empresaId,
        nome: nome,
        inativa: state.inativa ?? false,
      );

      final salva = state.id == null
          ? await _criarCategoria.call(categoria)
          : await _atualizarCategoria.call(categoria);

      emit(
        CategoriaDespesaState.fromModel(
          salva,
          step: state.id == null
              ? CategoriaDespesaStep.criado
              : CategoriaDespesaStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: CategoriaDespesaStep.falha,
          erro: 'Falha ao salvar categoria de despesa.',
        ),
      );
      addError(e, s);
    }
  }
}
