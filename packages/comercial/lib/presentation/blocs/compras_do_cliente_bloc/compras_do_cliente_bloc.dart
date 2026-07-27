import 'dart:async';

import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/get_compras_do_cliente.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';

part 'compras_do_cliente_event.dart';
part 'compras_do_cliente_state.dart';

class ComprasDoClienteBloc
    extends Bloc<ComprasDoClienteEvent, ComprasDoClienteState> {
  final GetComprasDoCliente _useCase;

  ComprasDoClienteBloc(this._useCase)
      : super(const ComprasDoClienteState.initial()) {
    on<ComprasDoClienteCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    ComprasDoClienteCarregar event,
    Emitter<ComprasDoClienteState> emit,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    try {
      emit(const ComprasDoClienteState(step: ComprasDoClienteStep.carregando));
      final dados = await _useCase.call(
        empresaIds: [empresaId],
        pessoaId: event.pessoaId,
        limit: event.limit,
      );
      emit(ComprasDoClienteState(
        step: ComprasDoClienteStep.sucesso,
        dados: dados,
      ));
    } catch (e, s) {
      emit(const ComprasDoClienteState(
        step: ComprasDoClienteStep.falha,
        erro: 'Falha ao carregar compras do cliente.',
      ));
      addError(e, s);
    }
  }
}
