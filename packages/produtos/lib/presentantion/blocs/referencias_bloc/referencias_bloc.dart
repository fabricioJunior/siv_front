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
    final ordenacao = event.ordenacao ?? state.ordenacao;
    try {
      emit(ReferenciasCarregarEmProgresso(ordenacao: ordenacao));
      var referencias = await _recuperarReferencias.call(
        nome: event.busca,
        inativo: event.inativo,
      );
      referencias = referencias.toList()..sort(_buildOrdenacao(ordenacao));
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
          referencias: referencias,
          referenciasSelecionadas: referenciasSelecionadas,
          ordenacao: ordenacao,
        ),
      );
    } catch (e, s) {
      emit(ReferenciasCarregarFalha(ordenacao: ordenacao));
      addError(e, s);
    }
  }

  int Function(Referencia a, Referencia b) _buildOrdenacao(
    ReferenciasOrdenacao ordenacao,
  ) {
    switch (ordenacao) {
      case ReferenciasOrdenacao.nomeAsc:
        return (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      case ReferenciasOrdenacao.nomeDesc:
        return (a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
      case ReferenciasOrdenacao.criadoEmAsc:
        return (a, b) => _compararDatas(a.criadoEm, b.criadoEm, asc: true);
      case ReferenciasOrdenacao.criadoEmDesc:
        return (a, b) => _compararDatas(a.criadoEm, b.criadoEm, asc: false);
      case ReferenciasOrdenacao.atualizadoEmAsc:
        return (a, b) =>
            _compararDatas(a.atualizadoEm, b.atualizadoEm, asc: true);
      case ReferenciasOrdenacao.atualizadoEmDesc:
        return (a, b) =>
            _compararDatas(a.atualizadoEm, b.atualizadoEm, asc: false);
    }
  }

  int _compararDatas(DateTime? a, DateTime? b, {required bool asc}) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return asc ? a.compareTo(b) : b.compareTo(a);
  }
}
