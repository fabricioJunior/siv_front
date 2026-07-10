import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/use_cases.dart';

part 'consignacao_acerto_event.dart';
part 'consignacao_acerto_state.dart';

class ConsignacaoAcertoBloc
    extends Bloc<ConsignacaoAcertoEvent, ConsignacaoAcertoState> {
  final CriarRomaneio _criarRomaneio;
  final AdicionarItemRomaneio _adicionarItemRomaneio;
  final ReceberRomaneioNoCaixa _receberRomaneioNoCaixa;
  final RecuperarCaixaAberto _recuperarCaixaAberto;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  final int consignacaoId;
  final int? funcionarioId;
  final int? tabelaPrecoId;
  final List<ConsignacaoItem> itensPendentes;
  final List<int> romaneiosOrigem;

  ConsignacaoAcertoBloc(
    this._criarRomaneio,
    this._adicionarItemRomaneio,
    this._receberRomaneioNoCaixa,
    this._recuperarCaixaAberto,
    this._acessoGlobalSessao, {
    required this.consignacaoId,
    this.funcionarioId,
    this.tabelaPrecoId,
    required this.itensPendentes,
    required this.romaneiosOrigem,
  }) : super(const ConsignacaoAcertoState()) {
    on<ConsignacaoAcertoIniciado>(_onIniciado);
    on<ConsignacaoAcertoPagamentoConfirmado>(_onPagamentoConfirmado);
  }

  FutureOr<void> _onIniciado(
    ConsignacaoAcertoIniciado event,
    Emitter<ConsignacaoAcertoState> emit,
  ) async {
    emit(state.copyWith(step: ConsignacaoAcertoStep.processando, erro: null));

    final itens = itensPendentes
        .where((item) => (item.pendente ?? 0) > 0 && item.produtoId != null)
        .map((item) {
      final pendente = item.pendente ?? 0;
      final valorPendenteItem = item.valorPendente ?? 0;
      final valorUnitario = pendente > 0 ? valorPendenteItem / pendente : 0.0;
      return RomaneioItem.create(
        produtoId: item.produtoId,
        quantidade: pendente,
        valorUnitario: valorUnitario,
      );
    }).toList(growable: false);

    if (itens.isEmpty) {
      emit(
        state.copyWith(
          step: ConsignacaoAcertoStep.falha,
          erro: 'Não há itens pendentes para acertar nesta consignação.',
        ),
      );
      return;
    }

    try {
      final romaneioCriado = await _criarRomaneio.call(
        Romaneio.create(
          funcionarioId: funcionarioId,
          tabelaPrecoId: tabelaPrecoId,
          operacao: TipoOperacao.consignacao_acerto,
          consignacaoId: consignacaoId,
          romaneiosConsignacao: romaneiosOrigem,
        ),
      );

      final romaneioId = romaneioCriado.id;
      if (romaneioId == null) {
        throw StateError('A API não retornou o id do romaneio de acerto.');
      }

      for (final item in itens) {
        await _adicionarItemRomaneio.call(romaneioId: romaneioId, item: item);
      }

      emit(
        state.copyWith(
          step: ConsignacaoAcertoStep.aguardandoPagamento,
          romaneio: romaneioCriado,
          itens: itens,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ConsignacaoAcertoStep.falha,
          erro: mensagemDeErroApi(
            e,
            'Falha ao gerar o romaneio de acerto da consignação.',
          ),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onPagamentoConfirmado(
    ConsignacaoAcertoPagamentoConfirmado event,
    Emitter<ConsignacaoAcertoState> emit,
  ) async {
    final romaneioId = state.romaneio?.id;
    if (romaneioId == null) return;

    emit(state.copyWith(step: ConsignacaoAcertoStep.finalizando, erro: null));

    try {
      final empresaId = _acessoGlobalSessao.empresaIdDaSessao;
      final terminalId = _acessoGlobalSessao.terminalIdDaSessao;
      if (empresaId == null || terminalId == null) {
        throw StateError(
          'Sessão sem empresa/terminal definidos. Faça login novamente.',
        );
      }

      final caixa = await _recuperarCaixaAberto.call(
        idEmpresa: empresaId,
        idTerminal: terminalId,
      );

      if (caixa == null) {
        throw StateError(
          'Nenhum caixa aberto para este terminal. Abra um caixa antes de continuar.',
        );
      }

      final formasDePagamentoRealizadas = _extrairFormasDePagamento(
        event.formasDePagamentoRealizadas,
      );

      await _receberRomaneioNoCaixa.call(
        caixaId: caixa.id,
        romaneioId: romaneioId,
        formasDePagamentoRealizadas: formasDePagamentoRealizadas,
        descontosItens: event.descontosItens,
        incluirCpfNaNota: event.incluirCpfNaNota,
        cpfNaNota: event.cpfNaNota,
      );

      emit(state.copyWith(step: ConsignacaoAcertoStep.sucesso, erro: null));
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ConsignacaoAcertoStep.aguardandoPagamento,
          erro: mensagemDeErroApi(
            e,
            'Romaneio #$romaneioId criado, mas não foi possível concluir o recebimento no caixa.',
          ),
        ),
      );
      addError(e, s);
    }
  }

  List<RomaneioPagamentoRealizado> _extrairFormasDePagamento(
    List<Map<String, dynamic>> formas,
  ) {
    return formas
        .map((item) {
          final formaDePagamentoId = _toInt(item['formaDePagamentoId']);
          final valor = _toDouble(item['valor']);
          final parcela = _toInt(item['parcela']) ?? 1;
          final controle = _toInt(item['controle']) ?? 0;

          if (formaDePagamentoId == null || formaDePagamentoId <= 0) {
            return null;
          }
          if (valor == null || valor <= 0) {
            return null;
          }

          return RomaneioPagamentoRealizado.create(
            controle: controle > 0 ? controle : 1,
            formaDePagamentoId: formaDePagamentoId,
            parcela: parcela > 0 ? parcela : 1,
            valor: valor,
          );
        })
        .whereType<RomaneioPagamentoRealizado>()
        .toList(growable: false);
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
