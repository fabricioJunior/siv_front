import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'sub_categorias_event.dart';
part 'sub_categorias_state.dart';

class SubCategoriasBloc extends Bloc<SubCategoriasEvent, SubCategoriasState> {
  final RecuperarSubCategorias _recuperarSubCategorias;
  final DesativarSubCategoria _desativarSubCategoria;

  SubCategoriasBloc(this._recuperarSubCategorias, this._desativarSubCategoria)
    : super(const SubCategoriasInitial()) {
    on<SubCategoriasIniciou>(_onSubCategoriasIniciou);
    on<SubCategoriasDesativar>(_onSubCategoriasDesativar);
  }

  FutureOr<void> _onSubCategoriasIniciou(
    SubCategoriasIniciou event,
    Emitter<SubCategoriasState> emit,
  ) async {
    try {
      emit(const SubCategoriasCarregarEmProgresso());
      var subCategorias = await _recuperarSubCategorias.call(
        event.categoriaId,
        nome: event.busca,
        inativa: event.inativa,
      );
      emit(SubCategoriasCarregarSucesso(subCategorias: subCategorias.toList()));
    } catch (e, s) {
      emit(const SubCategoriasCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onSubCategoriasDesativar(
    SubCategoriasDesativar event,
    Emitter<SubCategoriasState> emit,
  ) async {
    try {
      emit(
        SubCategoriasDesativarEmProgresso(subCategorias: state.subCategorias),
      );
      await _desativarSubCategoria.call(event.categoriaId, event.id);
      final subCategoriasFiltradas = state.subCategorias
          .where((subCategoria) => subCategoria.id != event.id)
          .toList();
      emit(
        SubCategoriasDesativarSucesso(subCategorias: subCategoriasFiltradas),
      );
    } catch (e, s) {
      emit(SubCategoriasDesativarFalha(subCategorias: state.subCategorias));
      addError(e, s);
    }
  }
}
