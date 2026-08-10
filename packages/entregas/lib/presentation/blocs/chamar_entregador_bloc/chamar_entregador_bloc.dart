import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sessao.dart';
import 'package:empresas/models.dart';
import 'package:empresas/use_cases.dart';
import 'package:entregas/data/remote/dtos/entrega_dto.dart';
import 'package:entregas/domain/models/entrega.dart';
import 'package:entregas/use_cases.dart';

part 'chamar_entregador_event.dart';
part 'chamar_entregador_state.dart';

/// Backend ainda não expõe endpoint de listagem de categorias de entrega —
/// usa categoria padrão única até existir seleção de veículo/categoria.
const categoriaEntregaPadraoId = 1;
const categoriaEntregaPadraoNome = 'Padrão';

class ChamarEntregadorBloc
    extends Bloc<ChamarEntregadorEvent, ChamarEntregadorState> {
  final ObterSaldoEntrega _obterSaldo;
  final EstimarEntrega _estimar;
  final AbrirSolicitacaoEntrega _abrirSolicitacao;
  final ObterRastreioEntrega _obterRastreio;
  final CancelarSolicitacaoEntrega _cancelarSolicitacao;
  final RecuperarEmpresa _recuperarEmpresa;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  ChamarEntregadorBloc(
    this._obterSaldo,
    this._estimar,
    this._abrirSolicitacao,
    this._obterRastreio,
    this._cancelarSolicitacao,
    this._recuperarEmpresa,
    this._acessoGlobalSessao,
  ) : super(const ChamarEntregadorState.initial()) {
    on<ChamarEntregadorIniciou>(_onIniciou);
    on<ChamarEntregadorEstimou>(_onEstimou);
    on<ChamarEntregadorChamou>(_onChamou);
    on<ChamarEntregadorObterRastreio>(_onObterRastreio);
    on<ChamarEntregadorCancelou>(_onCancelou);
  }

  FutureOr<void> _onIniciou(
    ChamarEntregadorIniciou event,
    Emitter<ChamarEntregadorState> emit,
  ) async {
    try {
      final saldo = await _obterSaldo.call();
      emit(state.copyWith(saldo: saldo));
    } catch (e, s) {
      addError(e, s);
    }

    final empresaId = _acessoGlobalSessao.empresaIdDaSessao;
    if (empresaId == null) return;

    try {
      final empresa = await _recuperarEmpresa.call(empresaId);
      if (empresa == null) return;

      EnderecoEntrega? partida;
      if (empresa.latitude != null && empresa.longitude != null) {
        partida = EnderecoEntregaDto(
          endereco: [empresa.logradouro, empresa.numero]
              .where((v) => v != null && v.isNotEmpty)
              .join(', '),
          bairro: empresa.bairro ?? '',
          cidade: empresa.municipio ?? '',
          estado: empresa.uf ?? '',
          lat: empresa.latitude!,
          lng: empresa.longitude!,
        );
      }

      emit(state.copyWith(empresa: empresa, partida: partida));
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onEstimou(
    ChamarEntregadorEstimou event,
    Emitter<ChamarEntregadorState> emit,
  ) async {
    try {
      emit(state.copyWith(
        step: ChamarEntregadorStep.estimando,
        erro: null,
      ));
      final estimativa = await _estimar.call(
        partida: event.partida,
        destino: event.destino,
        categoriaId: categoriaEntregaPadraoId,
        categoriaNome: categoriaEntregaPadraoNome,
      );
      emit(state.copyWith(
        step: ChamarEntregadorStep.estimado,
        estimativa: estimativa,
        partida: event.partida,
        destino: event.destino,
        parada: event.parada,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ChamarEntregadorStep.falha,
        erro: mensagemDeErroApi(e, 'Falha ao calcular a entrega.'),
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onChamou(
    ChamarEntregadorChamou event,
    Emitter<ChamarEntregadorState> emit,
  ) async {
    final partida = state.partida;
    final parada = state.parada;
    final estimativa = state.estimativa;
    if (partida == null || parada == null) return;

    try {
      emit(state.copyWith(step: ChamarEntregadorStep.chamando, erro: null));
      final solicitacao = await _abrirSolicitacao.call(
        categoriaId: categoriaEntregaPadraoId,
        categoriaNome: categoriaEntregaPadraoNome,
        partida: partida,
        paradas: [parada],
        valorEstimado: estimativa?.valor,
      );
      emit(state.copyWith(
        step: ChamarEntregadorStep.chamado,
        solicitacao: solicitacao,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ChamarEntregadorStep.falha,
        erro: mensagemDeErroApi(e, 'Falha ao chamar o entregador.'),
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onObterRastreio(
    ChamarEntregadorObterRastreio event,
    Emitter<ChamarEntregadorState> emit,
  ) async {
    final solicitacao = state.solicitacao;
    if (solicitacao == null) return;

    try {
      emit(state.copyWith(
        step: ChamarEntregadorStep.obtendoRastreio,
        erro: null,
      ));
      final rastreio = await _obterRastreio.call(solicitacao.id);
      emit(state.copyWith(
        step: ChamarEntregadorStep.chamado,
        rastreio: rastreio,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ChamarEntregadorStep.chamado,
        erro: mensagemDeErroApi(e, 'Falha ao obter o rastreio.'),
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onCancelou(
    ChamarEntregadorCancelou event,
    Emitter<ChamarEntregadorState> emit,
  ) async {
    final solicitacao = state.solicitacao;
    if (solicitacao == null) return;

    try {
      emit(state.copyWith(step: ChamarEntregadorStep.cancelando, erro: null));
      final atualizada = await _cancelarSolicitacao.call(
        solicitacao.id,
        motivoId: event.motivoId,
      );
      emit(state.copyWith(
        step: ChamarEntregadorStep.cancelado,
        solicitacao: atualizada,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ChamarEntregadorStep.chamado,
        erro: mensagemDeErroApi(e, 'Falha ao cancelar a entrega.'),
      ));
      addError(e, s);
    }
  }
}
