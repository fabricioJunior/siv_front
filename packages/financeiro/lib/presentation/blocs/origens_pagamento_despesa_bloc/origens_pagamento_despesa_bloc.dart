import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/use_cases.dart';

part 'origens_pagamento_despesa_event.dart';
part 'origens_pagamento_despesa_state.dart';

class OrigensPagamentoDespesaBloc
    extends Bloc<OrigensPagamentoDespesaEvent, OrigensPagamentoDespesaState> {
  final RecuperarOrigensPagamentoDespesa _recuperarOrigens;
  final CriarOrigemPagamentoDespesa _criarOrigem;
  final AtualizarOrigemPagamentoDespesa _atualizarOrigem;

  OrigensPagamentoDespesaBloc(
    this._recuperarOrigens,
    this._criarOrigem,
    this._atualizarOrigem,
  ) : super(const OrigensPagamentoDespesaInitial()) {
    on<OrigensPagamentoDespesaIniciou>(_onIniciou);
    on<OrigensPagamentoDespesaSelecionou>(_onSelecionou);
    on<OrigensPagamentoDespesaCampoAlterado>(_onCampoAlterado);
    on<OrigensPagamentoDespesaSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    OrigensPagamentoDespesaIniciou event,
    Emitter<OrigensPagamentoDespesaState> emit,
  ) async {
    try {
      emit(OrigensPagamentoDespesaCarregarEmProgresso(origens: state.origens));

      final origens = await _recuperarOrigens.call(
        empresaId: event.empresaId,
        filtro: event.busca,
      );

      emit(OrigensPagamentoDespesaCarregarSucesso(origens: origens));
    } catch (e, s) {
      emit(OrigensPagamentoDespesaCarregarFalha(origens: state.origens));
      addError(e, s);
    }
  }

  void _onSelecionou(
    OrigensPagamentoDespesaSelecionou event,
    Emitter<OrigensPagamentoDespesaState> emit,
  ) {
    final atual = _sucesso(emit);
    if (atual == null) return;

    if (event.id == null) {
      emit(atual.copyWith(editando: true, limparFormId: true, formNome: '', formTipo: TipoOrigemPagamentoDespesa.dinheiro, erro: null));
      return;
    }

    OrigemPagamentoDespesa? origem;
    for (final o in atual.origens) {
      if (o.id == event.id) origem = o;
    }
    if (origem == null) return;

    emit(
      atual.copyWith(
        editando: true,
        formId: origem.id,
        formNome: origem.nome,
        formTipo: origem.tipo,
        formDiaVencimento: origem.diaVencimento,
        formPrazoFechamentoDias: origem.prazoFechamentoDias,
        erro: null,
      ),
    );
  }

  void _onCampoAlterado(
    OrigensPagamentoDespesaCampoAlterado event,
    Emitter<OrigensPagamentoDespesaState> emit,
  ) {
    final atual = _sucesso(emit);
    if (atual == null) return;
    emit(
      atual.copyWith(
        formNome: event.nome,
        formTipo: event.tipo,
        formDiaVencimento: event.diaVencimento,
        formPrazoFechamentoDias: event.prazoFechamentoDias,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    OrigensPagamentoDespesaSalvou event,
    Emitter<OrigensPagamentoDespesaState> emit,
  ) async {
    final atual = _sucesso(emit);
    if (atual == null) return;
    if (atual.formNome.trim().isEmpty) {
      emit(atual.copyWith(erro: 'Informe o nome da origem.'));
      return;
    }
    if (atual.formTipo.diaVencimentoObrigatorio &&
        (atual.formDiaVencimento == null ||
            atual.formDiaVencimento! <= 0 ||
            atual.formDiaVencimento! > 31 ||
            atual.formPrazoFechamentoDias == null ||
            atual.formPrazoFechamentoDias! <= 0)) {
      emit(atual.copyWith(erro: 'Informe o dia de vencimento e o prazo de fechamento.'));
      return;
    }

    try {
      emit(atual.copyWith(salvando: true, erro: null));

      final origem = OrigemPagamentoDespesa(
        id: atual.formId,
        empresaId: event.empresaId,
        nome: atual.formNome.trim(),
        tipo: atual.formTipo,
        diaVencimento: atual.formTipo.diaVencimentoObrigatorio ? atual.formDiaVencimento : null,
        prazoFechamentoDias:
            atual.formTipo.diaVencimentoObrigatorio ? atual.formPrazoFechamentoDias : null,
      );

      if (atual.formId == null) {
        await _criarOrigem.call(origem);
      } else {
        await _atualizarOrigem.call(origem);
      }

      final origens = await _recuperarOrigens.call(empresaId: event.empresaId);
      emit(OrigensPagamentoDespesaCarregarSucesso(origens: origens));
    } catch (e, s) {
      emit(atual.copyWith(salvando: false, erro: 'Falha ao salvar a origem de pagamento.'));
      addError(e, s);
    }
  }

  OrigensPagamentoDespesaCarregarSucesso? _sucesso(Emitter<OrigensPagamentoDespesaState> emit) {
    final atual = state;
    return atual is OrigensPagamentoDespesaCarregarSucesso ? atual : null;
  }
}
