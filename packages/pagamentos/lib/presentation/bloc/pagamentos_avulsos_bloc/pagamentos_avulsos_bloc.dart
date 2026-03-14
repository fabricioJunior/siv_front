import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';
import 'package:pagamentos/use_cases.dart';

part 'pagamentos_avulsos_event.dart';
part 'pagamentos_avulsos_state.dart';

class PagamentosAvulsosBloc
    extends Bloc<PagamentosAvulsosEvent, PagamentosAvulsosState> {
  final RecuperarPagamentosAvulsos recuperarPagamentosAvulsos;

  PagamentosAvulsosBloc(this.recuperarPagamentosAvulsos)
      : super(
            const PagamentosAvulsosState(step: PagamentosAvulsosStep.inicial)) {
    on<PagamentosAvulsosIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    PagamentosAvulsosIniciou event,
    Emitter<PagamentosAvulsosState> emit,
  ) async {
    emit(state.copyWith(step: PagamentosAvulsosStep.carregando, erro: null));
    try {
      final pagamentos = await recuperarPagamentosAvulsos.call();
      emit(
        state.copyWith(
          pagamentos: pagamentos,
          step: PagamentosAvulsosStep.carregado,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          step: PagamentosAvulsosStep.falha,
          erro: 'Falha ao carregar pagamentos avulsos.',
        ),
      );
    }
  }
}
