import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;

part 'listas_grupos_event.dart';
part 'listas_grupos_state.dart';

class ListasGruposBloc extends Bloc<ListasGruposEvent, ListasGruposState> {
  final ListarListasGrupos _listar;
  final ExcluirListaGrupo _excluir;

  ListasGruposBloc(this._listar, this._excluir) : super(const ListasGruposState()) {
    on<ListasGruposIniciou>(_onIniciou);
    on<ListasGruposExcluiu>(_onExcluiu);
  }

  Future<void> _onIniciou(
    ListasGruposIniciou event,
    Emitter<ListasGruposState> emit,
  ) async {
    emit(state.copyWith(step: ListasGruposStep.carregando, erro: ''));
    try {
      final pagina = await _listar.call(limit: 100);
      emit(state.copyWith(step: ListasGruposStep.carregado, itens: pagina.items));
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ListasGruposStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar os grupos.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onExcluiu(
    ListasGruposExcluiu event,
    Emitter<ListasGruposState> emit,
  ) async {
    try {
      await _excluir.call(event.id);
      emit(
        state.copyWith(
          itens: state.itens.where((g) => g.id != event.id).toList(),
          erro: '',
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(erro: mensagemDeErroApi(e, 'Falha ao excluir o grupo.')));
      addError(e, s);
    }
  }
}
