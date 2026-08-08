import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:promocoes/domain/models/cupom.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';
import 'package:promocoes/use_cases.dart';

part 'cupom_event.dart';
part 'cupom_state.dart';

class CupomBloc extends Bloc<CupomEvent, CupomState> {
  final RecuperarCupom _recuperarCupom;
  final CriarCupom _criarCupom;
  final AtualizarCupom _atualizarCupom;

  CupomBloc(
    this._recuperarCupom,
    this._criarCupom,
    this._atualizarCupom,
  ) : super(const CupomState(step: CupomStep.inicial)) {
    on<CupomIniciou>(_onIniciou);
    on<CupomCampoAlterado>(_onCampoAlterado);
    on<CupomSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    CupomIniciou event,
    Emitter<CupomState> emit,
  ) async {
    try {
      emit(state.copyWith(step: CupomStep.carregando));

      if (event.idCupom != null) {
        final cupom = await _recuperarCupom.call(event.idCupom!);

        if (cupom == null) {
          emit(state.copyWith(step: CupomStep.falha));
          return;
        }

        emit(CupomState.fromModel(cupom));
        return;
      }

      emit(
        const CupomState(
          codigo: '',
          tipoDesconto: TipoDesconto.percentual,
          tipoEscopo: TipoEscopo.geral,
          step: CupomStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: CupomStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    CupomCampoAlterado event,
    Emitter<CupomState> emit,
  ) {
    emit(
      state.copyWith(
        codigo: event.codigo,
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
        limiteUsos: event.limiteUsos,
        ativa: event.ativa,
        step: CupomStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(CupomSalvou event, Emitter<CupomState> emit) async {
    try {
      final codigo = state.codigo?.trim() ?? '';
      final dataInicio = state.dataInicio;
      final dataFim = state.dataFim;

      if (codigo.isEmpty || dataInicio == null || dataFim == null) {
        emit(
          state.copyWith(
            step: CupomStep.validacaoInvalida,
            erro: 'Preencha código, data de início e data de fim.',
          ),
        );
        return;
      }

      if (dataFim.isBefore(dataInicio)) {
        emit(
          state.copyWith(
            step: CupomStep.validacaoInvalida,
            erro: 'A data de fim não pode ser anterior à data de início.',
          ),
        );
        return;
      }

      final erroDesconto = _validarTipoDesconto(state);
      if (erroDesconto != null) {
        emit(
          state.copyWith(
            step: CupomStep.validacaoInvalida,
            erro: erroDesconto,
          ),
        );
        return;
      }

      final erroEscopo = _validarTipoEscopo(state);
      if (erroEscopo != null) {
        emit(
          state.copyWith(
            step: CupomStep.validacaoInvalida,
            erro: erroEscopo,
          ),
        );
        return;
      }

      emit(state.copyWith(step: CupomStep.salvando, erro: null));

      final cupom = Cupom.create(
        id: state.id,
        empresaId: state.cupom?.empresaId,
        codigo: codigo.toUpperCase(),
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
        limiteUsos: state.limiteUsos,
        usosRealizados: state.cupom?.usosRealizados ?? 0,
        ativa: state.ativa,
        criadoEm: state.cupom?.criadoEm,
        atualizadoEm: state.cupom?.atualizadoEm,
      );

      final salvo = state.id == null
          ? await _criarCupom.call(cupom)
          : await _atualizarCupom.call(cupom);

      emit(
        CupomState.fromModel(
          salvo,
          step: state.id == null ? CupomStep.criado : CupomStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: CupomStep.falha,
          erro: 'Falha ao salvar cupom.',
        ),
      );
      addError(e, s);
    }
  }

  String? _validarTipoDesconto(CupomState state) {
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

  String? _validarTipoEscopo(CupomState state) {
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
