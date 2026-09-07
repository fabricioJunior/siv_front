import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;

part 'listas_personalizadas_event.dart';
part 'listas_personalizadas_state.dart';

class ListasPersonalizadasBloc
    extends Bloc<ListasPersonalizadasEvent, ListasPersonalizadasState> {
  final ListarListasPersonalizadas _listarListasPersonalizadas;

  ListasPersonalizadasBloc(this._listarListasPersonalizadas)
      : super(const ListasPersonalizadasState()) {
    on<ListasPersonalizadasIniciou>(_onIniciou);
    on<ListasPersonalizadasCarregarMaisSolicitado>(_onCarregarMaisSolicitado);
  }

  Future<void> _onIniciou(
    ListasPersonalizadasIniciou event,
    Emitter<ListasPersonalizadasState> emit,
  ) async {
    emit(
      state.copyWith(
        step: ListasPersonalizadasStep.carregando,
        itens: const [],
        page: 1,
        erro: '',
      ),
    );
    try {
      final pagina = await _listarListasPersonalizadas.call(page: 1);
      emit(
        state.copyWith(
          step: ListasPersonalizadasStep.carregado,
          itens: pagina.items,
          page: 1,
          totalPages: pagina.meta.totalPages,
          erro: '',
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ListasPersonalizadasStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar as listas personalizadas.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onCarregarMaisSolicitado(
    ListasPersonalizadasCarregarMaisSolicitado event,
    Emitter<ListasPersonalizadasState> emit,
  ) async {
    if (state.step == ListasPersonalizadasStep.carregandoMais) return;
    if (!state.temMaisPaginas) return;

    final proximaPagina = state.page + 1;
    emit(state.copyWith(step: ListasPersonalizadasStep.carregandoMais, erro: ''));

    try {
      final pagina = await _listarListasPersonalizadas.call(page: proximaPagina);
      emit(
        state.copyWith(
          step: ListasPersonalizadasStep.carregado,
          itens: [...state.itens, ...pagina.items],
          page: proximaPagina,
          totalPages: pagina.meta.totalPages,
          erro: '',
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ListasPersonalizadasStep.carregado,
          erro: mensagemDeErroApi(e, 'Falha ao carregar mais listas.'),
        ),
      );
      addError(e, s);
    }
  }
}
