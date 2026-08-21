import 'dart:async';

import 'package:comunicados/domain/models/models.dart';
import 'package:comunicados/domain/usecases/listar_comunicados.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'comunicados_event.dart';
part 'comunicados_state.dart';

class ComunicadosBloc extends Bloc<ComunicadosEvent, ComunicadosState> {
  final ListarComunicados _listar;

  ComunicadosBloc(this._listar) : super(const ComunicadosState.initial()) {
    on<ComunicadosCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    ComunicadosCarregar event,
    Emitter<ComunicadosState> emit,
  ) async {
    try {
      emit(state.copyWith(step: ComunicadosStep.carregando));
      final result = await _listar.call(
        status: event.status,
        pagina: event.pagina,
      );
      emit(
        state.copyWith(
          items: result.items,
          total: result.total,
          pagina: event.pagina,
          status: event.status,
          limparStatus: event.status == null,
          step: ComunicadosStep.sucesso,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ComunicadosStep.falha,
          erro: 'Falha ao carregar comunicados.',
        ),
      );
      addError(e, s);
    }
  }
}
