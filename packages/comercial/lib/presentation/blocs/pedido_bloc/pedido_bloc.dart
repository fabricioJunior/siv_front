import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sessao.dart';

part 'pedido_event.dart';
part 'pedido_state.dart';

class PedidoBloc extends Bloc<PedidoEvent, PedidoState> {
  final RecuperarPedido _recuperarPedido;
  final CriarPedido _criarPedido;
  final AtualizarPedido _atualizarPedido;
  final ConferirPedido _conferirPedido;
  final FaturarPedido _faturarPedido;
  final CancelarPedido _cancelarPedido;
  final AdicionarPagamentoPedido _adicionarPagamentoPedido;
  final ListarPagamentosPedido _listarPagamentosPedido;
  final ConfirmarPagamentoPedido _confirmarPagamentoPedido;
  final ChamarEntregadorPedido _chamarEntregadorPedido;
  final ConfirmarEntregaPedido _confirmarEntregaPedido;
  final CriarTaxaEntregaPedido _criarTaxaEntregaPedido;
  final ListarEventosPedido _listarEventosPedido;
  final ListarItensPedido _listarItensPedido;
  final AdicionarItemPedido _adicionarItemPedido;
  final RemoverItemPedido _removerItemPedido;
  final ConferirItemPedido _conferirItemPedido;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  PedidoBloc(
    this._recuperarPedido,
    this._criarPedido,
    this._atualizarPedido,
    this._conferirPedido,
    this._faturarPedido,
    this._cancelarPedido,
    this._adicionarPagamentoPedido,
    this._listarPagamentosPedido,
    this._confirmarPagamentoPedido,
    this._chamarEntregadorPedido,
    this._confirmarEntregaPedido,
    this._criarTaxaEntregaPedido,
    this._listarEventosPedido,
    this._listarItensPedido,
    this._adicionarItemPedido,
    this._removerItemPedido,
    this._conferirItemPedido,
    this._acessoGlobalSessao,
  ) : super(const PedidoState.initial()) {
    on<PedidoIniciou>(_onIniciou);
    on<PedidoCampoAlterado>(_onCampoAlterado);
    on<PedidoModalidadeEntregaAlterada>(_onModalidadeEntregaAlterada);
    on<PedidoEnderecoEntregaAlterado>(_onEnderecoEntregaAlterado);
    on<PedidoSalvou>(_onSalvou);
    on<PedidoConferiu>(_onConferiu);
    on<PedidoFaturou>(_onFaturou);
    on<PedidoCancelou>(_onCancelou);
    on<PedidoPagamentoAdicionou>(_onPagamentoAdicionou);
    on<PedidoPagamentoConfirmou>(_onPagamentoConfirmou);
    on<PedidoEntregadorChamou>(_onEntregadorChamou);
    on<PedidoEntregaConfirmou>(_onEntregaConfirmou);
    on<PedidoTaxaEntregaCriou>(_onTaxaEntregaCriou);
    on<PedidoItemAdicionou>(_onItemAdicionou);
    on<PedidoItemRemoveu>(_onItemRemoveu);
    on<PedidoItemConferiu>(_onItemConferiu);
  }

  FutureOr<void> _onIniciou(
    PedidoIniciou event,
    Emitter<PedidoState> emit,
  ) async {
    try {
      emit(state.copyWith(step: PedidoStep.carregando, erro: null));

      if (event.idPedido != null) {
        final pedido = await _recuperarPedido.call(event.idPedido!);
        final dependencias = await _carregarDependencias(pedido.id!);
        emit(
          PedidoState.fromModel(
            pedido,
            pagamentos: dependencias.$1,
            eventos: dependencias.$2,
            itens: dependencias.$3,
          ),
        );
        return;
      }

      emit(
        const PedidoState.initial().copyWith(
          dataBasePagamento: _dateOnly(DateTime.now()),
          previsaoDeFaturamento: _dateOnly(DateTime.now()),
          previsaoDeEntrega: _dateOnly(DateTime.now()),
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
        step: PedidoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onModalidadeEntregaAlterada(
    PedidoModalidadeEntregaAlterada event,
    Emitter<PedidoState> emit,
  ) {
    emit(
      state.copyWith(
        modalidadeEntrega: event.modalidadeEntrega,
        limparEnderecoEntregaId: event.modalidadeEntrega == 'retirada',
        step: PedidoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onEnderecoEntregaAlterado(
    PedidoEnderecoEntregaAlterado event,
    Emitter<PedidoState> emit,
  ) {
    emit(
      state.copyWith(
        enderecoEntregaId: event.enderecoEntregaId,
        limparEnderecoEntregaId: event.enderecoEntregaId == null,
        step: PedidoStep.editando,
        erro: null,
      ),
    );
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

  FutureOr<void> _onConferiu(
    PedidoConferiu event,
    Emitter<PedidoState> emit,
  ) async {
    if (state.id == null) return;

    try {
      emit(state.copyWith(step: PedidoStep.processando, erro: null));
      await _conferirPedido.call(state.id!);
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
      await _adicionarPagamentoPedido.call(
        state.id!,
        tipo: event.tipo,
        pagamentoAvulsoId: event.pagamentoAvulsoId,
        formaPagamento: event.formaPagamento,
        valorEsperado: event.valorEsperado,
      );
      await _recarregarComDependencias(emit, PedidoStep.pagamentoAdicionado);
    } catch (e, s) {
      emit(state.copyWith(
          step: PedidoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao adicionar pagamento.')));
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

  Future<void> _recarregarComDependencias(
    Emitter<PedidoState> emit,
    PedidoStep step,
  ) async {
    final pedido = await _recuperarPedido.call(state.id!);
    final dependencias = await _carregarDependencias(pedido.id!);
    emit(
      PedidoState.fromModel(
        pedido,
        step: step,
        pagamentos: dependencias.$1,
        eventos: dependencias.$2,
        itens: dependencias.$3,
      ),
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
    );
  }

  String _dateOnly(DateTime value) {
    return value.toIso8601String().split('T').first;
  }
}
