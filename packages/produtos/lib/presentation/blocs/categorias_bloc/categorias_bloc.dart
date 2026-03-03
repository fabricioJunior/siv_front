import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'categorias_event.dart';
part 'categorias_state.dart';

class CategoriasBloc extends Bloc<CategoriasEvent, CategoriasState> {
  final RecuperarCategorias _recuperarCategorias;
  final DesativarCategoria _desativarCategoria;

  CategoriasBloc(this._recuperarCategorias, this._desativarCategoria)
    : super(const CategoriasInitial()) {
    on<CategoriasIniciou>(_onCategoriasIniciou);
    on<CategoriasDesativar>(_onCategoriasDesativar);
  }

  FutureOr<void> _onCategoriasIniciou(
    CategoriasIniciou event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      emit(const CategoriasCarregarEmProgresso());
      var categorias = await _recuperarCategorias.call(
        nome: event.busca,
        inativa: event.inativa,
      );
      emit(CategoriasCarregarSucesso(categorias: categorias.toList()));
    } catch (e, s) {
      emit(const CategoriasCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onCategoriasDesativar(
    CategoriasDesativar event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      emit(CategoriasDesativarEmProgresso(categorias: state.categorias));
      await _desativarCategoria.call(event.id);
      final categoriasFiltradas = state.categorias
          .where((categoria) => categoria.id != event.id)
          .toList();
      emit(CategoriasDesativarSucesso(categorias: categoriasFiltradas));
    } catch (e, s) {
      emit(CategoriasDesativarFalha(categorias: state.categorias));
      addError(e, s);
    }
  }
}
