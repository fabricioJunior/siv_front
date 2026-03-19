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
  final CriarProduto _criarProduto;
  final AtualizarProduto _atualizarProduto;
  final CriarCodigoDeBarras _criarCodigoDeBarras;
  final SalvarCodigoDeBarras _salvarCodigoDeBarras;

  ProdutoBloc(
    this._recuperarCores,
    this._recuperarTamanhos,
    this._criarProduto,
    this._atualizarProduto,
    this._criarCodigoDeBarras,
    this._salvarCodigoDeBarras,
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

      final produto = event.produto;
      final corInicial = event.corId == null
          ? null
          : cores.firstWhereOrNull((cor) => cor.id == event.corId);
      final tamanhoInicial = event.tamanhoId == null
          ? null
          : tamanhos.firstWhereOrNull(
              (tamanho) => tamanho.id == event.tamanhoId,
            );

      if (produto != null) {
        emit(
          ProdutoState.fromModel(
            produto,
            step: ProdutoStep.carregado,
            cores: cores,
            tamanhos: tamanhos,
          ),
        );
      } else {
        emit(
          state.copyWith(
            produtoStep: ProdutoStep.editando,
            etapaAtual: 0,
            criarCodigoBarrasAutomaticamente: false,
            referenciaSelecionada: null,
            coresSelecionadas: corInicial == null ? const [] : [corInicial],
            tamanhosSelecionados: tamanhoInicial == null
                ? const []
                : [tamanhoInicial],
            combinacoes: _sincronizarCombinacoes(
              corInicial == null ? const [] : [corInicial],
              tamanhoInicial == null ? const [] : [tamanhoInicial],
              const [],
            ),
            id: null,
            referenciaId: event.referenciaId,
            idExterno: '',
            corId: event.corId,
            tamanhoId: event.tamanhoId,
            cores: cores,
            tamanhos: tamanhos,
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
        );

        emit(
          ProdutoState.fromModel(
            criado,
            step: ProdutoStep.criado,
            cores: state.cores,
            tamanhos: state.tamanhos,
          ),
        );
      } else {
        final salvo = await _atualizarProduto.call(
          id: state.id!,
          referenciaId: referenciaId,
          idExterno: idExterno,
          corId: corId,
          tamanhoId: tamanhoId,
        );

        emit(
          ProdutoState.fromModel(
            salvo,
            step: ProdutoStep.salvo,
            cores: state.cores,
            tamanhos: state.tamanhos,
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

      Produto? ultimoCriado;

      for (final combinacao in event.combinacoes) {
        final codigoInformado = combinacao.codigoDeBarras?.trim();
        final codigoDeBarras = event.criarCodigoDeBarrasAutomaticamente
            ? await _criarCodigoDeBarras.call()
            : codigoInformado;

        ultimoCriado = await _criarProduto.call(
          referenciaId: event.referenciaId,
          corId: combinacao.corId,
          tamanhoId: combinacao.tamanhoId,
        );

        if (codigoDeBarras != null &&
            codigoDeBarras.isNotEmpty &&
            ultimoCriado.id != null) {
          await _salvarCodigoDeBarras.call(
            produtoId: ultimoCriado.id!,
            codigoDeBarras: codigoDeBarras,
          );
        }
      }

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

  List<ProdutoCombinacaoCadastro> _sincronizarCombinacoes(
    List<Cor> cores,
    List<Tamanho> tamanhos,
    List<ProdutoCombinacaoCadastro> anteriores,
  ) {
    final statusAnterior = <String, ProdutoCombinacaoCadastro>{
      for (final item in anteriores) item.chave: item,
    };

    final novas = <ProdutoCombinacaoCadastro>[];

    for (final cor in cores) {
      for (final tamanho in tamanhos) {
        final chave = ProdutoCombinacaoCadastro.gerarChave(cor, tamanho);
        final anterior = statusAnterior[chave];
        novas.add(
          ProdutoCombinacaoCadastro(
            cor: cor,
            tamanho: tamanho,
            selecionada: anterior?.selecionada ?? true,
            codigoDeBarras: anterior?.codigoDeBarras ?? '',
          ),
        );
      }
    }

    return novas;
  }
}
