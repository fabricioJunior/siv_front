import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'referencia_event.dart';
part 'referencia_state.dart';

class ReferenciaBloc extends Bloc<ReferenciaEvent, ReferenciaState> {
  final RecuperarReferencia _recuperarReferencia;
  final AtualizarReferencia _atualizarReferencia;

  ReferenciaBloc(this._recuperarReferencia, this._atualizarReferencia)
    : super(const ReferenciaInitial()) {
    on<ReferenciaIniciou>(_onReferenciaIniciou);
    on<ReferenciaAtualizou>(_onReferenciaAtualizou);
  }

  FutureOr<void> _onReferenciaIniciou(
    ReferenciaIniciou event,
    Emitter<ReferenciaState> emit,
  ) async {
    try {
      emit(const ReferenciaCarregarEmProgresso());
      final referencia = await _recuperarReferencia.call(
        id: event.idReferencia,
      );
      emit(ReferenciaCarregarSucesso(referencia: referencia));
    } catch (e, s) {
      emit(const ReferenciaCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onReferenciaAtualizou(
    ReferenciaAtualizou event,
    Emitter<ReferenciaState> emit,
  ) async {
    final referenciaAtual = state.referencia;
    if (referenciaAtual == null) return;

    try {
      emit(ReferenciaSalvarEmProgresso(referencia: referenciaAtual));
      final atualizada = await _atualizarReferencia.call(
        id: event.id,
        nome: event.nome,
        categoriaId: event.categoriaId,
        subCategoriaId: event.subCategoriaId,
        marcaId: event.marcaId,
        idExterno: event.idExterno,
        unidadeMedida: event.unidadeMedida,
        descricao: event.descricao,
        composicao: event.composicao,
        cuidados: event.cuidados,
        ncm: event.ncm,
        pesoGramas: event.pesoGramas,
      );
      emit(ReferenciaSalvarSucesso(referencia: atualizada));
    } catch (e, s) {
      emit(ReferenciaSalvarFalha(referencia: referenciaAtual));
      addError(e, s);
    }
  }
}
