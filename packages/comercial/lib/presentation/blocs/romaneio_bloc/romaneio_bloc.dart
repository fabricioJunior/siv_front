import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';

part 'romaneio_event.dart';
part 'romaneio_state.dart';

class RomaneioBloc extends Bloc<RomaneioEvent, RomaneioState> {
  final RecuperarRomaneio _recuperarRomaneio;
  final RecuperarItensRomaneio _recuperarItensRomaneio;
  final CriarRomaneio _criarRomaneio;
  final AtualizarRomaneio _atualizarRomaneio;
  final AtualizarObservacaoRomaneio _atualizarObservacaoRomaneio;
  final RecuperarListaDeProdutosCompartilhada
      _recuperarListaDeProdutosCompartilhada;
  final AdicionarItemRomaneio _adicionarItemRomaneio;
  final RemoverProdutoCompartilhado _removerProdutoCompartilhado;

  RomaneioBloc(
    this._recuperarRomaneio,
    this._recuperarItensRomaneio,
    this._criarRomaneio,
    this._atualizarRomaneio,
    this._atualizarObservacaoRomaneio,
    this._recuperarListaDeProdutosCompartilhada,
    this._adicionarItemRomaneio,
    this._removerProdutoCompartilhado,
  ) : super(const RomaneioState.initial()) {
    on<RomaneioIniciou>(_onIniciou);
    on<RomaneioCampoAlterado>(_onCampoAlterado);
    on<RomaneioSalvou>(_onSalvou);
    on<RomaneioObservacaoAtualizada>(_onObservacaoAtualizada);
    on<RomaneioContinuarEnvioSolicitado>(_onContinuarEnvioSolicitado);
  }

