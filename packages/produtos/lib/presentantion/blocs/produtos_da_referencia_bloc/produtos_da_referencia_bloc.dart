import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/domain/tamanho_grade_agrupamento.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'produtos_da_referencia_event.dart';
part 'produtos_da_referencia_state.dart';

typedef ItemPresente = ({int id, String nome});
typedef EstampaPresente = ({int? id, String nome});

const rotuloFiltroFaltando = 'Faltando';
const rotuloFiltroTodos = 'Todos';

String chaveComboGrade(int corId, int tamanhoId, int? estampaId) =>
    '$corId|$tamanhoId|${estampaId ?? ''}';

class ProdutosDaReferenciaBloc
    extends Bloc<ProdutosDaReferenciaEvent, ProdutosDaReferenciaState> {
  final RecuperarGradeDaReferencia _recuperarGradeDaReferencia;
  final CriarProdutosEmLote _criarProdutosEmLote;
  final CriarCodigoDeBarras _criarCodigoDeBarras;

  ProdutosDaReferenciaBloc(
    this._recuperarGradeDaReferencia,
    this._criarProdutosEmLote,
    this._criarCodigoDeBarras,
  ) : super(const ProdutosDaReferenciaState()) {
    on<ProdutosDaReferenciaIniciou>(_onIniciou);
    on<ProdutosDaReferenciaBuscouAlterou>(_onBuscaAlterou);
    on<ProdutosDaReferenciaFiltroAlterou>(_onFiltroAlterou);
    on<ProdutosDaReferenciaCriouCombinacoes>(_onCriouCombinacoes);
  }

  FutureOr<void> _onIniciou(
    ProdutosDaReferenciaIniciou event,
    Emitter<ProdutosDaReferenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        step: ProdutosDaReferenciaStep.carregando,
        referenciaId: event.referenciaId,
      ),
    );
    try {
      final grade = await _recuperarGradeDaReferencia.call(
        referenciaId: event.referenciaId,
      );
      emit(_estadoComGrade(state, grade));
    } catch (e, s) {
      emit(state.copyWith(step: ProdutosDaReferenciaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onBuscaAlterou(
    ProdutosDaReferenciaBuscouAlterou event,
    Emitter<ProdutosDaReferenciaState> emit,
  ) {
    emit(state.copyWith(busca: event.busca));
  }

  FutureOr<void> _onFiltroAlterou(
    ProdutosDaReferenciaFiltroAlterou event,
    Emitter<ProdutosDaReferenciaState> emit,
  ) {
    emit(state.copyWith(filtro: event.filtro));
  }

  FutureOr<void> _onCriouCombinacoes(
    ProdutosDaReferenciaCriouCombinacoes event,
    Emitter<ProdutosDaReferenciaState> emit,
  ) async {
    if (event.combinacoes.isEmpty || state.referenciaId == null) return;

    emit(state.copyWith(step: ProdutosDaReferenciaStep.criandoProdutos));
    try {
      final itens = <NovoProdutoCombinacao>[];
      for (final combinacao in event.combinacoes) {
        final codigoDeBarras = await _criarCodigoDeBarras.call();
        itens.add(
          NovoProdutoCombinacao(
            referenciaId: state.referenciaId!,
            corId: combinacao.corId,
            tamanhoId: combinacao.tamanhoId,
            estampaId: combinacao.estampaId,
            codigoDeBarras: codigoDeBarras,
          ),
        );
      }

      await _criarProdutosEmLote.call(itens);

      final grade = await _recuperarGradeDaReferencia.call(
        referenciaId: state.referenciaId!,
      );
      emit(_estadoComGrade(state, grade));
    } catch (e, s) {
      emit(state.copyWith(step: ProdutosDaReferenciaStep.falha));
      addError(e, s);
    }
  }

  ProdutosDaReferenciaState _estadoComGrade(
    ProdutosDaReferenciaState atual,
    GradeDaReferencia grade,
  ) {
    final mapaProduto = <String, ProdutoDaGrade>{
      for (final produto in grade.produtos)
        chaveComboGrade(produto.corId, produto.tamanhoId, produto.estampaId):
            produto,
    };

    final cores = _itensPresentesUnicos(
      grade.produtos.map((p) => (id: p.corId, nome: p.corNome)),
    );
    final tamanhos = _itensPresentesUnicos(
      grade.produtos.map((p) => (id: p.tamanhoId, nome: p.tamanhoNome)),
    )..sort(
      (a, b) => compararTamanhosNaOrdemDaGrade(
        _TamanhoAdapter(a),
        _TamanhoAdapter(b),
      ),
    );

    final estampasMap = <int?, String>{null: 'Liso'};
    for (final produto in grade.produtos) {
      if (produto.estampaId != null) {
        estampasMap[produto.estampaId] = produto.estampaNome ?? '';
      }
    }
    final estampas = estampasMap.entries
        .map((e) => (id: e.key, nome: e.value))
        .toList()
      ..sort((a, b) {
        if (a.id == null) return -1;
        if (b.id == null) return 1;
        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      });

    return atual.copyWith(
      step: ProdutosDaReferenciaStep.sucesso,
      grade: grade,
      cores: cores,
      tamanhos: tamanhos,
      estampas: estampas,
      mapaProduto: mapaProduto,
    );
  }

  List<ItemPresente> _itensPresentesUnicos(Iterable<ItemPresente> itens) {
    final mapa = <int, String>{};
    for (final item in itens) {
      mapa[item.id] = item.nome;
    }
    final lista = mapa.entries.map((e) => (id: e.key, nome: e.value)).toList()
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return lista;
  }
}

/// Adapter mínimo só pra reusar [compararTamanhosNaOrdemDaGrade], que
/// espera um [Tamanho] completo.
class _TamanhoAdapter implements Tamanho {
  final ItemPresente item;
  _TamanhoAdapter(this.item);

  @override
  int? get id => item.id;
  @override
  String get nome => item.nome;
  @override
  bool get inativo => false;
  @override
  List<Object?> get props => [id, nome, inativo];
  @override
  bool? get stringify => true;
}

/// Uma combinação a criar em lote (usada tanto pelo painel "Adicionar
/// variações" quanto pela criação direta de uma célula/linha/faltantes).
class ComboDeGrade extends Equatable {
  final int corId;
  final int tamanhoId;
  final int? estampaId;

  const ComboDeGrade({
    required this.corId,
    required this.tamanhoId,
    this.estampaId,
  });

  @override
  List<Object?> get props => [corId, tamanhoId, estampaId];
}
