import 'dart:async';
import 'dart:collection';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:precos/use_cases.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'impressao_etiquetas_event.dart';
part 'impressao_etiquetas_state.dart';

class ImpressaoEtiquetasBloc
    extends Bloc<ImpressaoEtiquetasEvent, ImpressaoEtiquetasState> {
  final RecuperarProdutos _recuperarProdutos;
  final RecuperarCodigoDeBarrasDoProduto _recuperarCodigoDeBarrasDoProduto;
  final ObterPrecoDaReferencia _obterPrecoDaReferencia;
  final ProcessarEtiquetaParaImpressao _processarEtiquetaParaImpressao;
  final ImprimirEtiquetas _imprimirEtiquetas;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  ImpressaoEtiquetasBloc(
    this._recuperarProdutos,
    this._recuperarCodigoDeBarrasDoProduto,
    this._obterPrecoDaReferencia,
    this._processarEtiquetaParaImpressao,
    this._imprimirEtiquetas,
    this._acessoGlobalSessao,
  ) : super(const ImpressaoEtiquetasState()) {
    on<ImpressaoEtiquetasIniciou>(_onIniciou);
    on<ImpressaoEtiquetasEtiquetaSelecionada>(_onEtiquetaSelecionada);
    on<ImpressaoEtiquetasTabelaSelecionada>(_onTabelaSelecionada);
    on<ImpressaoEtiquetasReferenciaSelecionada>(_onReferenciaSelecionada);
    on<ImpressaoEtiquetasQuantidadeAlterada>(_onQuantidadeAlterada);
    on<ImpressaoEtiquetasAdicionarSolicitado>(_onAdicionarSolicitado);
    on<ImpressaoEtiquetasImprimirSolicitado>(_onImprimirSolicitado);
    on<ImpressaoEtiquetasPilhaLimpaSolicitada>(_onPilhaLimpaSolicitada);
    on<ImpressaoEtiquetasPilhaQuantidadeAlterada>(_onPilhaQuantidadeAlterada);
    on<ImpressaoEtiquetasPilhaItemRemovido>(_onPilhaItemRemovido);
    on<ImpressaoEtiquetasPilhaOrdenacaoAlterada>(_onPilhaOrdenacaoAlterada);
  }

  FutureOr<void> _onIniciou(
    ImpressaoEtiquetasIniciou event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) {
    final empresaNome = _acessoGlobalSessao.empresaNomeDaSessao?.trim();
    final empresaId = _acessoGlobalSessao.empresaIdDaSessao;
    final tituloEmpresa = (empresaNome != null && empresaNome.isNotEmpty)
        ? empresaNome
        : (empresaId == null ? 'EMPRESA' : 'EMPRESA $empresaId');

    emit(state.copyWith(tituloEmpresaSessao: tituloEmpresa));
  }

  FutureOr<void> _onEtiquetaSelecionada(
    ImpressaoEtiquetasEtiquetaSelecionada event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) {
    emit(state.copyWith(etiquetaSelecionada: () => event.etiqueta));
  }

  FutureOr<void> _onTabelaSelecionada(
    ImpressaoEtiquetasTabelaSelecionada event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) {
    emit(state.copyWith(tabelaSelecionada: () => event.tabela));
  }

  FutureOr<void> _onReferenciaSelecionada(
    ImpressaoEtiquetasReferenciaSelecionada event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) async {
    final referencia = event.referencia;

    if (referencia?.id == null) {
      emit(
        state.copyWith(
          referenciaSelecionada: () => referencia,
          produtos: const [],
          cores: const [],
          tamanhos: const [],
          mapaCorTamanhoParaProduto: const {},
          quantidadesPorProdutoId: const {},
          erro: () => null,
        ),
      );
      return;
    }

    try {
      emit(
        state.copyWith(
          referenciaSelecionada: () => referencia,
          carregandoGrade: true,
          erro: () => null,
          sucesso: () => null,
          produtos: const [],
          cores: const [],
          tamanhos: const [],
          mapaCorTamanhoParaProduto: const {},
          quantidadesPorProdutoId: const {},
        ),
      );

      final produtos = await _recuperarProdutos(referenciaId: referencia!.id);

      final mapaCores = <String, Cor>{};
      final mapaTamanhos = <String, Tamanho>{};
      final mapaCorTamanhoParaProduto = <String, Produto>{};

      for (final produto in produtos) {
        final cor = produto.cor;
        final tamanho = produto.tamanho;

        if (cor != null) {
          final chaveCor = cor.id?.toString() ?? cor.nome.toLowerCase().trim();
          mapaCores[chaveCor] = cor;
        }

        if (tamanho != null) {
          final chaveTamanho =
              tamanho.id?.toString() ?? tamanho.nome.toLowerCase().trim();
          mapaTamanhos[chaveTamanho] = tamanho;
        }

        if (cor?.id != null && tamanho?.id != null) {
          final chave = '${cor!.id}_${tamanho!.id}';
          mapaCorTamanhoParaProduto[chave] = produto;
        }
      }

      final cores = mapaCores.values.toList()
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      final tamanhos = mapaTamanhos.values.toList()
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

      emit(
        state.copyWith(
          carregandoGrade: false,
          produtos: produtos,
          cores: cores,
          tamanhos: tamanhos,
          mapaCorTamanhoParaProduto: mapaCorTamanhoParaProduto,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoGrade: false,
          erro: () => 'Falha ao carregar produtos da referencia selecionada.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onQuantidadeAlterada(
    ImpressaoEtiquetasQuantidadeAlterada event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) {
    final quantidades = Map<int, int>.from(state.quantidadesPorProdutoId);

    if (event.quantidade <= 0) {
      quantidades.remove(event.produtoId);
    } else {
      quantidades[event.produtoId] = event.quantidade;
    }

    emit(state.copyWith(quantidadesPorProdutoId: quantidades));
  }

  FutureOr<void> _onAdicionarSolicitado(
    ImpressaoEtiquetasAdicionarSolicitado event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) async {
    final etiqueta = state.etiquetaSelecionada;
    final referencia = state.referenciaSelecionada;
    final tabela = state.tabelaSelecionada;

    if (etiqueta == null || referencia?.id == null || tabela == null) {
      emit(
        state.copyWith(
          erro: () =>
              'Selecione etiqueta, tabela de preco e referencia antes de adicionar.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(processando: true, erro: () => null, sucesso: () => null));

      final precoDaReferencia = await _obterPrecoDaReferencia(
        tabelaDePrecoId: tabela.id,
        referenciaId: referencia!.id!,
      );

      if (precoDaReferencia.valor <= 0) {
        emit(
          state.copyWith(
            processando: false,
            erro: () =>
                'A referencia selecionada nao possui preco cadastrado na tabela informada.',
          ),
        );
        return;
      }

      final viasOrdenadas = [...etiqueta.vias]
        ..sort((a, b) => a.ordem.compareTo(b.ordem));

      if (viasOrdenadas.isEmpty) {
        emit(
          state.copyWith(
            processando: false,
            erro: () => 'A etiqueta selecionada nao possui vias configuradas.',
          ),
        );
        return;
      }

      final novosItens = <EtiquetaImpressaoItem>[];
      final combinacoesSemCodigo = <String>[];
      final requisicoes = <_RequisicaoEtiqueta>[];

      for (final produto in state.produtos) {
        final produtoId = produto.id;
        if (produtoId == null) {
          continue;
        }

        final quantidade = state.quantidadesPorProdutoId[produtoId] ?? 0;
        if (quantidade <= 0) {
          continue;
        }

        final cor = produto.cor?.nome ?? 'SEM COR';
        final tamanho = produto.tamanho?.nome ?? 'SEM TAMANHO';
        final codigoStorage = await _recuperarCodigoDeBarrasDoProduto(
          produtoId: produtoId,
        );

        if (codigoStorage == null || codigoStorage.trim().isEmpty) {
          combinacoesSemCodigo.add('$cor/$tamanho');
          continue;
        }

        for (var i = 0; i < quantidade; i++) {
          requisicoes.add(
            _RequisicaoEtiqueta(
              cor: cor,
              tamanho: tamanho,
              codigoBarras: codigoStorage.trim(),
            ),
          );
        }
      }

      if (combinacoesSemCodigo.isNotEmpty) {
        final combinacoesOrdenadas = combinacoesSemCodigo.toSet().toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final detalhes = combinacoesOrdenadas.join(', ');

        emit(
          state.copyWith(
            processando: false,
            erro: () =>
                'Nao foi possivel adicionar. As seguintes combinacoes estao sem codigo de barras cadastrado: $detalhes.',
          ),
        );
        return;
      }

      if (requisicoes.isEmpty) {
        emit(
          state.copyWith(
            processando: false,
            erro: () => 'Informe ao menos uma quantidade maior que zero na grade.',
          ),
        );
        return;
      }

      for (var i = 0; i < requisicoes.length; i++) {
        final requisicao = requisicoes[i];
        final via = viasOrdenadas[i % viasOrdenadas.length];

        final zplProcessado = _processarEtiquetaParaImpressao(
          templateZpl: via.zpl,
          titulo: state.tituloEmpresaSessao,
          cor: requisicao.cor,
          tamanho: requisicao.tamanho,
          codigoBarras: requisicao.codigoBarras,
          preco: precoDaReferencia.valor,
          descricao: referencia.nome,
        );

        novosItens.add(
          EtiquetaImpressaoItem.create(
            descricao:
                '${referencia.nome} | Cor: ${requisicao.cor} | Tam: ${requisicao.tamanho} | Via ${via.ordem + 1}',
            zpl: zplProcessado,
            referencia: referencia.nome,
            cor: requisicao.cor,
            tamanho: requisicao.tamanho,
            viaOrdem: via.ordem,
          ),
        );
      }

      emit(
        state.copyWith(
          processando: false,
          pilhaImpressao: _ordenarPilha(
            [...state.pilhaImpressao, ...novosItens],
            state.pilhaOrdenacao,
          ),
          sucesso: () => '${novosItens.length} etiqueta(s) adicionada(s) a pilha.',
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          processando: false,
          erro: () =>
              'Falha ao processar etiquetas. Verifique se a referencia possui preco cadastrado na tabela selecionada.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onImprimirSolicitado(
    ImpressaoEtiquetasImprimirSolicitado event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) async {
    if (state.pilhaImpressao.isEmpty) {
      emit(state.copyWith(erro: () => 'A pilha de impressao esta vazia.'));
      return;
    }

    try {
      emit(state.copyWith(imprimindo: true, erro: () => null, sucesso: () => null));

      await _imprimirEtiquetas(
        zpls: state.pilhaImpressao.map((item) => item.zpl).toList(growable: false),
      );

      emit(
        state.copyWith(
          imprimindo: false,
          sucesso: () => 'Chamada de impressao enviada. Implementacao pendente.',
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          imprimindo: false,
          erro: () => 'Falha ao chamar impressao de etiquetas.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onPilhaLimpaSolicitada(
    ImpressaoEtiquetasPilhaLimpaSolicitada event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) {
    emit(
      state.copyWith(
        pilhaImpressao: const [],
        sucesso: () => 'Pilha de impressao limpa.',
        erro: () => null,
      ),
    );
  }

  FutureOr<void> _onPilhaQuantidadeAlterada(
    ImpressaoEtiquetasPilhaQuantidadeAlterada event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) {
    final pilhaAtual = [...state.pilhaImpressao];
    final itensDoGrupo = pilhaAtual
        .where(
          (item) => _mesmaCombinacao(
            item: item,
            referencia: event.referencia,
            cor: event.cor,
            tamanho: event.tamanho,
          ),
        )
        .toList(growable: false);

    if (itensDoGrupo.isEmpty) {
      emit(state.copyWith(erro: () => 'Item nao encontrado na pilha.'));
    } else {
      final quantidadeAtual = itensDoGrupo.length;
      final novaQuantidade = event.quantidade;

      if (novaQuantidade <= 0) {
        final pilhaSemGrupo = pilhaAtual
            .where(
              (item) => !_mesmaCombinacao(
                item: item,
                referencia: event.referencia,
                cor: event.cor,
                tamanho: event.tamanho,
              ),
            )
            .toList(growable: false);

        emit(
          state.copyWith(
            pilhaImpressao: _ordenarPilha(pilhaSemGrupo, state.pilhaOrdenacao),
            sucesso: () =>
                'Combinacao ${event.referencia} | ${event.cor} | ${event.tamanho} removida da pilha.',
            erro: () => null,
          ),
        );
      } else if (novaQuantidade != quantidadeAtual) {
        if (novaQuantidade < quantidadeAtual) {
          var quantidadeParaRemover = quantidadeAtual - novaQuantidade;
          for (var i = pilhaAtual.length - 1;
              i >= 0 && quantidadeParaRemover > 0;
              i--) {
            final item = pilhaAtual[i];
            if (_mesmaCombinacao(
              item: item,
              referencia: event.referencia,
              cor: event.cor,
              tamanho: event.tamanho,
            )) {
              pilhaAtual.removeAt(i);
              quantidadeParaRemover--;
            }
          }
        } else {
          final modelos = [...itensDoGrupo]
            ..sort((a, b) => a.viaOrdem.compareTo(b.viaOrdem));
          final quantidadeParaAdicionar = novaQuantidade - quantidadeAtual;

          for (var i = 0; i < quantidadeParaAdicionar; i++) {
            final base = modelos[(quantidadeAtual + i) % modelos.length];
            pilhaAtual.add(base.copyWith());
          }
        }

        emit(
          state.copyWith(
            pilhaImpressao: _ordenarPilha(pilhaAtual, state.pilhaOrdenacao),
            sucesso: () =>
                'Quantidade atualizada para $novaQuantidade na combinacao ${event.referencia} | ${event.cor} | ${event.tamanho}.',
            erro: () => null,
          ),
        );
      }
    }
  }

  FutureOr<void> _onPilhaItemRemovido(
    ImpressaoEtiquetasPilhaItemRemovido event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) {
    final pilhaSemItem = state.pilhaImpressao
        .where(
          (item) => !_mesmaCombinacao(
            item: item,
            referencia: event.referencia,
            cor: event.cor,
            tamanho: event.tamanho,
          ),
        )
        .toList(growable: false);

    emit(
      state.copyWith(
        pilhaImpressao: _ordenarPilha(pilhaSemItem, state.pilhaOrdenacao),
        sucesso: () =>
            'Combinacao ${event.referencia} | ${event.cor} | ${event.tamanho} removida da pilha.',
        erro: () => null,
      ),
    );
  }

  FutureOr<void> _onPilhaOrdenacaoAlterada(
    ImpressaoEtiquetasPilhaOrdenacaoAlterada event,
    Emitter<ImpressaoEtiquetasState> emit,
  ) {
    emit(
      state.copyWith(
        pilhaOrdenacao: event.ordenacao,
        pilhaImpressao: _ordenarPilha(state.pilhaImpressao, event.ordenacao),
        erro: () => null,
      ),
    );
  }

  bool _mesmaCombinacao({
    required EtiquetaImpressaoItem item,
    required String referencia,
    required String cor,
    required String tamanho,
  }) {
    return item.referencia == referencia &&
        item.cor == cor &&
        item.tamanho == tamanho;
  }

  List<EtiquetaImpressaoItem> _ordenarPilha(
    List<EtiquetaImpressaoItem> itens,
    PilhaImpressaoOrdenacao ordenacao,
  ) {
    if (ordenacao == PilhaImpressaoOrdenacao.insercao) {
      return _balancearPilhaPorVia(itens);
    }

    final ordenados = [...itens];

    int compararTexto(String a, String b) =>
        a.toLowerCase().trim().compareTo(b.toLowerCase().trim());

    ordenados.sort((a, b) {
      if (ordenacao == PilhaImpressaoOrdenacao.referencia) {
        final porReferencia = compararTexto(a.referencia, b.referencia);
        if (porReferencia != 0) return porReferencia;
        final porCor = compararTexto(a.cor, b.cor);
        if (porCor != 0) return porCor;
        final porTamanho = compararTexto(a.tamanho, b.tamanho);
        if (porTamanho != 0) return porTamanho;
        return a.viaOrdem.compareTo(b.viaOrdem);
      }

      if (ordenacao == PilhaImpressaoOrdenacao.referenciaCor) {
        final porReferencia = compararTexto(a.referencia, b.referencia);
        if (porReferencia != 0) return porReferencia;
        final porCor = compararTexto(a.cor, b.cor);
        if (porCor != 0) return porCor;
        final porVia = a.viaOrdem.compareTo(b.viaOrdem);
        if (porVia != 0) return porVia;
        return compararTexto(a.tamanho, b.tamanho);
      }

      if (ordenacao == PilhaImpressaoOrdenacao.referenciaTamanho) {
        final porReferencia = compararTexto(a.referencia, b.referencia);
        if (porReferencia != 0) return porReferencia;
        final porTamanho = compararTexto(a.tamanho, b.tamanho);
        if (porTamanho != 0) return porTamanho;
        final porVia = a.viaOrdem.compareTo(b.viaOrdem);
        if (porVia != 0) return porVia;
        return compararTexto(a.cor, b.cor);
      }

      if (ordenacao == PilhaImpressaoOrdenacao.cor) {
        final porCor = compararTexto(a.cor, b.cor);
        if (porCor != 0) return porCor;
        final porTamanho = compararTexto(a.tamanho, b.tamanho);
        if (porTamanho != 0) return porTamanho;
        final porReferencia = compararTexto(a.referencia, b.referencia);
        if (porReferencia != 0) return porReferencia;
        return a.viaOrdem.compareTo(b.viaOrdem);
      }

      final porTamanho = compararTexto(a.tamanho, b.tamanho);
      if (porTamanho != 0) return porTamanho;
      final porCor = compararTexto(a.cor, b.cor);
      if (porCor != 0) return porCor;
      final porReferencia = compararTexto(a.referencia, b.referencia);
      if (porReferencia != 0) return porReferencia;
      return a.viaOrdem.compareTo(b.viaOrdem);
    });

    return _balancearPilhaPorVia(ordenados);
  }

  List<EtiquetaImpressaoItem> _balancearPilhaPorVia(
    List<EtiquetaImpressaoItem> itens,
  ) {
    final filasPorVia = <int, Queue<EtiquetaImpressaoItem>>{};

    for (final item in itens) {
      filasPorVia.putIfAbsent(item.viaOrdem, Queue.new).add(item);
    }

    final viasOrdenadas = filasPorVia.keys.toList()..sort();
    final resultado = <EtiquetaImpressaoItem>[];

    while (filasPorVia.values.any((fila) => fila.isNotEmpty)) {
      for (final via in viasOrdenadas) {
        final fila = filasPorVia[via];
        if (fila == null || fila.isEmpty) {
          continue;
        }
        resultado.add(fila.removeFirst());
      }
    }

    return resultado;
  }
}

class _RequisicaoEtiqueta {
  final String cor;
  final String tamanho;
  final String codigoBarras;

  const _RequisicaoEtiqueta({
    required this.cor,
    required this.tamanho,
    required this.codigoBarras,
  });
}
