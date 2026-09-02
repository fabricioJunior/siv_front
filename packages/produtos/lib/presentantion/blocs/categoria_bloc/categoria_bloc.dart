import 'dart:async';
import 'dart:typed_data';

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
  final EnviarIconeCategoria _enviarIconeCategoria;

  CategoriaBloc(
    this._recuperarCategoria,
    this._criarCategoria,
    this._atualizarCategoria,
    this._enviarIconeCategoria,
  ) : super(const CategoriaState(categoriaStep: CategoriaStep.inicial)) {
    on<CategoriaIniciou>(_onCategoriaIniciou);
    on<CategoriaEditou>(_onCategoriaEditou);
    on<CategoriaSalvou>(_onCategoriaSalvou);
    on<CategoriaIconeEnviou>(_onCategoriaIconeEnviou);
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
      state.copyWith(
        categoriaStep: CategoriaStep.editando,
        nome: event.nome,
        ncm: event.ncm ?? state.ncm,
        descricao: event.descricao ?? state.descricao,
      ),
    );
  }

  FutureOr<void> _onCategoriaSalvou(
    CategoriaSalvou event,
    Emitter<CategoriaState> emit,
  ) async {
    try {
      emit(state.copyWith(categoriaStep: CategoriaStep.carregando));

      if (state.id != null) {
        var categoria = await _atualizarCategoria.call(
          state.id!,
          state.nome!,
          ncm: state.ncm,
          descricao: state.descricao,
        );
        emit(CategoriaState.fromModel(categoria, step: CategoriaStep.salvo));
      } else {
        var categoria = await _criarCategoria.call(
          state.nome!,
          ncm: state.ncm,
          descricao: state.descricao,
        );
        emit(CategoriaState.fromModel(categoria, step: CategoriaStep.criado));
      }
    } catch (e, s) {
      emit(state.copyWith(categoriaStep: CategoriaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCategoriaIconeEnviou(
    CategoriaIconeEnviou event,
    Emitter<CategoriaState> emit,
  ) async {
    if (state.id == null) return;
    try {
      var categoria = await _enviarIconeCategoria.call(
        state.id!,
        event.bytes,
        event.fileName,
      );
      emit(state.copyWith(icone: categoria.icone));
    } catch (e, s) {
      addError(e, s);
    }
  }
}
