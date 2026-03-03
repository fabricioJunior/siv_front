import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'cor_state.dart';
part 'cor_event.dart';

class CorBloc extends Bloc<CorEvent, CorState> {
  final RecuperarCor _recuperarCor;
  final CriarCor _criarCor;
  final AtualizarCor _atualizarCor;

  CorBloc(this._recuperarCor, this._criarCor, this._atualizarCor)
    : super(const CorState(corStep: CorStep.inicial)) {
    on<CorIniciou>(_onCorIniciou);
    on<CorEditou>(_onCorEditou);
    on<CorSalvou>(_onCorSalvou);
  }

  FutureOr<void> _onCorIniciou(CorIniciou event, Emitter<CorState> emit) async {
    try {
      emit(state.copyWith(corStep: CorStep.carregando));

      if (event.idCor != null) {
        var cor = await _recuperarCor.call(event.idCor!);
        if (cor != null) {
          emit(CorState.fromModel(cor));
        } else {
          emit(state.copyWith(corStep: CorStep.falha));
        }
      } else {
        emit(const CorState(corStep: CorStep.editando, inativo: false));
      }
    } catch (e, s) {
      emit(state.copyWith(corStep: CorStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCorEditou(CorEditou event, Emitter<CorState> emit) async {
    emit(state.copyWith(corStep: CorStep.editando, nome: event.nome));
  }

  FutureOr<void> _onCorSalvou(CorSalvou event, Emitter<CorState> emit) async {
    try {
      emit(state.copyWith(corStep: CorStep.carregando));

      if (state.id != null) {
        var cor = await _atualizarCor.call(state.id!, state.nome!);
        emit(CorState.fromModel(cor, step: CorStep.salvo));
      } else {
        var cor = await _criarCor.call(state.nome!);
        emit(CorState.fromModel(cor, step: CorStep.criado));
      }
    } catch (e, s) {
      emit(state.copyWith(corStep: CorStep.falha));
      addError(e, s);
    }
  }
}
