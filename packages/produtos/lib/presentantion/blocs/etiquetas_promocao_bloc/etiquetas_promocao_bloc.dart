import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/impressao_etiquetas_bloc/montar_etiquetas_por_vias.dart';
import 'package:produtos/use_cases.dart';

part 'etiquetas_promocao_event.dart';
part 'etiquetas_promocao_state.dart';

class EtiquetasPromocaoBloc
    extends Bloc<EtiquetasPromocaoEvent, EtiquetasPromocaoState> {
  final RecuperarPromocoesParaEtiqueta _recuperarPromocoes;
  final RecuperarItensDaPromocaoParaEtiqueta _recuperarItens;
  final RecuperarCodigoDeBarrasDoProduto _recuperarCodigoDeBarras;
  final ProcessarEtiquetaParaImpressao _processarEtiqueta;
  final IAcessoGlobalSessao _sessao;

  EtiquetasPromocaoBloc(
    this._recuperarPromocoes,
    this._recuperarItens,
    this._recuperarCodigoDeBarras,
    this._processarEtiqueta,
    this._sessao,
  ) : super(const EtiquetasPromocaoState()) {
    on<EtiquetasPromocaoIniciou>(_onIniciou);
    on<EtiquetasPromocaoVigenteAlterado>(_onVigenteAlterado);
    on<EtiquetasPromocaoSelecionada>(_onPromocaoSelecionada);
    on<EtiquetasPromocaoTabelaSelecionada>(_onTabelaSelecionada);
    on<EtiquetasPromocaoModeloSelecionado>(
      (e, emit) => emit(state.copyWith(etiqueta: () => e.etiqueta)),
    );
    on<EtiquetasPromocaoItemAlternado>(_onItemAlternado);
    on<EtiquetasPromocaoTodosAlternado>(_onTodosAlternado);
    on<EtiquetasPromocaoImprimirSolicitado>(_onImprimir);
    on<EtiquetasPromocaoPilhaConsumida>(
      (e, emit) => emit(state.copyWith(pilha: const [])),
    );
  }

  Future<void> _onIniciou(
    EtiquetasPromocaoIniciou event,
    Emitter<EtiquetasPromocaoState> emit,
  ) async {
    final nome = _sessao.empresaNomeDaSessao?.trim();
    final id = _sessao.empresaIdDaSessao;
    emit(
      state.copyWith(
        tituloEmpresa: (nome != null && nome.isNotEmpty)
            ? nome
            : (id == null ? 'EMPRESA' : 'EMPRESA $id'),
      ),
    );
    await _carregarPromocoes(emit);
  }

  Future<void> _onVigenteAlterado(
    EtiquetasPromocaoVigenteAlterado event,
    Emitter<EtiquetasPromocaoState> emit,
  ) async {
    emit(state.copyWith(apenasVigentes: event.apenasVigentes));
    await _carregarPromocoes(emit);
  }

  Future<void> _carregarPromocoes(Emitter<EtiquetasPromocaoState> emit) async {
    emit(state.copyWith(carregandoPromocoes: true, erro: () => null));
    try {
      final lista = await _recuperarPromocoes(
        apenasVigentes: state.apenasVigentes,
      );
      final atual = state.promocao;
      final mantem = atual != null && lista.any((p) => p.id == atual.id);
      emit(
        state.copyWith(
          promocoes: lista,
          carregandoPromocoes: false,
          promocao: mantem ? null : () => null,
          itens: mantem ? null : const [],
          selecionados: mantem ? null : const {},
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoPromocoes: false,
          erro: () => 'Nao foi possivel carregar as promocoes.',
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onPromocaoSelecionada(
    EtiquetasPromocaoSelecionada event,
    Emitter<EtiquetasPromocaoState> emit,
  ) async {
    emit(state.copyWith(promocao: () => event.promocao));
    await _carregarItens(emit);
  }

  Future<void> _onTabelaSelecionada(
    EtiquetasPromocaoTabelaSelecionada event,
    Emitter<EtiquetasPromocaoState> emit,
  ) async {
    emit(state.copyWith(tabela: () => event.tabela));
    await _carregarItens(emit);
  }

  Future<void> _carregarItens(Emitter<EtiquetasPromocaoState> emit) async {
    final promocao = state.promocao;
    final tabela = state.tabela;
    if (promocao == null || tabela == null) {
      emit(
        state.copyWith(
          itens: const [],
          selecionados: const {},
          carregandoItens: false,
          erro: () => null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        carregandoItens: true,
        itens: const [],
        selecionados: const {},
        erro: () => null,
      ),
    );
    try {
      final itens = await _recuperarItens(
        promocaoId: promocao.id,
        tabelaDePrecoId: tabela.id,
      );
      // Descarta resposta velha se o usuario trocou promocao/tabela no meio.
      if (state.promocao?.id != promocao.id || state.tabela?.id != tabela.id) {
        return;
      }
      emit(state.copyWith(itens: itens, carregandoItens: false));
    } catch (e, s) {
      if (state.promocao?.id != promocao.id || state.tabela?.id != tabela.id) {
        return;
      }
      emit(
        state.copyWith(
          carregandoItens: false,
          erro: () => 'Nao foi possivel carregar os produtos da promocao.',
        ),
      );
      addError(e, s);
    }
  }

  void _onItemAlternado(
    EtiquetasPromocaoItemAlternado event,
    Emitter<EtiquetasPromocaoState> emit,
  ) {
    final item = state.itens.where((i) => i.produtoId == event.produtoId);
    if (item.isEmpty || !item.first.imprimivel) return;
    final novos = {...state.selecionados};
    if (!novos.remove(event.produtoId)) novos.add(event.produtoId);
    emit(state.copyWith(selecionados: novos));
  }

  void _onTodosAlternado(
    EtiquetasPromocaoTodosAlternado event,
    Emitter<EtiquetasPromocaoState> emit,
  ) {
    emit(
      state.copyWith(
        selecionados: event.selecionar
            ? {
                for (final i in state.itens)
                  if (i.imprimivel) i.produtoId,
              }
            : const {},
      ),
    );
  }

  Future<void> _onImprimir(
    EtiquetasPromocaoImprimirSolicitado event,
    Emitter<EtiquetasPromocaoState> emit,
  ) async {
    final etiqueta = state.etiqueta;
    if (etiqueta == null) {
      emit(state.copyWith(erro: () => 'Selecione o modelo de etiqueta.'));
      return;
    }
    if (etiqueta.vias.isEmpty) {
      emit(
        state.copyWith(
          erro: () => 'A etiqueta selecionada nao possui vias configuradas.',
        ),
      );
      return;
    }
    final selecionados = state.itensSelecionados.toList();
    if (selecionados.isEmpty) {
      emit(state.copyWith(erro: () => 'Selecione ao menos um produto.'));
      return;
    }

    emit(state.copyWith(imprimindo: true, erro: () => null));
    try {
      final requisicoes = <RequisicaoEtiqueta>[];
      final semCodigo = <String>[];
      for (final item in selecionados) {
        var codigo = item.codigoBarras?.trim();
        if (codigo == null || codigo.isEmpty) {
          codigo = (await _recuperarCodigoDeBarras(
            produtoId: item.produtoId,
          ))?.trim();
        }
        final cor = item.corNome ?? 'SEM COR';
        final tamanho = item.tamanhoNome ?? 'SEM TAMANHO';
        if (codigo == null || codigo.isEmpty) {
          semCodigo.add('${item.referenciaNome} $cor/$tamanho');
          continue;
        }
        for (var i = 0; i < item.saldo; i++) {
          requisicoes.add(
            RequisicaoEtiqueta(
              preco: item.precoFinal,
              descricao: item.referenciaNome,
              cor: cor,
              corExibicao: cor,
              tamanho: tamanho,
              codigoBarras: codigo,
            ),
          );
        }
      }
      if (semCodigo.isNotEmpty) {
        emit(
          state.copyWith(
            imprimindo: false,
            erro: () =>
                'Produtos sem codigo de barras cadastrado: ${semCodigo.join(', ')}.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          imprimindo: false,
          pilha: montarEtiquetasPorVias(
            etiqueta: etiqueta,
            requisicoes: requisicoes,
            titulo: state.tituloEmpresa,
            processar: _processarEtiqueta,
          ),
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          imprimindo: false,
          erro: () => 'Falha ao preparar as etiquetas para impressao.',
        ),
      );
      addError(e, s);
    }
  }
}
