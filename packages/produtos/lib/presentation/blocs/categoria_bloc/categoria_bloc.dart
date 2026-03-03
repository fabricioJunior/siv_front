import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'categoria_state.dart';
part 'categoria_event.dart';

class CategoriaBloc extends Bloc<CategoriaEvent, CategoriaState> {
  final RecuperarCategoria _recuperarCategoria;
  final CriarCategoria _criarCategoria;
  final AtualizarCategoria _atualizarCategoria;

  CategoriaBloc(
    this._recuperarCategoria,
    this._criarCategoria,
    this._atualizarCategoria,
  ) : super(const CategoriaState(categoriaStep: CategoriaStep.inicial)) {
    on<CategoriaIniciou>(_onCategoriaIniciou);
    on<CategoriaEditou>(_onCategoriaEditou);
    on<CategoriaSalvou>(_onCategoriaSalvou);
  }

  FutureOr<void> _onCategoriaIniciou(
    CategoriaIniciou event,
    Emitter<CategoriaState> emit,
  ) async {
    try {
      emit(state.copyWith(categoriaStep: CategoriaStep.carregando));

      if (event.idCategoria != null) {
        var categoria = await _recuperarCategoria.call(event.idCategoria!);
        if (categoria != null) {
          emit(CategoriaState.fromModel(categoria));
        } else {
          emit(state.copyWith(categoriaStep: CategoriaStep.falha));
        }
      } else {
        emit(
          const CategoriaState(
            categoriaStep: CategoriaStep.editando,
            inativa: false,
          ),
        );
      }
    } catch (e, s) {
      emit(state.copyWith(categoriaStep: CategoriaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCategoriaEditou(
    CategoriaEditou event,
    Emitter<CategoriaState> emit,
  ) async {
    emit(
      state.copyWith(categoriaStep: CategoriaStep.editando, nome: event.nome),
    );
  }

  FutureOr<void> _onCategoriaSalvou(
    CategoriaSalvou event,
    Emitter<CategoriaState> emit,
  ) async {
    try {
      emit(state.copyWith(categoriaStep: CategoriaStep.carregando));

      if (state.id != null) {
        var categoria = await _atualizarCategoria.call(state.id!, state.nome!);
        emit(CategoriaState.fromModel(categoria, step: CategoriaStep.salvo));
      } else {
        var categoria = await _criarCategoria.call(state.nome!);
        emit(CategoriaState.fromModel(categoria, step: CategoriaStep.criado));
      }
    } catch (e, s) {
      emit(state.copyWith(categoriaStep: CategoriaStep.falha));
      addError(e, s);
    }
  }
}
