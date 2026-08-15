import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/use_cases.dart' show RecuperarFormasDePagamento;
import 'package:pessoas/uses_cases.dart' show RecuperarEnderecosDaPessoa;

part 'pedido_event.dart';
part 'pedido_state.dart';

class PedidoBloc extends Bloc<PedidoEvent, PedidoState> {
  final RecuperarPedido _recuperarPedido;
  final CriarPedido _criarPedido;
  final AtualizarPedido _atualizarPedido;
  final AplicarDescontoPedido _aplicarDescontoPedido;
  final ConferirPedido _conferirPedido;
  final MarcarConferido _marcarConferido;
  final FaturarPedido _faturarPedido;
  final CancelarPedido _cancelarPedido;
  final AdicionarPagamentoPedido _adicionarPagamentoPedido;
  final RemoverPagamentoPedido _removerPagamentoPedido;
  final ListarPagamentosPedido _listarPagamentosPedido;
  final ConfirmarPagamentoPedido _confirmarPagamentoPedido;
  final AtualizarValorParaTrocoPagamentoPedido
      _atualizarValorParaTrocoPagamentoPedido;
  final ChamarEntregadorPedido _chamarEntregadorPedido;
  final ConfirmarEntregaPedido _confirmarEntregaPedido;
  final ConfirmarRetiradaPedido _confirmarRetiradaPedido;
  final ConfirmarRetiradaLotePedido _confirmarRetiradaLotePedido;
  final CriarTaxaEntregaPedido _criarTaxaEntregaPedido;
  final ListarEventosPedido _listarEventosPedido;
  final ListarItensPedido _listarItensPedido;
  final AdicionarItemPedido _adicionarItemPedido;
  final RemoverItemPedido _removerItemPedido;
  final ConferirItemPedido _conferirItemPedido;
  final ConferirItemPedidoPorCodigo _conferirItemPedidoPorCodigo;
  final AssumirPedido _assumirPedido;
  final ReenviarEmailPedido _reenviarEmailPedido;
  final EmbalarPedido _embalarPedido;
  final IAcessoGlobalSessao _acessoGlobalSessao;
  final RecuperarFormasDePagamento _recuperarFormasDePagamento;
  final RecuperarEnderecosDaPessoa _recuperarEnderecosDaPessoa;

  PedidoBloc(
    this._recuperarPedido,
    this._criarPedido,
    this._atualizarPedido,
    this._aplicarDescontoPedido,
    this._conferirPedido,
    this._marcarConferido,
    this._faturarPedido,
    this._cancelarPedido,
    this._adicionarPagamentoPedido,
    this._removerPagamentoPedido,
    this._listarPagamentosPedido,
    this._confirmarPagamentoPedido,
    this._atualizarValorParaTrocoPagamentoPedido,
    this._chamarEntregadorPedido,
    this._confirmarEntregaPedido,
    this._confirmarRetiradaPedido,
    this._confirmarRetiradaLotePedido,
    this._criarTaxaEntregaPedido,
    this._listarEventosPedido,
    this._listarItensPedido,
    this._adicionarItemPedido,
    this._removerItemPedido,
    this._conferirItemPedido,
    this._conferirItemPedidoPorCodigo,
    this._assumirPedido,
    this._reenviarEmailPedido,
    this._embalarPedido,
    this._acessoGlobalSessao,
    this._recuperarFormasDePagamento,
    this._recuperarEnderecosDaPessoa,
  ) : super(const PedidoState.initial()) {
    on<PedidoIniciou>(_onIniciou);
    on<PedidoCampoAlterado>(_onCampoAlterado);
    on<PedidoModalidadeEntregaAlterada>(_onModalidadeEntregaAlterada);
    on<PedidoEnderecoEntregaAlterado>(_onEnderecoEntregaAlterado);
    on<PedidoSalvou>(_onSalvou);
    on<PedidoDescontoAlterado>(_onDescontoAlterado);
    on<PedidoObservacaoSalva>(_onObservacaoSalva);
    on<PedidoTaxaEntregaSalva>(_onTaxaEntregaSalva);
    on<PedidoConferiu>(_onConferiu);
    on<PedidoMarcouConferido>(_onMarcouConferido);
    on<PedidoFaturou>(_onFaturou);
    on<PedidoCancelou>(_onCancelou);
    on<PedidoPagamentoAdicionou>(_onPagamentoAdicionou);
    on<PedidoPagamentoRemoveu>(_onPagamentoRemoveu);
    on<PedidoPagamentoConfirmou>(_onPagamentoConfirmou);
    on<PedidoPagamentoValorParaTrocoAtualizou>(
      _onPagamentoValorParaTrocoAtualizou,
    );
    on<PedidoEntregadorChamou>(_onEntregadorChamou);
    on<PedidoEntregaConfirmou>(_onEntregaConfirmou);
    on<PedidoRetiradaConfirmou>(_onRetiradaConfirmou);
    on<PedidoRetiradaLoteConfirmou>(_onRetiradaLoteConfirmou);
    on<PedidoTaxaEntregaCriou>(_onTaxaEntregaCriou);
    on<PedidoItemAdicionou>(_onItemAdicionou);
    on<PedidoItemRemoveu>(_onItemRemoveu);
    on<PedidoItemConferiu>(_onItemConferiu);
    on<PedidoItemConferiuPorCodigo>(_onItemConferiuPorCodigo);
    on<PedidoAssumiu>(_onAssumiu);
    on<PedidoEmailReenviou>(_onEmailReenviou);
    on<PedidoEmbalou>(_onEmbalou);
  }