  FutureOr<void> _onIniciou(
    RomaneioIniciou event,
    Emitter<RomaneioState> emit,
  ) async {
    try {
      emit(state.copyWith(step: RomaneioStep.carregando, erro: null));

      if (event.idRomaneio != null) {
        final romaneio = await _recuperarRomaneio.call(event.idRomaneio!);
        final itens = await _recuperarItensRomaneio.call(event.idRomaneio!);
        final pendencia = await _carregarPendenciaDeEnvio(event.idRomaneio!);
        emit(
          RomaneioState.fromModel(romaneio, itensDoRomaneio: itens).copyWith(
            possuiPendenciaDeEnvio: pendencia.$1,
            quantidadeItensPendentes: pendencia.$2,
            hashListaPendente: pendencia.$3,
          ),
        );
        return;
      }

      emit(const RomaneioState.initial().copyWith(step: RomaneioStep.editando));
    } catch (e, s) {
      emit(state.copyWith(
          step: RomaneioStep.falha, erro: 'Falha ao carregar romaneio.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    RomaneioCampoAlterado event,
    Emitter<RomaneioState> emit,
  ) {
    emit(
      state.copyWith(
        pessoaId: event.pessoaId,
        funcionarioId: event.funcionarioId,
        tabelaPrecoId: event.tabelaPrecoId,
        operacao: event.operacao,
        observacao: event.observacao,
        step: RomaneioStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    RomaneioSalvou event,
    Emitter<RomaneioState> emit,
  ) async {
    final erro = _validarCadastro(state);
    if (erro != null) {
      emit(state.copyWith(step: RomaneioStep.validacaoInvalida, erro: erro));
      return;
    }

    try {
      emit(state.copyWith(step: RomaneioStep.salvando, erro: null));

      final romaneio = _toModel(state);
      final salvo = state.id == null
          ? await _criarRomaneio.call(romaneio)
          : await _atualizarRomaneio.call(romaneio);

      emit(
        RomaneioState.fromModel(
          salvo,
          itensDoRomaneio: state.itens,
          step: state.id == null ? RomaneioStep.criado : RomaneioStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: RomaneioStep.falha, erro: 'Falha ao salvar romaneio.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onObservacaoAtualizada(
    RomaneioObservacaoAtualizada event,
    Emitter<RomaneioState> emit,
  ) async {
    if (state.id == null) return;

    final observacao = (event.observacao ?? state.observacao ?? '').trim();
    if (observacao.isEmpty) {
      emit(
        state.copyWith(
          step: RomaneioStep.validacaoInvalida,
          erro: 'Informe a observacao.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: RomaneioStep.processando, erro: null));
      final romaneio = await _atualizarObservacaoRomaneio.call(
        state.id!,
        observacao,
      );
      emit(
        RomaneioState.fromModel(
          romaneio,
          itensDoRomaneio: state.itens,
          step: RomaneioStep.observacaoAtualizada,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: RomaneioStep.falha, erro: 'Falha ao atualizar observacao.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onContinuarEnvioSolicitado(
    RomaneioContinuarEnvioSolicitado event,
    Emitter<RomaneioState> emit,
  ) async {
    final romaneioId = state.id;
    final hashLista = state.hashListaPendente;
    if (romaneioId == null || hashLista == null) {
      emit(
        state.copyWith(
          step: RomaneioStep.validacaoInvalida,
          erro: 'Não há itens pendentes para envio neste romaneio.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: RomaneioStep.processando, erro: null));

      final produtosPendentes = await _recuperarListaDeProdutosCompartilhada
          .recuperarProdutos(hashLista);

      for (final produto in produtosPendentes) {
        await _adicionarItemRomaneio.call(
          romaneioId: romaneioId,
          item: _mapearItemPendente(produto),
        );
        await _removerProdutoCompartilhado.call(produto.hash);
      }

      final romaneio = await _recuperarRomaneio.call(romaneioId);
      final itens = await _recuperarItensRomaneio.call(romaneioId);
      final pendencia = await _carregarPendenciaDeEnvio(romaneioId);

      emit(
        RomaneioState.fromModel(romaneio, itensDoRomaneio: itens).copyWith(
          step: pendencia.$1
              ? RomaneioStep.envioPendenciaIncompleto
              : RomaneioStep.envioPendenciaConcluido,
          possuiPendenciaDeEnvio: pendencia.$1,
          quantidadeItensPendentes: pendencia.$2,
          hashListaPendente: pendencia.$3,
          erro: pendencia.$1
              ? 'Ainda existem ${pendencia.$2} item(ns) pendentes de envio.'
              : null,
        ),
      );
    } catch (e, s) {
      final pendencia = await _carregarPendenciaDeEnvio(romaneioId);
      emit(
        state.copyWith(
          step: RomaneioStep.envioPendenciaIncompleto,
          possuiPendenciaDeEnvio: pendencia.$1,
          quantidadeItensPendentes: pendencia.$2,
          hashListaPendente: pendencia.$3,
          erro: 'Falha ao continuar envio dos itens pendentes.',
        ),
      );
      addError(e, s);
    }
  }

  Future<(bool, int, String?)> _carregarPendenciaDeEnvio(int romaneioId) async {
    try {
      final listas = await _recuperarListaDeProdutosCompartilhada
          .recuperarListas(idLista: romaneioId);

      for (final lista in listas) {
        final produtosPendentes = await _recuperarListaDeProdutosCompartilhada
            .recuperarProdutos(lista.hash);
        if (produtosPendentes.isNotEmpty) {
          return (true, produtosPendentes.length, lista.hash);
        }
      }
    } catch (_) {
      return (false, 0, null);
    }

    return (false, 0, null);
  }

  RomaneioItem _mapearItemPendente(ProdutoCompartilhado produto) {
    return RomaneioItem.create(
      produtoId: produto.produtoId,
      quantidade: produto.quantidade.toDouble(),
      referenciaNome: produto.nome,
      corNome: produto.corNome,
      tamanhoNome: produto.tamanhoNome,
    );
  }

  String? _validarCadastro(RomaneioState state) {
    if (state.pessoaId == null ||
        state.funcionarioId == null ||
        state.tabelaPrecoId == null) {
      return 'Preencha os campos obrigatorios.';
    }

    return null;
  }

  Romaneio _toModel(RomaneioState state) {
    return Romaneio.create(
      id: state.id,
      pessoaId: state.pessoaId,
      funcionarioId: state.funcionarioId,
      tabelaPrecoId: state.tabelaPrecoId,
      operacao: state.operacao,
      observacao: state.observacao?.trim(),
      pessoaNome: state.romaneio?.pessoaNome,
      funcionarioNome: state.romaneio?.funcionarioNome,
      modalidade: state.romaneio?.modalidade,
      situacao: state.romaneio?.situacao,
      quantidade: state.romaneio?.quantidade,
      valorBruto: state.romaneio?.valorBruto,
      valorDesconto: state.romaneio?.valorDesconto,
      valorLiquido: state.romaneio?.valorLiquido,
      data: state.romaneio?.data,
      criadoEm: state.romaneio?.criadoEm,
      atualizadoEm: state.romaneio?.atualizadoEm,
    );
  }
}
