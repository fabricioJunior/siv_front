import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'etiquetas_event.dart';
part 'etiquetas_state.dart';

class EtiquetasBloc extends Bloc<EtiquetasEvent, EtiquetasState> {
  final RecuperarEtiquetas _recuperarEtiquetas;
  final CriarEtiqueta _criarEtiqueta;
  final ExcluirEtiqueta _excluirEtiqueta;

  EtiquetasBloc(this._recuperarEtiquetas, this._criarEtiqueta, this._excluirEtiqueta)
    : super(const EtiquetasInitial()) {
    on<EtiquetasIniciou>(_onEtiquetasIniciou);
    on<EtiquetasCriarSolicitado>(_onEtiquetasCriarSolicitado);
    on<EtiquetasExcluirSolicitado>(_onEtiquetasExcluirSolicitado);
  }

  FutureOr<void> _onEtiquetasIniciou(
    EtiquetasIniciou event,
    Emitter<EtiquetasState> emit,
  ) async {
    try {
      emit(EtiquetasCarregarEmProgresso(etiquetas: state.etiquetas));
      final etiquetas = await _recuperarEtiquetas();
      emit(EtiquetasCarregarSucesso(etiquetas: etiquetas));
    } catch (e, s) {
      emit(EtiquetasCarregarFalha(etiquetas: state.etiquetas));
      addError(e, s);
    }
  }

  FutureOr<void> _onEtiquetasCriarSolicitado(
    EtiquetasCriarSolicitado event,
    Emitter<EtiquetasState> emit,
  ) async {
    try {
      emit(EtiquetasCriarEmProgresso(etiquetas: state.etiquetas));
      final etiqueta = await _criarEtiqueta(
        nome: event.nome,
        altura: event.altura,
        largura: event.largura,
        dpi: event.dpi,
        elementos: event.elementos,
        vias: event.vias,
      );

      emit(
        EtiquetasCriarSucesso(
          etiquetas: [etiqueta, ...state.etiquetas],
        ),
      );
    } catch (e, s) {
      emit(EtiquetasCriarFalha(etiquetas: state.etiquetas));
      addError(e, s);
    }
  }

  FutureOr<void> _onEtiquetasExcluirSolicitado(
    EtiquetasExcluirSolicitado event,
    Emitter<EtiquetasState> emit,
  ) async {
    try {
      emit(EtiquetasExcluirEmProgresso(etiquetas: state.etiquetas));
      await _excluirEtiqueta(event.id);
      final etiquetasFiltradas = state.etiquetas
          .where((etiqueta) => etiqueta.id != event.id)
          .toList(growable: false);
      emit(EtiquetasExcluirSucesso(etiquetas: etiquetasFiltradas));
    } catch (e, s) {
      emit(EtiquetasExcluirFalha(etiquetas: state.etiquetas));
      addError(e, s);
    }
  }
}