  FutureOr<void> _onIniciou(
    PedidoIniciou event,
    Emitter<PedidoState> emit,
  ) async {
    try {
      emit(state.copyWith(step: PedidoStep.carregando, erro: null));

      final formasDePagamentoPorId = await _carregarFormasDePagamentoPorId();

      if (event.idPedido != null) {
        final pedido = await _recuperarPedido.call(event.idPedido!);
        final dependencias = await _carregarDependencias(pedido.id!);
        final enderecoEntregaResumo = await _carregarEnderecoEntregaResumo(
          pessoaId: pedido.pessoaId,
          enderecoEntregaId: pedido.enderecoEntregaId,
        );
        emit(
          PedidoState.fromModel(
            pedido,
            pagamentos: dependencias.$1,
            eventos: dependencias.$2,
            itens: dependencias.$3,
            formasDePagamentoPorId: formasDePagamentoPorId,
            enderecoEntregaResumo: enderecoEntregaResumo,
          ),
        );
        return;
      }

      emit(
        const PedidoState.initial().copyWith(
          dataBasePagamento: _dateOnly(DateTime.now()),
          previsaoDeFaturamento: _dateOnly(DateTime.now()),
          previsaoDeEntrega: _dateOnly(DateTime.now()),
          formasDePagamentoPorId: formasDePagamentoPorId,
          step: PedidoStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    PedidoCampoAlterado event,
    Emitter<PedidoState> emit,
  ) {
    emit(
      state.copyWith(
        pessoaId: event.pessoaId,
        funcionarioId: event.funcionarioId,
        tabelaPrecoId: event.tabelaPrecoId,
        parcelas: event.parcelas,
        intervalo: event.intervalo,
        dataBasePagamento: event.dataBasePagamento,
        previsaoDeFaturamento: event.previsaoDeFaturamento,
        previsaoDeEntrega: event.previsaoDeEntrega,
        tipo: event.tipo,
        fiscal: event.fiscal,
        observacao: event.observacao,
        valorTaxaEntrega: event.valorTaxaEntrega,
        step: PedidoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onModalidadeEntregaAlterada(
    PedidoModalidadeEntregaAlterada event,
    Emitter<PedidoState> emit,
  ) async {
    final novoEstadoLocal = state.copyWith(
      modalidadeEntrega: event.modalidadeEntrega,
      limparEnderecoEntregaId: event.modalidadeEntrega == 'retirada',
      step: PedidoStep.editando,
      erro: null,
    );

    // Pedido novo (id == null) ainda não existe no backend -- fica só no estado local, mandado
    // junto no PedidoSalvou. Pedido já existente precisa persistir na hora (mesmo padrão de
    // _onObservacaoSalva/_onTaxaEntregaSalva), senão a troca de modalidade nunca chega no servidor
    // e a situacaoEntrega nunca sai de "nao_aplicavel".
    if (state.id == null) {
      emit(novoEstadoLocal);
      return;
    }

    emit(novoEstadoLocal.copyWith(step: PedidoStep.processando));
    try {
      final pedido = _toModel(novoEstadoLocal);
      final salvo = await _atualizarPedido.call(pedido);
      emit(
        PedidoState.fromModel(
          salvo,
          step: PedidoStep.dadosSalvos,
          pagamentos: state.pagamentos,
          eventos: state.eventos,
          itens: state.itens,
          formasDePagamentoPorId: state.formasDePagamentoPorId,
          enderecoEntregaResumo:
              event.modalidadeEntrega == 'retirada' ? null : state.enderecoEntregaResumo,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(
              e, 'Falha ao salvar modalidade de entrega do pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onEnderecoEntregaAlterado(
    PedidoEnderecoEntregaAlterado event,
    Emitter<PedidoState> emit,
  ) async {
    final novoEstadoLocal = state.copyWith(
      enderecoEntregaId: event.enderecoEntregaId,
      limparEnderecoEntregaId: event.enderecoEntregaId == null,
      enderecoEntregaResumo: event.enderecoEntregaResumo,
      step: PedidoStep.editando,
      erro: null,
    );

    if (state.id == null) {
      emit(novoEstadoLocal);
      return;
    }

    emit(novoEstadoLocal.copyWith(step: PedidoStep.processando));
    try {
      final pedido = _toModel(novoEstadoLocal);
      final salvo = await _atualizarPedido.call(pedido);
      emit(
        PedidoState.fromModel(
          salvo,
          step: PedidoStep.enderecoEntregaSalvo,
          pagamentos: state.pagamentos,
          eventos: state.eventos,
          itens: state.itens,
          formasDePagamentoPorId: state.formasDePagamentoPorId,
          enderecoEntregaResumo: event.enderecoEntregaResumo,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(
              e, 'Falha ao salvar endereço de entrega do pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onSalvou(
    PedidoSalvou event,
    Emitter<PedidoState> emit,
  ) async {
    final erro = _validar(state);
    if (erro != null) {
      emit(state.copyWith(step: PedidoStep.validacaoInvalida, erro: erro));
      return;
    }

    try {
      emit(state.copyWith(step: PedidoStep.salvando, erro: null));

      final pedido = _toModel(state);
      final salvo = state.id == null
          ? await _criarPedido.call(pedido)
          : await _atualizarPedido.call(pedido);

      emit(
        PedidoState.fromModel(
          salvo,
          step: state.id == null ? PedidoStep.criado : PedidoStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao salvar pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onDescontoAlterado(
    PedidoDescontoAlterado event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _aplicarDescontoPedido.call(state.id!, desconto: event.desconto);
      await _recarregarComDependencias(emit, PedidoStep.descontoAlterado);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao aplicar desconto no pedido.')));
      addError(e, s);
    }
  }

  // Salvam só um campo isolado (via modal, ver pedido_page) num pedido já existente -- reusa
  // _toModel/_atualizarPedido igual _onSalvou, mas SEM navegar pra fora da tela ao terminar
  // (PedidoStep.dadosSalvos, não criado/salvo -- é isso que o listener da tela usa pra decidir se
  // faz Navigator.pop). Preserva pagamentos/eventos/itens/formasDePagamentoPorId já carregados,
  // igual _onConferiu/_onFaturou fazem.
  FutureOr<void> _onObservacaoSalva(
    PedidoObservacaoSalva event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      final pedido = _toModel(state.copyWith(observacao: event.observacao));
      final salvo = await _atualizarPedido.call(pedido);
      emit(
        PedidoState.fromModel(
          salvo,
          step: PedidoStep.dadosSalvos,
          pagamentos: state.pagamentos,
          eventos: state.eventos,
          itens: state.itens,
          formasDePagamentoPorId: state.formasDePagamentoPorId,
          enderecoEntregaResumo: state.enderecoEntregaResumo,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao salvar observação do pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onTaxaEntregaSalva(
    PedidoTaxaEntregaSalva event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      final pedido = _toModel(
        state.copyWith(valorTaxaEntrega: event.valorTaxaEntrega),
      );
      final salvo = await _atualizarPedido.call(pedido);
      emit(
        PedidoState.fromModel(
          salvo,
          step: PedidoStep.dadosSalvos,
          pagamentos: state.pagamentos,
          eventos: state.eventos,
          itens: state.itens,
          formasDePagamentoPorId: state.formasDePagamentoPorId,
          enderecoEntregaResumo: state.enderecoEntregaResumo,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(
              e, 'Falha ao salvar taxa de entrega do pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onConferiu(
    PedidoConferiu event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _conferirPedido.call(
        state.id!,
        processarComDivergencia: event.processarComDivergencia,
      );
      final pedido = await _recuperarPedido.call(state.id!);
      emit(PedidoState.fromModel(
        pedido,
        step: PedidoStep.conferido,
        pagamentos: state.pagamentos,
        eventos: state.eventos,
        itens: state.itens,
      ));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao conferir pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onMarcouConferido(
    PedidoMarcouConferido event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _marcarConferido.call(state.id!);
      final pedido = await _recuperarPedido.call(state.id!);
      emit(PedidoState.fromModel(
        pedido,
        step: PedidoStep.conferido,
        pagamentos: state.pagamentos,
        eventos: state.eventos,
        itens: state.itens,
      ));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao marcar conferência do pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onFaturou(
    PedidoFaturou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    final caixaId = _acessoGlobalSessao.caixaIdDaSessao;
    if (caixaId == null) {
      emit(state.copyWith(
        step: PedidoStep.falha,
        erro: 'Abra um caixa para fechar o pedido.',
      ));
      return;
    }

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _faturarPedido.call(state.id!, caixaId: caixaId);
      final pedido = await _recuperarPedido.call(state.id!);
      emit(PedidoState.fromModel(
        pedido,
        step: PedidoStep.faturado,
        pagamentos: state.pagamentos,
        eventos: state.eventos,
        itens: state.itens,
      ));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao faturar pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onCancelou(
    PedidoCancelou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    final motivo = event.motivoCancelamento.trim();
    if (motivo.isEmpty) {
      emit(
        state.copyWith(
          step: PedidoStep.validacaoInvalida,
          erro: 'Informe o motivo do cancelamento.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _cancelarPedido.call(state.id!, motivoCancelamento: motivo);
      final pedido = await _recuperarPedido.call(state.id!);
      emit(PedidoState.fromModel(
        pedido,
        step: PedidoStep.cancelado,
        pagamentos: state.pagamentos,
        eventos: state.eventos,
        itens: state.itens,
      ));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao cancelar pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onPagamentoAdicionou(
    PedidoPagamentoAdicionou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      final pagamento = await _adicionarPagamentoPedido.call(
        state.id!,
        formaDePagamentoId: event.formaDePagamentoId,
        valorEsperado: event.valorEsperado,
        taxaAplicada: event.taxaAplicada,
      );
      // Reaproveita o troco já calculado pelo PagamentosRealizadosWidget --
      // se o backend rejeitar (forma nao e dinheiro), ignora silenciosamente:
      // e um preenchimento automatico best-effort, nao uma acao explicita
      // do operador que mereça SnackBar de erro.
      if (event.valorParaTroco != null && pagamento.id != null) {
        try {
          await _atualizarValorParaTrocoPagamentoPedido.call(
            state.id!,
            pagamento.id!,
            valorParaTroco: event.valorParaTroco!,
          );
        } catch (_) {
          // best-effort, ver comentario acima
        }
      }
      await _recarregarComDependencias(
        emit,
        PedidoStep.pagamentoAdicionado,
        ultimoPagamentoAdicionado: pagamento,
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao adicionar pagamento.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onPagamentoRemoveu(
    PedidoPagamentoRemoveu event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _removerPagamentoPedido.call(state.id!, event.pagamentoId);
      await _recarregarComDependencias(emit, PedidoStep.pagamentoRemovido);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao remover pagamento.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onPagamentoConfirmou(
    PedidoPagamentoConfirmou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _confirmarPagamentoPedido.call(
        state.id!,
        event.pagamentoId,
        valorConfirmado: event.valorConfirmado,
      );
      await _recarregarComDependencias(emit, PedidoStep.pagamentoConfirmado);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao confirmar pagamento.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onPagamentoValorParaTrocoAtualizou(
    PedidoPagamentoValorParaTrocoAtualizou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _atualizarValorParaTrocoPagamentoPedido.call(
        state.id!,
        event.pagamentoId,
        valorParaTroco: event.valorParaTroco,
      );
      await _recarregarComDependencias(
        emit,
        PedidoStep.pagamentoValorParaTrocoAtualizado,
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(
              e, 'Falha ao informar valor para troco.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onEntregadorChamou(
    PedidoEntregadorChamou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _chamarEntregadorPedido.call(state.id!);
      await _recarregarComDependencias(emit, PedidoStep.entregadorChamado);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao chamar entregador.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onEntregaConfirmou(
    PedidoEntregaConfirmou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _confirmarEntregaPedido.call(state.id!);
      await _recarregarComDependencias(emit, PedidoStep.entregaConfirmada);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao confirmar entrega.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onRetiradaConfirmou(
    PedidoRetiradaConfirmou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      final (pedido, outrosPedidosPendentes) =
          await _confirmarRetiradaPedido.call(state.id!, event.codigo);
      final dependencias = await _carregarDependencias(pedido.id!);
      emit(
        PedidoState.fromModel(
          pedido,
          step: PedidoStep.retiradaConfirmada,
          pagamentos: dependencias.$1,
          eventos: dependencias.$2,
          itens: dependencias.$3,
        ).copyWith(outrosPedidosPendentes: outrosPedidosPendentes),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao confirmar retirada.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onRetiradaLoteConfirmou(
    PedidoRetiradaLoteConfirmou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _confirmarRetiradaLotePedido.call(event.pedidoIds);
      await _recarregarComDependencias(
        emit,
        PedidoStep.retiradaLoteConfirmada,
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao confirmar retirada em lote.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onTaxaEntregaCriou(
    PedidoTaxaEntregaCriou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      final novoPedido = await _criarTaxaEntregaPedido.call(
        state.id!,
        valorTaxaEntrega: event.valorTaxaEntrega,
        enderecoEntregaId: event.enderecoEntregaId,
      );
      emit(
        state.copyWith(
          step: PedidoStep.taxaEntregaCriada,
          pedidoTaxaEntregaCriadoId: novoPedido.id,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao converter pedido em entrega.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onItemAdicionou(
    PedidoItemAdicionou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _adicionarItemPedido.call(
        state.id!,
        produtoId: event.produtoId,
        quantidade: event.quantidade,
      );
      final itens = await _listarItensPedido.call(state.id!);
      emit(state.copyWith(itens: itens, step: PedidoStep.itemAdicionado));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao adicionar item.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onItemRemoveu(
    PedidoItemRemoveu event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _removerItemPedido.call(
        state.id!,
        produtoId: event.produtoId,
        sequencia: event.sequencia,
        quantidade: event.quantidade,
      );
      final itens = await _listarItensPedido.call(state.id!);
      emit(state.copyWith(itens: itens, step: PedidoStep.itemRemovido));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao remover item.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onItemConferiu(
    PedidoItemConferiu event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _conferirItemPedido.call(
        state.id!,
        produtoId: event.produtoId,
        sequencia: event.sequencia,
        quantidade: event.quantidade,
      );
      final itens = await _listarItensPedido.call(state.id!);
      emit(state.copyWith(itens: itens, step: PedidoStep.itemConferido));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao conferir item.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onItemConferiuPorCodigo(
    PedidoItemConferiuPorCodigo event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _conferirItemPedidoPorCodigo.call(
        state.id!,
        codigoBarras: event.codigoBarras,
        quantidade: event.quantidade,
      );
      final itens = await _listarItensPedido.call(state.id!);
      emit(state.copyWith(itens: itens, step: PedidoStep.itemConferido));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao conferir item por código.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onAssumiu(
    PedidoAssumiu event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _assumirPedido.call(state.id!, funcionarioId: event.funcionarioId);
      await _recarregarComDependencias(emit, PedidoStep.dadosSalvos);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao assumir pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onEmailReenviou(
    PedidoEmailReenviou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _reenviarEmailPedido.call(state.id!);
      emit(state.copyWith(step: PedidoStep.emailReenviado));
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao reenviar e-mail do pedido.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onEmbalou(
    PedidoEmbalou event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _embalarPedido.call(state.id!);
      await _recarregarComDependencias(emit, PedidoStep.embalado);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao marcar pedido como embalado.')));
      addError(e, s);
    }
  }

  Future<void> _recarregarComDependencias(
    Emitter<PedidoState> emit,
    PedidoStep step, {
    PedidoPagamento? ultimoPagamentoAdicionado,
  }) async {
    final pedido = await _recuperarPedido.call(state.id!);
    final dependencias = await _carregarDependencias(pedido.id!);
    emit(
      PedidoState.fromModel(
        pedido,
        step: step,
        pagamentos: dependencias.$1,
        eventos: dependencias.$2,
        itens: dependencias.$3,
      ).copyWith(ultimoPagamentoAdicionado: ultimoPagamentoAdicionado),
    );
  }

  Future<(List<PedidoPagamento>, List<PedidoEvento>, List<PedidoItem>)>
      _carregarDependencias(int id) async {
    final itens = await _carregarItens(id);
    try {
      final pagamentos = await _listarPagamentosPedido.call(id);
      final eventos = await _listarEventosPedido.call(id);
      return (pagamentos, eventos, itens);
    } catch (_) {
      return (const <PedidoPagamento>[], const <PedidoEvento>[], itens);
    }
  }

  Future<List<PedidoItem>> _carregarItens(int id) async {
    try {
      return await _listarItensPedido.call(id);
    } catch (_) {
      return const <PedidoItem>[];
    }
  }

  Future<String?> _carregarEnderecoEntregaResumo({
    int? pessoaId,
    int? enderecoEntregaId,
  }) async {
    if (pessoaId == null || enderecoEntregaId == null) return null;

    try {
      final enderecos = await _recuperarEnderecosDaPessoa.call(
        idPessoa: pessoaId,
      );
      final encontrados = enderecos.where(
        (endereco) => endereco.id == enderecoEntregaId,
      );
      if (encontrados.isEmpty) return null;
      final endereco = encontrados.first;

      final numero = endereco.numero.trim();
      final complemento = endereco.complemento.trim();
      final linha1 = StringBuffer(endereco.logradouro.trim());
      if (numero.isNotEmpty) linha1.write(', $numero');
      if (complemento.isNotEmpty) linha1.write(' - $complemento');

      return '$linha1 - ${endereco.bairro.trim()}';
    } catch (_) {
      return null;
    }
  }

  Future<Map<int, String>> _carregarFormasDePagamentoPorId() async {
    try {
      final formas = await _recuperarFormasDePagamento.call();
      return {
        for (final forma in formas)
          if (forma.id != null) forma.id!: forma.descricao,
      };
    } catch (_) {
      return const {};
    }
  }

  String? _validar(PedidoState state) {
    if ((state.pessoaId ?? '').trim().isEmpty ||
        (state.funcionarioId ?? '').trim().isEmpty ||
        (state.tabelaPrecoId ?? '').trim().isEmpty ||
        (state.dataBasePagamento ?? '').trim().isEmpty ||
        (state.previsaoDeFaturamento ?? '').trim().isEmpty ||
        (state.previsaoDeEntrega ?? '').trim().isEmpty) {
      return 'Preencha os campos obrigatorios.';
    }

    if (int.tryParse(state.parcelas ?? '') == null ||
        int.tryParse(state.intervalo ?? '') == null) {
      return 'Parcelas e intervalo devem ser numericos.';
    }

    if (DateTime.tryParse(state.dataBasePagamento ?? '') == null ||
        DateTime.tryParse(state.previsaoDeFaturamento ?? '') == null ||
        DateTime.tryParse(state.previsaoDeEntrega ?? '') == null) {
      return 'As datas devem estar no formato YYYY-MM-DD.';
    }

    if (state.modalidadeEntrega == 'entrega' &&
        state.enderecoEntregaId == null) {
      return 'Selecione o endereço de entrega.';
    }

    return null;
  }

  Pedido _toModel(PedidoState state) {
    return Pedido.create(
      id: state.id,
      pessoaId: int.tryParse(state.pessoaId ?? ''),
      funcionarioId: int.tryParse(state.funcionarioId ?? ''),
      tabelaPrecoId: int.tryParse(state.tabelaPrecoId ?? ''),
      parcelas: int.tryParse(state.parcelas ?? ''),
      intervalo: int.tryParse(state.intervalo ?? ''),
      dataBasePagamento: DateTime.tryParse(state.dataBasePagamento ?? ''),
      previsaoDeFaturamento:
          DateTime.tryParse(state.previsaoDeFaturamento ?? ''),
      previsaoDeEntrega: DateTime.tryParse(state.previsaoDeEntrega ?? ''),
      tipo: state.tipo,
      fiscal: state.fiscal,
      observacao: state.observacao?.trim(),
      criadoEm: state.pedido?.criadoEm,
      atualizadoEm: state.pedido?.atualizadoEm,
      situacao: state.pedido?.situacao,
      motivoCancelamento: state.pedido?.motivoCancelamento,
      modalidadeEntrega: state.modalidadeEntrega,
      enderecoEntregaId: state.enderecoEntregaId,
      valorTaxaEntrega: state.modalidadeEntrega == 'entrega'
          ? double.tryParse(
              (state.valorTaxaEntrega ?? '').replaceAll(',', '.'),
            )
          : null,
    );
  }

  String _dateOnly(DateTime value) {
    return value.toIso8601String().split('T').first;
  }
}
