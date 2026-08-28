import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';
import 'package:collection/collection.dart';

part 'produto_event.dart';
part 'produto_state.dart';

class ProdutoBloc extends Bloc<ProdutoEvent, ProdutoState> {
  final RecuperarCores _recuperarCores;
  final RecuperarTamanhos _recuperarTamanhos;
  final RecuperarEstampas _recuperarEstampas;
  final CriarProduto _criarProduto;
  final AtualizarProduto _atualizarProduto;
  final CriarCodigoDeBarras _criarCodigoDeBarras;
  final CriarProdutosEmLote _criarProdutosEmLote;

  ProdutoBloc(
    this._recuperarCores,
    this._recuperarTamanhos,
    this._recuperarEstampas,
    this._criarProduto,
    this._atualizarProduto,
    this._criarCodigoDeBarras,
    this._criarProdutosEmLote,
  ) : super(const ProdutoState(produtoStep: ProdutoStep.inicial)) {
    on<ProdutoIniciou>(_onProdutoIniciou);
    on<ProdutoEditou>(_onProdutoEditou);
    on<ProdutoSalvou>(_onProdutoSalvou);
    on<ProdutoSalvouCombinacoes>(_onProdutoSalvouCombinacoes);
    on<ProdutoEtapaAtualizou>(_onProdutoEtapaAtualizou);
    on<ProdutoCriacaoCodigoBarrasAutomaticaAlternou>(
      _onProdutoCriacaoCodigoBarrasAutomaticaAlternou,
    );
    on<ProdutoReferenciaSelecionou>(_onProdutoReferenciaSelecionou);
    on<ProdutoCoresSelecionou>(_onProdutoCoresSelecionou);
    on<ProdutoTamanhosSelecionou>(_onProdutoTamanhosSelecionou);
    on<ProdutoEstampasSelecionou>(_onProdutoEstampasSelecionou);
    on<ProdutoCombinacaoSelecionou>(_onProdutoCombinacaoSelecionou);
    on<ProdutoCombinacaoCodigoBarrasEditou>(
      _onProdutoCombinacaoCodigoBarrasEditou,
    );
  }

