import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'orcamentos_event.dart';
part 'orcamentos_state.dart';

class OrcamentosBloc extends Bloc<OrcamentosEvent, OrcamentosState> {
  final ListarOrcamentos _listarOrcamentos;
  final ExcluirOrcamento _excluirOrcamento;

  OrcamentosBloc(
    this._listarOrcamentos,
    this._excluirOrcamento,
  ) : super(const OrcamentosState()) {
    on<OrcamentosCarregarSolicitado>(_onCarregarSolicitado);
    on<OrcamentoExcluirSolicitado>(_onExcluirSolicitado);
  }

  FutureOr<void> _onCarregarSolicitado(
    OrcamentosCarregarSolicitado event,
    Emitter<OrcamentosState> emit,
  ) async {
    emit(state.copyWith(status: OrcamentosStatus.carregando, erro: null));
    try {
      final orcamentos = await _listarOrcamentos();
      emit(
        state.copyWith(
          status: OrcamentosStatus.carregado,
          orcamentos: orcamentos,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          status: OrcamentosStatus.erro,
          erro: 'Falha ao carregar os orçamentos.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onExcluirSolicitado(
    OrcamentoExcluirSolicitado event,
    Emitter<OrcamentosState> emit,
  ) async {
    try {
      await _excluirOrcamento(event.hash);
      emit(
        state.copyWith(
          orcamentos: state.orcamentos
              .where((orcamento) => orcamento.hash != event.hash)
              .toList(growable: false),
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(erro: 'Falha ao excluir o orçamento.'));
      addError(e, s);
    }
  }
}
