import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/use_cases.dart';

part 'calendario_de_despesas_event.dart';
part 'calendario_de_despesas_state.dart';

class CalendarioDeDespesasBloc
    extends Bloc<CalendarioDeDespesasEvent, CalendarioDeDespesasState> {
  final RecuperarCalendarioDeDespesas _recuperarCalendario;
  final RegistrarOcorrenciaDeDespesa _registrarOcorrencia;
  final RecuperarCategoriasDespesa _recuperarCategorias;
  final RecuperarOrigensPagamentoDespesa _recuperarOrigens;

  CalendarioDeDespesasBloc(
    this._recuperarCalendario,
    this._registrarOcorrencia,
    this._recuperarCategorias,
    this._recuperarOrigens,
  ) : super(const CalendarioDeDespesasInitial()) {
    on<CalendarioDeDespesasIniciou>(_onIniciou);
    on<CalendarioDeDespesasMesAlterado>(_onMesAlterado);
    on<CalendarioDeDespesasOcorrenciaRegistrada>(_onOcorrenciaRegistrada);
  }

  FutureOr<void> _onIniciou(
    CalendarioDeDespesasIniciou event,
    Emitter<CalendarioDeDespesasState> emit,
  ) async {
    final agora = DateTime.now();
    try {
      final resultados = await Future.wait([
        _recuperarCategorias.call(empresaId: event.empresaId),
        _recuperarOrigens.call(empresaId: event.empresaId),
      ]);
      emit(
        state.copyWith(
          categoriaPorId: {
            for (final c in resultados[0] as List<CategoriaDespesa>)
              if (c.id != null) c.id!: c.nome,
          },
          origemPorId: {
            for (final o in resultados[1] as List<OrigemPagamentoDespesa>)
              if (o.id != null) o.id!: o.nome,
          },
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }
    await _carregar(emit, empresaId: event.empresaId, ano: agora.year, mes: agora.month);
  }

  FutureOr<void> _onMesAlterado(
    CalendarioDeDespesasMesAlterado event,
    Emitter<CalendarioDeDespesasState> emit,
  ) async {
    await _carregar(
      emit,
      empresaId: state.empresaId,
      ano: event.ano,
      mes: event.mes,
    );
  }

  FutureOr<void> _onOcorrenciaRegistrada(
    CalendarioDeDespesasOcorrenciaRegistrada event,
    Emitter<CalendarioDeDespesasState> emit,
  ) async {
    try {
      await _registrarOcorrencia.call(
        event.id,
        ano: state.ano,
        mes: state.mes,
        valor: event.valor,
        dataPagamento: event.dataPagamento,
        status: event.status,
      );
      await _carregar(emit, empresaId: state.empresaId, ano: state.ano, mes: state.mes);
    } catch (e, s) {
      emit(state.copyWith(step: CalendarioDeDespesasStep.carregado, erro: 'Falha ao registrar a ocorrência.'));
      addError(e, s);
    }
  }

  Future<void> _carregar(
    Emitter<CalendarioDeDespesasState> emit, {
    required int empresaId,
    required int ano,
    required int mes,
  }) async {
    try {
      emit(
        state.copyWith(
          empresaId: empresaId,
          ano: ano,
          mes: mes,
          step: CalendarioDeDespesasStep.carregando,
          erro: null,
        ),
      );

      final ocorrencias = await _recuperarCalendario.call(
        empresaId: empresaId,
        ano: ano,
        mes: mes,
      );

      emit(
        state.copyWith(
          ocorrencias: ocorrencias,
          step: CalendarioDeDespesasStep.carregado,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: CalendarioDeDespesasStep.falha));
      addError(e, s);
    }
  }
}
