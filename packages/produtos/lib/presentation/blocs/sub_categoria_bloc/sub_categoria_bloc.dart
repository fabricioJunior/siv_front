import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'sub_categoria_state.dart';
part 'sub_categoria_event.dart';

class SubCategoriaBloc extends Bloc<SubCategoriaEvent, SubCategoriaState> {
  final RecuperarSubCategoria _recuperarSubCategoria;
  final CriarSubCategoria _criarSubCategoria;
  final AtualizarSubCategoria _atualizarSubCategoria;

  SubCategoriaBloc(
    this._recuperarSubCategoria,
    this._criarSubCategoria,
    this._atualizarSubCategoria,
  ) : super(
        const SubCategoriaState(subCategoriaStep: SubCategoriaStep.inicial),
      ) {
    on<SubCategoriaIniciou>(_onSubCategoriaIniciou);
    on<SubCategoriaEditou>(_onSubCategoriaEditou);
    on<SubCategoriaSalvou>(_onSubCategoriaSalvou);
  }

  FutureOr<void> _onSubCategoriaIniciou(
    SubCategoriaIniciou event,
    Emitter<SubCategoriaState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          subCategoriaStep: SubCategoriaStep.carregando,
          categoriaId: event.categoriaId,
        ),
      );

      if (event.idSubCategoria != null) {
        var subCategoria = await _recuperarSubCategoria.call(
          event.categoriaId,
          event.idSubCategoria!,
        );
        if (subCategoria != null) {
          emit(SubCategoriaState.fromModel(subCategoria));
        } else {
          emit(state.copyWith(subCategoriaStep: SubCategoriaStep.falha));
        }
      } else {
        emit(
          SubCategoriaState(
            subCategoriaStep: SubCategoriaStep.editando,
            categoriaId: event.categoriaId,
            inativa: false,
          ),
        );
      }
    } catch (e, s) {
      emit(state.copyWith(subCategoriaStep: SubCategoriaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onSubCategoriaEditou(
    SubCategoriaEditou event,
    Emitter<SubCategoriaState> emit,
  ) async {
    emit(
      state.copyWith(
        subCategoriaStep: SubCategoriaStep.editando,
        nome: event.nome,
      ),
    );
  }

  FutureOr<void> _onSubCategoriaSalvou(
    SubCategoriaSalvou event,
    Emitter<SubCategoriaState> emit,
  ) async {
    try {
      emit(state.copyWith(subCategoriaStep: SubCategoriaStep.carregando));

      if (state.id != null) {
        var subCategoria = await _atualizarSubCategoria.call(
          state.categoriaId,
          state.id!,
          state.nome!,
        );
        emit(
          SubCategoriaState.fromModel(
            subCategoria,
            step: SubCategoriaStep.salvo,
          ),
        );
      } else {
        var subCategoria = await _criarSubCategoria.call(
          state.categoriaId,
          state.nome!,
        );
        emit(
          SubCategoriaState.fromModel(
            subCategoria,
            step: SubCategoriaStep.criado,
          ),
        );
      }
    } catch (e, s) {
      emit(state.copyWith(subCategoriaStep: SubCategoriaStep.falha));
      addError(e, s);
    }
  }
}
