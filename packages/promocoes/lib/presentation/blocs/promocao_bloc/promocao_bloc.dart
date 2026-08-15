import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';
import 'package:promocoes/domain/models/promocao.dart';
import 'package:promocoes/domain/models/promocao_forma_pagamento.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';
import 'package:promocoes/use_cases.dart';

part 'promocao_event.dart';
part 'promocao_state.dart';

class PromocaoBloc extends Bloc<PromocaoEvent, PromocaoState> {
  final RecuperarPromocao _recuperarPromocao;
  final CriarPromocao _criarPromocao;
  final AtualizarPromocao _atualizarPromocao;
  final RecuperarFormasDePagamento _recuperarFormasDePagamento;

  PromocaoBloc(
    this._recuperarPromocao,
    this._criarPromocao,
    this._atualizarPromocao,
    this._recuperarFormasDePagamento,
  ) : super(const PromocaoState(step: PromocaoStep.inicial)) {
    on<PromocaoIniciou>(_onIniciou);
    on<PromocaoCampoAlterado>(_onCampoAlterado);
    on<PromocaoSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    PromocaoIniciou event,
    Emitter<PromocaoState> emit,
  ) async {
    try {
      emit(state.copyWith(step: PromocaoStep.carregando));

      final formasDePagamentoDisponiveis =
          await _recuperarFormasDePagamento.call();

      if (event.idPromocao != null) {
        final promocao = await _recuperarPromocao.call(event.idPromocao!);

        if (promocao == null) {
          emit(state.copyWith(step: PromocaoStep.falha));
          return;
        }

        emit(
          PromocaoState.fromModel(
            promocao,
            formasDePagamentoDisponiveis: formasDePagamentoDisponiveis,
          ),
        );
        return;
      }

      emit(
        PromocaoState(
          nome: '',
          tipoDesconto: TipoDesconto.percentual,
          tipoEscopo: TipoEscopo.geral,
          formasDePagamentoDisponiveis: formasDePagamentoDisponiveis,
          step: PromocaoStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: PromocaoStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    PromocaoCampoAlterado event,
    Emitter<PromocaoState> emit,
  ) {
    emit(
      state.copyWith(
        nome: event.nome,
        descricao: event.descricao,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        tipoDesconto: event.tipoDesconto,
        valorPercentual: event.valorPercentual,
        valorDescontoMaximo: event.valorDescontoMaximo,
        valorFixo: event.valorFixo,
        valorMinimoCompra: event.valorMinimoCompra,
        quantidadeMinima: event.quantidadeMinima,
        precoFixo: event.precoFixo,
        tipoEscopo: event.tipoEscopo,
        referenciaIds: event.referenciaIds,
        comboKit: event.comboKit,
        quantidadeLeva: event.quantidadeLeva,
        quantidadePaga: event.quantidadePaga,
        limparEscopo: event.limparEscopo,
        limiteUnidadesVendidas: event.limiteUnidadesVendidas,
        limiteUsosPorCliente: event.limiteUsosPorCliente,
        periodoLimiteCliente: event.periodoLimiteCliente,
        somenteAniversariante: event.somenteAniversariante,
        canal: event.canal,
        ativa: event.ativa,
        restringirFormasPagamento: event.restringirFormasPagamento,
        formasPagamento: event.formasPagamento,
        step: PromocaoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    PromocaoSalvou event,
    Emitter<PromocaoState> emit,
  ) async {
    try {
      final nome = state.nome?.trim() ?? '';
      final dataInicio = state.dataInicio;
      final dataFim = state.dataFim;

      if (nome.isEmpty || dataInicio == null || dataFim == null) {
        emit(
          state.copyWith(
            step: PromocaoStep.validacaoInvalida,
            erro: 'Preencha nome, data de início e data de fim.',
          ),
        );
        return;
      }

      if (dataFim.isBefore(dataInicio)) {
        emit(
          state.copyWith(
            step: PromocaoStep.validacaoInvalida,
            erro: 'A data de fim não pode ser anterior à data de início.',
          ),
        );
        return;
      }

      final erroDesconto = _validarTipoDesconto(state);
      if (erroDesconto != null) {
        emit(
          state.copyWith(
            step: PromocaoStep.validacaoInvalida,
            erro: erroDesconto,
          ),
        );
        return;
      }

      final erroEscopo = _validarTipoEscopo(state);
      if (erroEscopo != null) {
        emit(
          state.copyWith(
            step: PromocaoStep.validacaoInvalida,
            erro: erroEscopo,
          ),
        );
        return;
      }

      if (state.restringirFormasPagamento && state.formasPagamento.isEmpty) {
        emit(
          state.copyWith(
            step: PromocaoStep.validacaoInvalida,
            erro:
                'Selecione ao menos uma forma de pagamento permitida ou desligue a restrição.',
          ),
        );
        return;
      }

      if ((state.limiteUsosPorCliente != null) !=
          (state.periodoLimiteCliente != null)) {
        emit(
          state.copyWith(
            step: PromocaoStep.validacaoInvalida,
            erro:
                'Informe o limite de usos por cliente e o período juntos, ou deixe os dois vazios.',
          ),
        );
        return;
      }

      emit(state.copyWith(step: PromocaoStep.salvando, erro: null));

      final promocao = Promocao.create(
        id: state.id,
        empresaId: state.promocao?.empresaId,
        nome: nome,
        descricao: state.descricao,
        dataInicio: dataInicio,
        dataFim: dataFim,
        tipoDesconto: state.tipoDesconto,
        valorPercentual: state.valorPercentual,
        valorDescontoMaximo: state.valorDescontoMaximo,
        valorFixo: state.valorFixo,
        valorMinimoCompra: state.valorMinimoCompra,
        quantidadeMinima: state.quantidadeMinima,
        precoFixo: state.precoFixo,
        tipoEscopo: state.tipoEscopo,
        referenciaIds: state.referenciaIds,
        comboKit: state.comboKit,
        quantidadeLeva: state.quantidadeLeva,
        quantidadePaga: state.quantidadePaga,
        limiteUnidadesVendidas: state.limiteUnidadesVendidas,
        unidadesVendidas: state.promocao?.unidadesVendidas ?? 0,
        limiteUsosPorCliente: state.limiteUsosPorCliente,
        periodoLimiteCliente: state.periodoLimiteCliente,
        somenteAniversariante: state.somenteAniversariante,
        canal: state.canal,
        ativa: state.ativa,
        restringirFormasPagamento: state.restringirFormasPagamento,
        formasPagamento: state.formasPagamento,
        criadoEm: state.promocao?.criadoEm,
        atualizadoEm: state.promocao?.atualizadoEm,
      );

      final salvo = state.id == null
          ? await _criarPromocao.call(promocao)
          : await _atualizarPromocao.call(promocao);

      emit(
        PromocaoState.fromModel(
          salvo,
          step: state.id == null ? PromocaoStep.criado : PromocaoStep.salvo,
          formasDePagamentoDisponiveis: state.formasDePagamentoDisponiveis,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: PromocaoStep.falha,
          erro: 'Falha ao salvar promoção.',
        ),
      );
      addError(e, s);
    }
  }

  String? _validarTipoDesconto(PromocaoState state) {
    switch (state.tipoDesconto) {
      case TipoDesconto.percentual:
        if (state.valorPercentual == null) {
          return 'Informe o percentual de desconto.';
        }
        return null;
      case TipoDesconto.valorFixo:
        if (state.valorFixo == null) {
          return 'Informe o valor fixo de desconto.';
        }
        return null;
      case TipoDesconto.precoFixo:
        if (state.precoFixo == null) {
          return 'Informe o preço fixo.';
        }
        return null;
    }
  }

  String? _validarTipoEscopo(PromocaoState state) {
    switch (state.tipoEscopo) {
      case TipoEscopo.geral:
        return null;
      case TipoEscopo.referencias:
        if (state.referenciaIds == null || state.referenciaIds!.isEmpty) {
          return 'Selecione ao menos uma referência.';
        }
        return null;
      case TipoEscopo.comboKit:
        if (state.comboKit == null || state.comboKit!.isEmpty) {
          return 'Monte o combo com ao menos um item.';
        }
        return null;
      case TipoEscopo.comboLevePague:
        if (state.referenciaIds == null || state.referenciaIds!.isEmpty) {
          return 'Selecione o grupo elegível de referências.';
        }
        if (state.quantidadeLeva == null || state.quantidadeLeva! <= 0) {
          return 'Informe a quantidade que o cliente leva.';
        }
        if (state.quantidadePaga == null || state.quantidadePaga! <= 0) {
          return 'Informe a quantidade que o cliente paga.';
        }
        return null;
    }
  }
}
