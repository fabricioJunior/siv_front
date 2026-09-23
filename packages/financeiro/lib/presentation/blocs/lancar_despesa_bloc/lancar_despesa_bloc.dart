import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/domain/utils/proxima_data_vencimento_cartao.dart';
import 'package:financeiro/use_cases.dart';

part 'lancar_despesa_event.dart';
part 'lancar_despesa_state.dart';

class LancarDespesaBloc extends Bloc<LancarDespesaEvent, LancarDespesaState> {
  final RecuperarCategoriasDespesa _recuperarCategorias;
  final RecuperarOrigensPagamentoDespesa _recuperarOrigens;
  final RecuperarFormasDePagamento _recuperarFormasDePagamento;
  final CriarDespesa _criarDespesa;

  LancarDespesaBloc(
    this._recuperarCategorias,
    this._recuperarOrigens,
    this._recuperarFormasDePagamento,
    this._criarDespesa,
  ) : super(const LancarDespesaState(step: LancarDespesaStep.inicial)) {
    on<LancarDespesaIniciou>(_onIniciou);
    on<LancarDespesaCampoAlterado>(_onCampoAlterado);
    on<LancarDespesaSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    LancarDespesaIniciou event,
    Emitter<LancarDespesaState> emit,
  ) async {
    try {
      emit(state.copyWith(step: LancarDespesaStep.carregando));

      final resultados = await Future.wait([
        _recuperarCategorias.call(empresaId: event.empresaId),
        _recuperarOrigens.call(empresaId: event.empresaId),
        _recuperarFormasDePagamento.call(),
      ]);

      final dataInicial = event.dataInicial ?? DateTime.now();

      emit(
        state.copyWith(
          empresaId: event.empresaId,
          caixaId: event.caixaId,
          categorias: resultados[0] as List<CategoriaDespesa>,
          origens: resultados[1] as List<OrigemPagamentoDespesa>,
          formasDePagamento: resultados[2] as List<FormaDePagamento>,
          dataInicial: dataInicial,
          dataPagamento: dataInicial,
          parcelas: 1,
          step: LancarDespesaStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: LancarDespesaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    LancarDespesaCampoAlterado event,
    Emitter<LancarDespesaState> emit,
  ) {
    final modoAtual = event.modo ?? state.modo;
    final origemIdAtual = event.origemPagamentoId ?? state.origemPagamentoId;

    var dataPagamento = event.dataPagamento ?? state.dataPagamento;
    var pulouPorFechamento = state.pulouPorFechamento;

    // Recalcula sempre que modo ou origem mudam (não só origem), e volta pra
    // data inicial quando a origem sai de crédito pra outra -- ver 3.4/3.3.
    final precisaRecalcular = event.dataPagamento == null &&
        (event.modo != null || event.origemPagamentoId != null) &&
        (modoAtual == ModoLancamentoDespesa.avulsa ||
            modoAtual == ModoLancamentoDespesa.parcelada);

    if (precisaRecalcular) {
      final origem = origemIdAtual == null ? null : _origemPorId(state.origens, origemIdAtual);
      final diaVencimentoCartao = origem?.diaVencimento;
      if (origem != null &&
          origem.tipo.diaVencimentoObrigatorio &&
          diaVencimentoCartao != null) {
        final (data, pulou) = proximaDataVencimentoCartao(
          diaVencimentoCartao,
          prazoFechamentoDias: origem.prazoFechamentoDias,
        );
        dataPagamento = data;
        pulouPorFechamento = pulou;
      } else {
        dataPagamento = state.dataInicial ?? DateTime.now();
        pulouPorFechamento = false;
      }
    }

    emit(
      state.copyWith(
        modo: event.modo,
        descricao: event.descricao,
        valor: event.valor,
        categoriaId: event.categoriaId,
        origemPagamentoId: event.origemPagamentoId,
        formaPagamentoId: event.formaPagamentoId,
        limparFormaPagamento: event.limparFormaPagamento,
        dataPagamento: dataPagamento,
        pulouPorFechamento: pulouPorFechamento,
        diaVencimento: event.diaVencimento,
        parcelas: event.parcelas,
        step: LancarDespesaStep.editando,
        erro: null,
      ),
    );
  }

  OrigemPagamentoDespesa? _origemPorId(
    List<OrigemPagamentoDespesa> origens,
    int id,
  ) {
    for (final origem in origens) {
      if (origem.id == id) return origem;
    }
    return null;
  }

  FutureOr<void> _onSalvou(
    LancarDespesaSalvou event,
    Emitter<LancarDespesaState> emit,
  ) async {
    try {
      final descricao = state.descricao?.trim() ?? '';
      final valor = state.valor ?? 0;
      final categoriaId = state.categoriaId;
      final origemPagamentoId = state.origemPagamentoId;
      final modo = state.modo;

      if (descricao.isEmpty || valor <= 0) {
        emit(
          state.copyWith(
            step: LancarDespesaStep.validacaoInvalida,
            erro: 'Informe descrição e valor da despesa.',
          ),
        );
        return;
      }

      if (categoriaId == null || origemPagamentoId == null) {
        emit(
          state.copyWith(
            step: LancarDespesaStep.validacaoInvalida,
            erro: 'Selecione a categoria e a origem de pagamento.',
          ),
        );
        return;
      }

      if (modo == ModoLancamentoDespesa.recorrente &&
          (state.diaVencimento == null || state.diaVencimento! <= 0)) {
        emit(
          state.copyWith(
            step: LancarDespesaStep.validacaoInvalida,
            erro: 'Informe o dia de vencimento da despesa recorrente.',
          ),
        );
        return;
      }

      if (modo == ModoLancamentoDespesa.parcelada &&
          (state.parcelas == null || state.parcelas! <= 1)) {
        emit(
          state.copyWith(
            step: LancarDespesaStep.validacaoInvalida,
            erro: 'Informe uma quantidade de parcelas maior que 1.',
          ),
        );
        return;
      }

      emit(state.copyWith(step: LancarDespesaStep.salvando, erro: null));

      final despesa = Despesa(
        empresaId: state.empresaId,
        descricao: descricao,
        valor: valor,
        categoriaId: categoriaId,
        origemPagamentoId: origemPagamentoId,
        formaPagamentoId: state.formaPagamentoId,
        caixaId: state.caixaId,
        // Avulsa e parcelada mandam a data da 1ª parcela (hoje, ou o
        // vencimento do cartão) -- o backend usa como base e incrementa mês
        // a mês sozinho. `dataPagamento` é obrigatório sempre que a despesa
        // não é `recorrente` (ver create-despesa.dto no apollo-api).
        dataPagamento: modo == ModoLancamentoDespesa.recorrente
            ? null
            : state.dataPagamento,
        recorrente: modo == ModoLancamentoDespesa.recorrente,
        diaVencimento:
            modo == ModoLancamentoDespesa.recorrente ? state.diaVencimento : null,
        parcelas: modo == ModoLancamentoDespesa.parcelada ? state.parcelas : null,
      );

      final criada = await _criarDespesa.call(despesa);

      emit(
        state.copyWith(
          despesaCriada: criada,
          step: LancarDespesaStep.criada,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: LancarDespesaStep.falha,
          erro: 'Falha ao lançar despesa.',
        ),
      );
      addError(e, s);
    }
  }
}
