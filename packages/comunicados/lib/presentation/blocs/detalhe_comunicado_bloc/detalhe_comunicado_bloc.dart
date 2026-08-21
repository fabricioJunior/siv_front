import 'dart:async';

import 'package:comunicados/domain/models/models.dart';
import 'package:comunicados/domain/usecases/buscar_comunicado.dart';
import 'package:comunicados/domain/usecases/listar_destinatarios_comunicado.dart';
import 'package:comunicados/domain/usecases/reenviar_destinatario_comunicado.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'detalhe_comunicado_event.dart';
part 'detalhe_comunicado_state.dart';

class DetalheComunicadoBloc
    extends Bloc<DetalheComunicadoEvent, DetalheComunicadoState> {
  final BuscarComunicado _buscarComunicado;
  final ListarDestinatariosComunicado _listarDestinatarios;
  final ReenviarDestinatarioComunicado _reenviarDestinatario;

  DetalheComunicadoBloc(
    this._buscarComunicado,
    this._listarDestinatarios,
    this._reenviarDestinatario,
  ) : super(const DetalheComunicadoState.initial()) {
    on<DetalheComunicadoCarregar>(_onCarregar);
    on<DetalheComunicadoCarregarDestinatarios>(_onCarregarDestinatarios);
    on<DetalheComunicadoReenviar>(_onReenviar);
  }

  FutureOr<void> _onCarregar(
    DetalheComunicadoCarregar event,
    Emitter<DetalheComunicadoState> emit,
  ) async {
    try {
      emit(state.copyWith(step: DetalheComunicadoStep.carregando));
      final comunicado = await _buscarComunicado.call(event.id);
      final destinatarios = await _listarDestinatarios.call(event.id);
      emit(
        state.copyWith(
          comunicado: comunicado,
          destinatarios: destinatarios.items,
          totalDestinatarios: destinatarios.total,
          paginaDestinatarios: 1,
          step: DetalheComunicadoStep.sucesso,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: DetalheComunicadoStep.falha,
          erro: 'Falha ao carregar comunicado.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onCarregarDestinatarios(
    DetalheComunicadoCarregarDestinatarios event,
    Emitter<DetalheComunicadoState> emit,
  ) async {
    final comunicado = state.comunicado;
    if (comunicado == null) return;
    try {
      final destinatarios = await _listarDestinatarios.call(
        comunicado.id,
        status: event.status,
        pagina: event.pagina,
      );
      emit(
        state.copyWith(
          destinatarios: destinatarios.items,
          totalDestinatarios: destinatarios.total,
          paginaDestinatarios: event.pagina,
          statusDestinatarios: event.status,
          limparStatusDestinatarios: event.status == null,
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onReenviar(
    DetalheComunicadoReenviar event,
    Emitter<DetalheComunicadoState> emit,
  ) async {
    final comunicado = state.comunicado;
    if (comunicado == null) return;
    try {
      emit(
        state.copyWith(
          reenviando: {...state.reenviando, event.destinatarioId},
        ),
      );
      final atualizado = await _reenviarDestinatario.call(
        comunicadoId: comunicado.id,
        destinatarioId: event.destinatarioId,
      );
      final destinatarios = state.destinatarios
          .map((d) => d.id == atualizado.id ? atualizado : d)
          .toList();
      final novoReenviando = {...state.reenviando}..remove(
        event.destinatarioId,
      );
      emit(
        state.copyWith(destinatarios: destinatarios, reenviando: novoReenviando),
      );
    } catch (e, s) {
      final novoReenviando = {...state.reenviando}..remove(
        event.destinatarioId,
      );
      emit(
        state.copyWith(
          reenviando: novoReenviando,
          erro: 'Falha ao reenviar para o destinatário.',
        ),
      );
      addError(e, s);
    }
  }
}