  FutureOr<void> _onProdutoIniciou(
    ProdutoIniciou event,
    Emitter<ProdutoState> emit,
  ) async {
    try {
      emit(state.copyWith(produtoStep: ProdutoStep.carregando));

      final cores = await _recuperarCores.call(inativo: false);
      final tamanhos = await _recuperarTamanhos.call(inativo: false);
      final estampas = await _recuperarEstampas.call(inativo: false);

      final produto = event.produto;
      final corInicial = event.corId == null
          ? null
          : cores.firstWhereOrNull((cor) => cor.id == event.corId);
      final tamanhoInicial = event.tamanhoId == null
          ? null
          : tamanhos.firstWhereOrNull(
              (tamanho) => tamanho.id == event.tamanhoId,
            );
      final estampaInicial = event.estampaId == null
          ? null
          : estampas.firstWhereOrNull(
              (estampa) => estampa.id == event.estampaId,
            );

      if (produto != null) {
        emit(
          ProdutoState.fromModel(
            produto,
            step: ProdutoStep.carregado,
            cores: cores,
            tamanhos: tamanhos,
            estampas: estampas,
          ),
        );
      } else {
        emit(
          state.copyWith(
            produtoStep: ProdutoStep.editando,
            etapaAtual: 0,
            criarCodigoBarrasAutomaticamente: true,
            referenciaSelecionada: null,
            coresSelecionadas: corInicial == null ? const [] : [corInicial],
            tamanhosSelecionados: tamanhoInicial == null
                ? const []
                : [tamanhoInicial],
            estampasSelecionadas: estampaInicial == null
                ? const []
                : [estampaInicial],
            combinacoes: _sincronizarCombinacoes(
              corInicial == null ? const [] : [corInicial],
              tamanhoInicial == null ? const [] : [tamanhoInicial],
              estampaInicial == null ? const [] : [estampaInicial],
              const [],
            ),
            id: null,
            referenciaId: event.referenciaId,
            idExterno: '',
            corId: event.corId,
            tamanhoId: event.tamanhoId,
            estampaId: event.estampaId,
            cores: cores,
            tamanhos: tamanhos,
            estampas: estampas,
            erroMensagem: null,
          ),
        );
      }
    } catch (e, s) {
      emit(
        state.copyWith(
          produtoStep: ProdutoStep.falha,
          erroMensagem: 'Falha ao carregar cores e tamanhos.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onProdutoEditou(
    ProdutoEditou event,
    Emitter<ProdutoState> emit,
  ) {
    emit(
      state.copyWith(
        produtoStep: ProdutoStep.editando,
        referenciaId: event.referenciaId,
        idExterno: event.idExterno,
        corId: event.corId,
        tamanhoId: event.tamanhoId,
        estampaId: event.estampaId,
      ),
    );
  }

  FutureOr<void> _onProdutoSalvou(
    ProdutoSalvou event,
    Emitter<ProdutoState> emit,
  ) async {
    try {
      final referenciaId = state.referenciaId;
      final idExterno = state.idExterno.trim();
      final corId = state.corId;
      final tamanhoId = state.tamanhoId;
      final estampaId = state.estampaId;

      if (referenciaId == null || corId == null || tamanhoId == null) {
        emit(
          state.copyWith(
            produtoStep: ProdutoStep.falha,
            erroMensagem: 'Preencha todos os campos obrigatórios.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(produtoStep: ProdutoStep.carregando, erroMensagem: null),
      );

      if (state.id == null) {
        final criado = await _criarProduto.call(
          referenciaId: referenciaId,
          idExterno: idExterno.isEmpty ? null : idExterno,
          corId: corId,
          tamanhoId: tamanhoId,
          estampaId: estampaId,
        );

        emit(
          ProdutoState.fromModel(
            criado,
            step: ProdutoStep.criado,
            cores: state.cores,
            tamanhos: state.tamanhos,
            estampas: state.estampas,
          ),
        );
      } else {
        final salvo = await _atualizarProduto.call(
          id: state.id!,
          referenciaId: referenciaId,
          idExterno: idExterno,
          corId: corId,
          tamanhoId: tamanhoId,
          estampaId: estampaId,
        );

        emit(
          ProdutoState.fromModel(
            salvo,
            step: ProdutoStep.salvo,
            cores: state.cores,
            tamanhos: state.tamanhos,
            estampas: state.estampas,
          ),
        );
      }
    } on InvalidProdutoException catch (e, _) {
      emit(
        state.copyWith(produtoStep: ProdutoStep.falha, erroMensagem: e.message),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          produtoStep: ProdutoStep.falha,
          erroMensagem: 'Falha ao salvar produto.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onProdutoSalvouCombinacoes(
    ProdutoSalvouCombinacoes event,
    Emitter<ProdutoState> emit,
  ) async {
    try {
      if (event.combinacoes.isEmpty) {
        emit(
          state.copyWith(
            produtoStep: ProdutoStep.falha,
            erroMensagem: 'Selecione ao menos uma combinação para cadastrar.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(produtoStep: ProdutoStep.carregando, erroMensagem: null),
      );

      // Geração/leitura do código de barras é só local (sem I/O) -- monta a lista inteira antes
      // e manda em UMA requisição (PUT /produtos em lote), em vez de 1 GET+POST+POST por
      // combinação sequencial (era o gargalo de lentidão reportado no cadastro de produtos).
      final itens = <NovoProdutoCombinacao>[];
      for (final combinacao in event.combinacoes) {
        final codigoInformado = combinacao.codigoDeBarras?.trim();
        final codigoDeBarras = event.criarCodigoDeBarrasAutomaticamente
            ? await _criarCodigoDeBarras.call()
            : codigoInformado;

        itens.add(
          NovoProdutoCombinacao(
            referenciaId: event.referenciaId,
            corId: combinacao.corId,
            tamanhoId: combinacao.tamanhoId,
            estampaId: combinacao.estampaId,
            codigoDeBarras: (codigoDeBarras?.isNotEmpty ?? false)
                ? codigoDeBarras
                : null,
          ),
        );
      }

      final criados = await _criarProdutosEmLote.call(itens);
      final ultimoCriado = criados.isEmpty ? null : criados.last;

      if (ultimoCriado == null) {
        emit(
          state.copyWith(
            produtoStep: ProdutoStep.falha,
            erroMensagem: 'Nenhuma combinação foi cadastrada.',
          ),
        );
        return;
      }

      emit(
        ProdutoState.fromModel(
          ultimoCriado,
          step: ProdutoStep.criado,
          cores: state.cores,
          tamanhos: state.tamanhos,
          estampas: state.estampas,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          produtoStep: ProdutoStep.falha,
          erroMensagem: 'Falha ao salvar combinações de produto.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onProdutoEtapaAtualizou(
    ProdutoEtapaAtualizou event,
    Emitter<ProdutoState> emit,
  ) {
    emit(state.copyWith(etapaAtual: event.etapaAtual));
  }

  FutureOr<void> _onProdutoCriacaoCodigoBarrasAutomaticaAlternou(
    ProdutoCriacaoCodigoBarrasAutomaticaAlternou event,
    Emitter<ProdutoState> emit,
  ) {
    emit(
      state.copyWith(
        criarCodigoBarrasAutomaticamente:
            event.criarCodigoBarrasAutomaticamente,
      ),
    );
  }

  FutureOr<void> _onProdutoReferenciaSelecionou(
    ProdutoReferenciaSelecionou event,
    Emitter<ProdutoState> emit,
  ) {
    emit(
      state.copyWith(
        referenciaSelecionada: event.referencia,
        referenciaId: event.referencia?.id,
      ),
    );
  }

  FutureOr<void> _onProdutoCoresSelecionou(
    ProdutoCoresSelecionou event,
    Emitter<ProdutoState> emit,
  ) {
    emit(
      state.copyWith(
        coresSelecionadas: event.cores,
        combinacoes: _sincronizarCombinacoes(
          event.cores,
          state.tamanhosSelecionados,
          state.estampasSelecionadas,
          state.combinacoes,
        ),
      ),
    );
  }

  FutureOr<void> _onProdutoTamanhosSelecionou(
    ProdutoTamanhosSelecionou event,
    Emitter<ProdutoState> emit,
  ) {
    emit(
      state.copyWith(
        tamanhosSelecionados: event.tamanhos,
        combinacoes: _sincronizarCombinacoes(
          state.coresSelecionadas,
          event.tamanhos,
          state.estampasSelecionadas,
          state.combinacoes,
        ),
      ),
    );
  }

  FutureOr<void> _onProdutoEstampasSelecionou(
    ProdutoEstampasSelecionou event,
    Emitter<ProdutoState> emit,
  ) {
    emit(
      state.copyWith(
        estampasSelecionadas: event.estampas,
        combinacoes: _sincronizarCombinacoes(
          state.coresSelecionadas,
          state.tamanhosSelecionados,
          event.estampas,
          state.combinacoes,
        ),
      ),
    );
  }

  FutureOr<void> _onProdutoCombinacaoSelecionou(
    ProdutoCombinacaoSelecionou event,
    Emitter<ProdutoState> emit,
  ) {
    final combinacoes = state.combinacoes
        .map(
          (item) => item.chave == event.chave
              ? item.copyWith(selecionada: event.selecionada)
              : item,
        )
        .toList();

    emit(state.copyWith(combinacoes: combinacoes));
  }

  FutureOr<void> _onProdutoCombinacaoCodigoBarrasEditou(
    ProdutoCombinacaoCodigoBarrasEditou event,
    Emitter<ProdutoState> emit,
  ) {
    final combinacoes = state.combinacoes
        .map(
          (item) => item.chave == event.chave
              ? item.copyWith(codigoDeBarras: event.codigoDeBarras)
              : item,
        )
        .toList();

    emit(state.copyWith(combinacoes: combinacoes));
  }

  // Estampa é a 3a dimensao, opcional: sem estampas selecionadas o produto
  // continua sendo gerado só por cor x tamanho (comportamento inalterado
  // pra maioria das referencias, que nao usa estampa).
  List<ProdutoCombinacaoCadastro> _sincronizarCombinacoes(
    List<Cor> cores,
    List<Tamanho> tamanhos,
    List<Estampa> estampas,
    List<ProdutoCombinacaoCadastro> anteriores,
  ) {
    final statusAnterior = <String, ProdutoCombinacaoCadastro>{
      for (final item in anteriores) item.chave: item,
    };

    final novas = <ProdutoCombinacaoCadastro>[];
    final estampasParaGerar = estampas.isEmpty
        ? const <Estampa?>[null]
        : estampas;

    for (final cor in cores) {
      for (final tamanho in tamanhos) {
        for (final estampa in estampasParaGerar) {
          final chave = ProdutoCombinacaoCadastro.gerarChave(
            cor,
            tamanho,
            estampa,
          );
          final anterior = statusAnterior[chave];
          novas.add(
            ProdutoCombinacaoCadastro(
              cor: cor,
              tamanho: tamanho,
              estampa: estampa,
              selecionada: anterior?.selecionada ?? true,
              codigoDeBarras: anterior?.codigoDeBarras ?? '',
            ),
          );
        }
      }
    }

    return novas;
  }
}
