import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'referencias_event.dart';
part 'referencias_state.dart';

class ReferenciasBloc extends Bloc<ReferenciasEvent, ReferenciasState> {
  final RecuperarReferencias _recuperarReferencias;

  ReferenciasBloc(this._recuperarReferencias)
    : super(const ReferenciasInitial()) {
    on<ReferenciasIniciou>(_onReferenciasIniciou);
  }

  FutureOr<void> _onReferenciasIniciou(
    ReferenciasIniciou event,
    Emitter<ReferenciasState> emit,
  ) async {
    try {
      emit(const ReferenciasCarregarEmProgresso());
      var referencias = await _recuperarReferencias.call(
        nome: event.busca,
        inativo: event.inativo,
      );
      List<Referencia> referenciasSelecionadas = [];
      if (event.referenciasSelecionadasIniciais.isNotEmpty) {
        referenciasSelecionadas = event.referenciasSelecionadasIniciais;
      } else if (event.idsReferenciasSelecionadasIniciais.isNotEmpty) {
        referenciasSelecionadas = referencias
            .where(
              (referencia) => event.idsReferenciasSelecionadasIniciais.contains(
                referencia.id,
              ),
            )
            .toList();
      }

      emit(
        ReferenciasCarregarSucesso(
          referencias: referencias.toList(),
          referenciasSelecionadas: referenciasSelecionadas,
        ),
      );
    } catch (e, s) {
      emit(const ReferenciasCarregarFalha());
      addError(e, s);
    }
  }
}
