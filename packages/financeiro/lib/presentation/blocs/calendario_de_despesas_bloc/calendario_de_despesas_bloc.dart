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
  final AtualizarDespesa _atualizarDespesa;
  final ApagarDespesa _apagarDespesa;
  final RecuperarCategoriasDespesa _recuperarCategorias;
  final RecuperarOrigensPagamentoDespesa _recuperarOrigens;

  CalendarioDeDespesasBloc(
    this._recuperarCalendario,
    this._registrarOcorrencia,
    this._atualizarDespesa,
    this._apagarDespesa,
    this._recuperarCategorias,
    this._recuperarOrigens,
  ) : super(const CalendarioDeDespesasInitial()) {
    on<CalendarioDeDespesasIniciou>(_onIniciou);
    on<CalendarioDeDespesasMesAlterado>(_onMesAlterado);
    on<CalendarioDeDespesasOcorrenciaRegistrada>(_onOcorrenciaRegistrada);
    on<CalendarioDeDespesasOcorrenciaApagada>(_onOcorrenciaApagada);
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
          origemPagamentoPorId: {
            for (final o in resultados[1] as List<OrigemPagamentoDespesa>)
              if (o.id != null) o.id!: o,
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
  ) {
    return _processar(emit, event.id, () async {
      if (event.virtual) {
        // Ainda não existe uma linha de despesa pra esse mês (recorrente) --
        // materializa via endpoint de ocorrências.
        await _registrarOcorrencia.call(
          event.id,
          ano: state.ano,
          mes: state.mes,
          valor: event.valor,
          dataPagamento: event.dataPagamento,
          status: event.status,
        );
      } else {
        // Já é uma despesa concreta (avulsa, parcela ou ocorrência já
        // materializada) -- o endpoint de ocorrências rejeita isso com 400
        // porque exige um template recorrente. Atualiza a linha direto.
        await _atualizarDespesa.call(
          event.id,
          valor: event.valor,
          categoriaId: event.categoriaId,
          origemPagamentoId: event.origemPagamentoId,
          dataPagamento: event.dataPagamento,
          status: event.status,
        );
      }
    }, 'Falha ao registrar a ocorrência.');
  }

  FutureOr<void> _onOcorrenciaApagada(
    CalendarioDeDespesasOcorrenciaApagada event,
    Emitter<CalendarioDeDespesasState> emit,
  ) {
    return _processar(emit, event.id, () async {
      if (event.virtual && event.escopo == EscopoExclusaoDespesa.esta) {
        // Só este mês de uma recorrente: não há linha pra apagar, então o mês
        // é materializado como cancelado.
        await _registrarOcorrencia.call(
          event.id,
          ano: state.ano,
          mes: state.mes,
          status: StatusDespesa.cancelado,
        );
      } else {
        await _apagarDespesa.call(event.id, escopo: event.escopo);
      }
    }, 'Falha ao apagar a despesa.');
  }

  /// Roda [acao] e recarrega o mês sem trocar o `step` -- só a ocorrência
  /// [chave] fica em `processando` (loading no card, não na tela toda).
  Future<void> _processar(
    Emitter<CalendarioDeDespesasState> emit,
    int chave,
    Future<void> Function() acao,
    String mensagemDeErro,
  ) async {
    final ano = state.ano;
    final mes = state.mes;
    emit(state.copyWith(processando: {...state.processando, chave}, erro: null));
    try {
      await acao();
      final ocorrencias = await _recuperarCalendario.call(
        empresaId: state.empresaId,
        ano: ano,
        mes: mes,
      );
      // O usuário pode ter trocado de mês enquanto isso rodava.
      final mesmoMes = state.ano == ano && state.mes == mes;
      emit(state.copyWith(
        ocorrencias: mesmoMes ? ocorrencias : null,
        processando: {...state.processando}..remove(chave),
      ));
    } catch (e, s) {
      emit(state.copyWith(
        processando: {...state.processando}..remove(chave),
        erro: mensagemDeErro,
      ));
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
