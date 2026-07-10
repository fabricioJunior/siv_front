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
  final RecuperarProvidersPagamentosAvulsos recuperarProvidersPagamentosAvulsos;

  PagamentosAvulsosBloc(
    this.recuperarPagamentosAvulsos,
    this.recuperarProvidersPagamentosAvulsos,
  ) : super(
            const PagamentosAvulsosState(step: PagamentosAvulsosStep.inicial)) {
    on<PagamentosAvulsosIniciou>(_onIniciou);
    on<PagamentosAvulsosProvidersCarregar>(_onProvidersCarregar);
  }

  FutureOr<void> _onIniciou(
    PagamentosAvulsosIniciou event,
    Emitter<PagamentosAvulsosState> emit,
  ) async {
    emit(
      PagamentosAvulsosState(
        pagamentos: state.pagamentos,
        providers: state.providers,
        orderBy: event.orderBy,
        orderDir: event.orderDir,
        descricao: event.descricao,
        provider: event.provider,
        step: PagamentosAvulsosStep.carregando,
      ),
    );
    try {
      final pagamentos = await recuperarPagamentosAvulsos.call(
        orderBy: event.orderBy,
        orderDir: event.orderDir,
        descricao: event.descricao,
        provider: event.provider,
      );
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

  FutureOr<void> _onProvidersCarregar(
    PagamentosAvulsosProvidersCarregar event,
    Emitter<PagamentosAvulsosState> emit,
  ) async {
    try {
      final providers = await recuperarProvidersPagamentosAvulsos.call();
      emit(state.copyWith(providers: providers));
    } catch (e, s) {
      addError(e, s);
    }
  }
}
