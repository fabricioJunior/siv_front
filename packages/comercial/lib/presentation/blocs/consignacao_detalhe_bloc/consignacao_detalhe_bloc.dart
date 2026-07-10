import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'consignacao_detalhe_event.dart';
part 'consignacao_detalhe_state.dart';

class ConsignacaoDetalheBloc
    extends Bloc<ConsignacaoDetalheEvent, ConsignacaoDetalheState> {
  final RecuperarConsignacao _recuperarConsignacao;
  final RecalcularConsignacao _recalcularConsignacao;
  final FecharConsignacao _fecharConsignacao;
  final CancelarConsignacao _cancelarConsignacao;

  int? _idAtual;

  ConsignacaoDetalheBloc(
    this._recuperarConsignacao,
    this._recalcularConsignacao,
    this._fecharConsignacao,
    this._cancelarConsignacao,
  ) : super(const ConsignacaoDetalheState()) {
    on<ConsignacaoDetalheCarregarSolicitado>(_onCarregarSolicitado);
    on<ConsignacaoDetalheFecharSolicitado>(_onFecharSolicitado);
    on<ConsignacaoDetalheCancelarSolicitado>(_onCancelarSolicitado);
  }

  FutureOr<void> _onCarregarSolicitado(
    ConsignacaoDetalheCarregarSolicitado event,
    Emitter<ConsignacaoDetalheState> emit,
  ) async {
    _idAtual = event.id;
    emit(state.copyWith(step: ConsignacaoDetalheStep.carregando, erro: null));

    try {
      await _recalcularConsignacao.call(event.id);
      final consignacao =
          await _recuperarConsignacao.call(event.id, incluirItens: true);
      emit(
        state.copyWith(
          step: ConsignacaoDetalheStep.sucesso,
          consignacao: consignacao,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ConsignacaoDetalheStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar a consignação.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onFecharSolicitado(
    ConsignacaoDetalheFecharSolicitado event,
    Emitter<ConsignacaoDetalheState> emit,
  ) async {
    final id = _idAtual;
    if (id == null) return;

    emit(state.copyWith(processando: true, erro: null));

    try {
      await _fecharConsignacao.call(id);
      final consignacao =
          await _recuperarConsignacao.call(id, incluirItens: true);
      emit(
        state.copyWith(
          processando: false,
          consignacao: consignacao,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          processando: false,
          erro: mensagemDeErroApi(e, 'Falha ao fechar a consignação.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onCancelarSolicitado(
    ConsignacaoDetalheCancelarSolicitado event,
    Emitter<ConsignacaoDetalheState> emit,
  ) async {
    final id = _idAtual;
    if (id == null) return;

    emit(state.copyWith(processando: true, erro: null));

    try {
      await _cancelarConsignacao.call(
        id: id,
        motivoCancelamento: event.motivoCancelamento,
      );
      final consignacao =
          await _recuperarConsignacao.call(id, incluirItens: true);
      emit(
        state.copyWith(
          processando: false,
          consignacao: consignacao,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          processando: false,
          erro: mensagemDeErroApi(e, 'Falha ao cancelar a consignação.'),
        ),
      );
      addError(e, s);
    }
  }
}
