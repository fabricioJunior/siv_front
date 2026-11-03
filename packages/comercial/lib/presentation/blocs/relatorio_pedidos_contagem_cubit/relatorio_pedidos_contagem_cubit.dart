import 'package:comercial/domain/data/gateways/i_filtros_pedidos_contagem_gateway.dart';
import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';
import 'package:comercial/domain/use_cases/relatorio_pedidos_contagem_use_cases.dart';
import 'package:core/bloc.dart';

const tamanhoPaginaPedidosContagem = 30;

/// Acima disso o "em aberto há" fica âmbar.
const diasAlertaContagemAberta = 30;

enum PeriodoContagem {
  esteMes('Este mês'),
  mesAnterior('Mês anterior'),
  ultimos90('Últimos 90 dias'),
  esteAno('Este ano'),
  tudo('Tudo'),
  personalizado('Personalizado');

  final String rotulo;
  const PeriodoContagem(this.rotulo);
}

(DateTime?, DateTime?) datasDoPeriodo(PeriodoContagem p, DateTime hoje) {
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  return switch (p) {
    PeriodoContagem.esteMes => (DateTime(dia.year, dia.month), dia),
    PeriodoContagem.mesAnterior => (
        DateTime(dia.year, dia.month - 1),
        DateTime(dia.year, dia.month, 0),
      ),
    PeriodoContagem.ultimos90 => (dia.subtract(const Duration(days: 89)), dia),
    PeriodoContagem.esteAno => (DateTime(dia.year), dia),
    PeriodoContagem.tudo || PeriodoContagem.personalizado => (null, null),
  };
}

class RelatorioPedidosContagemState {
  final bool carregando;
  final bool carregandoMais;
  final String? erro;
  final PeriodoContagem periodo;
  final FiltroPedidosContagem filtro;
  final OpcaoFiltro? categoria;
  final OpcaoFiltro? referencia;
  final OpcaoFiltro? produto;

  /// Muda a cada "Limpar filtros", para o seletor de fornecedor se refazer.
  final int limpezas;
  final ResumoPedidosContagem resumo;
  final List<PedidoContagemLinha> linhas;
  final int totalItems;
  final Set<int> expandidos;
  final Map<int, List<ItemPedidoContagem>> itens;
  final Set<int> itensComErro;

  const RelatorioPedidosContagemState({
    required this.filtro,
    this.carregando = true,
    this.carregandoMais = false,
    this.erro,
    this.periodo = PeriodoContagem.ultimos90,
    this.categoria,
    this.referencia,
    this.produto,
    this.limpezas = 0,
    this.resumo = const ResumoPedidosContagem(),
    this.linhas = const [],
    this.totalItems = 0,
    this.expandidos = const {},
    this.itens = const {},
    this.itensComErro = const {},
  });

  bool get temMais => linhas.length < totalItems;

  /// Algo além de situação, período e ordenação.
  bool get temFiltro =>
      filtro.temFiltroItem ||
      filtro.pessoaId != null ||
      filtro.busca.isNotEmpty ||
      filtro.etapa != null;

  RelatorioPedidosContagemState copyWith({
    bool? carregando,
    bool? carregandoMais,
    Object? erro = _manter,
    PeriodoContagem? periodo,
    FiltroPedidosContagem? filtro,
    Object? categoria = _manter,
    Object? referencia = _manter,
    Object? produto = _manter,
    int? limpezas,
    ResumoPedidosContagem? resumo,
    List<PedidoContagemLinha>? linhas,
    int? totalItems,
    Set<int>? expandidos,
    Map<int, List<ItemPedidoContagem>>? itens,
    Set<int>? itensComErro,
  }) =>
      RelatorioPedidosContagemState(
        carregando: carregando ?? this.carregando,
        carregandoMais: carregandoMais ?? this.carregandoMais,
        erro: identical(erro, _manter) ? this.erro : erro as String?,
        periodo: periodo ?? this.periodo,
        filtro: filtro ?? this.filtro,
        categoria: identical(categoria, _manter)
            ? this.categoria
            : categoria as OpcaoFiltro?,
        referencia: identical(referencia, _manter)
            ? this.referencia
            : referencia as OpcaoFiltro?,
        produto: identical(produto, _manter)
            ? this.produto
            : produto as OpcaoFiltro?,
        limpezas: limpezas ?? this.limpezas,
        resumo: resumo ?? this.resumo,
        linhas: linhas ?? this.linhas,
        totalItems: totalItems ?? this.totalItems,
        expandidos: expandidos ?? this.expandidos,
        itens: itens ?? this.itens,
        itensComErro: itensComErro ?? this.itensComErro,
      );
}

const _manter = Object();

class RelatorioPedidosContagemCubit
    extends Cubit<RelatorioPedidosContagemState> {
  final ObterRelatorioPedidosContagem _relatorio;
  final ObterItensPedidoContagem _itens;
  final ListarCategoriasFiltroContagem _categorias;
  final BuscarReferenciasFiltroContagem _referencias;
  final ListarProdutosFiltroContagem _produtos;
  final DateTime Function() _agora;

  RelatorioPedidosContagemCubit(
    this._relatorio,
    this._itens,
    this._categorias,
    this._referencias,
    this._produtos, {
    DateTime Function()? agora,
  })  : _agora = agora ?? DateTime.now,
        super(
          RelatorioPedidosContagemState(
            filtro: _filtroInicial((agora ?? DateTime.now)()),
          ),
        );

  static FiltroPedidosContagem _filtroInicial(DateTime hoje) {
    final (de, ate) = datasDoPeriodo(PeriodoContagem.ultimos90, hoje);
    return FiltroPedidosContagem(de: de, ate: ate);
  }

  Future<void> iniciar() => _carregar(state);

  Future<void> recarregar() => _carregar(state);

  Future<List<OpcaoFiltro>> categorias() => _categorias();

  Future<List<OpcaoFiltro>> referencias(String busca) =>
      _referencias(categoriaId: state.categoria?.id, busca: busca);

  Future<List<OpcaoFiltro>> produtos() async =>
      state.referencia == null ? const [] : _produtos(state.referencia!.id);

  Future<void> alterarSituacao(SituacaoContagem s) {
    if (s == state.filtro.situacao) return Future.value();
    // Etapa só vale para quem tem pedido em aberto.
    return _carregar(
      state.copyWith(
        filtro: state.filtro.copyWith(
          situacao: s,
          etapa: s == SituacaoContagem.faturado ? null : state.filtro.etapa,
        ),
      ),
    );
  }

  Future<void> alterarPeriodo(PeriodoContagem p) {
    final (de, ate) = datasDoPeriodo(p, _agora());
    return _carregar(
      state.copyWith(
        periodo: p,
        filtro: state.filtro.copyWith(de: de, ate: ate),
      ),
    );
  }

  Future<void> alterarDatas(DateTime de, DateTime ate) => _carregar(
        state.copyWith(
          periodo: PeriodoContagem.personalizado,
          filtro: state.filtro.copyWith(de: de, ate: ate),
        ),
      );

  Future<void> alterarCategoria(OpcaoFiltro? c) {
    final limpaReferencia = c != null &&
        state.referencia?.categoriaId != null &&
        state.referencia!.categoriaId != c.id;
    return _carregar(
      state.copyWith(
        categoria: c,
        referencia: limpaReferencia ? null : state.referencia,
        produto: limpaReferencia ? null : state.produto,
        filtro: state.filtro.copyWith(
          categoriaId: c?.id,
          referenciaId: limpaReferencia ? null : state.filtro.referenciaId,
          produtoId: limpaReferencia ? null : state.filtro.produtoId,
        ),
      ),
    );
  }

  Future<void> alterarReferencia(OpcaoFiltro? r) => _carregar(
        state.copyWith(
          referencia: r,
          produto: null,
          filtro: state.filtro.copyWith(referenciaId: r?.id, produtoId: null),
        ),
      );

  Future<void> alterarProduto(OpcaoFiltro? p) => _carregar(
        state.copyWith(
          produto: p,
          filtro: state.filtro.copyWith(produtoId: p?.id),
        ),
      );

  Future<void> alterarFornecedor(int? pessoaId) => _carregar(
        state.copyWith(filtro: state.filtro.copyWith(pessoaId: pessoaId)),
      );

  Future<void> buscar(String texto) {
    if (texto.trim() == state.filtro.busca) return Future.value();
    return _carregar(
      state.copyWith(filtro: state.filtro.copyWith(busca: texto.trim())),
    );
  }

  /// Tocar na etapa já escolhida limpa o filtro.
  Future<void> alternarEtapa(String? etapa) => _carregar(
        state.copyWith(
          filtro: state.filtro.copyWith(
            etapa: etapa == state.filtro.etapa ? null : etapa,
          ),
        ),
      );

  /// [coluna]: data, pecas ou custo. Repetir a coluna inverte a ordem.
  Future<void> ordenar(String coluna) {
    final f = state.filtro;
    final inverte = f.ordenarPor == coluna;
    return _carregar(
      state.copyWith(
        filtro: f.copyWith(
          ordenarPor: coluna,
          ordem: inverte && f.ordem == 'desc' ? 'asc' : 'desc',
        ),
      ),
    );
  }

  Future<void> limparFiltros() => _carregar(
        state.copyWith(
          categoria: null,
          referencia: null,
          produto: null,
          limpezas: state.limpezas + 1,
          filtro: state.filtro.copyWith(
            categoriaId: null,
            referenciaId: null,
            produtoId: null,
            pessoaId: null,
            busca: '',
            etapa: null,
          ),
        ),
      );

  Future<void> _carregar(RelatorioPedidosContagemState novo) async {
    emit(
      novo.copyWith(
        carregando: true,
        erro: null,
        expandidos: const {},
        itens: const {},
        itensComErro: const {},
      ),
    );
    final filtro = novo.filtro;
    try {
      final r = await _relatorio(filtro, tamanho: tamanhoPaginaPedidosContagem);
      if (isClosed || filtro != state.filtro) return;
      emit(
        state.copyWith(
          carregando: false,
          resumo: r.resumo,
          linhas: r.itens,
          totalItems: r.totalItems,
        ),
      );
    } catch (e, s) {
      if (isClosed || filtro != state.filtro) return;
      emit(
        state.copyWith(
          carregando: false,
          linhas: const [],
          erro: 'Falha ao carregar o relatório.',
        ),
      );
      addError(e, s);
    }
  }

  Future<void> carregarMais() async {
    if (state.carregando || state.carregandoMais || !state.temMais) return;
    final filtro = state.filtro;
    emit(state.copyWith(carregandoMais: true));
    try {
      final pagina = state.linhas.length ~/ tamanhoPaginaPedidosContagem + 1;
      final r = await _relatorio(
        filtro,
        pagina: pagina,
        tamanho: tamanhoPaginaPedidosContagem,
      );
      if (isClosed || filtro != state.filtro) return;
      emit(
        state.copyWith(
          carregandoMais: false,
          linhas: [...state.linhas, ...r.itens],
          totalItems: r.totalItems,
        ),
      );
    } catch (e, s) {
      if (isClosed) return;
      emit(state.copyWith(carregandoMais: false));
      addError(e, s);
    }
  }

  Future<void> alternarLinha(int pedidoId) async {
    final abertos = {...state.expandidos};
    if (!abertos.remove(pedidoId)) {
      abertos.add(pedidoId);
      emit(state.copyWith(expandidos: abertos));
      if (!state.itens.containsKey(pedidoId)) await carregarItens(pedidoId);
      return;
    }
    emit(state.copyWith(expandidos: abertos));
  }

  Future<void> carregarItens(int pedidoId) async {
    final filtro = state.filtro;
    emit(
      state.copyWith(
        itensComErro: {...state.itensComErro}..remove(pedidoId),
      ),
    );
    try {
      final itens = await _itens(
        pedidoId,
        categoriaId: filtro.categoriaId,
        referenciaId: filtro.referenciaId,
        produtoId: filtro.produtoId,
      );
      if (isClosed || filtro != state.filtro) return;
      emit(state.copyWith(itens: {...state.itens, pedidoId: itens}));
    } catch (e, s) {
      if (isClosed) return;
      emit(state.copyWith(itensComErro: {...state.itensComErro, pedidoId}));
      addError(e, s);
    }
  }

  /// Todas as páginas do filtro atual (para CSV/PDF).
  Future<List<PedidoContagemLinha>> todasAsLinhas() async {
    final todas = <PedidoContagemLinha>[];
    var pagina = 1;
    while (true) {
      final r = await _relatorio(state.filtro, pagina: pagina, tamanho: 100);
      todas.addAll(r.itens);
      if (r.itens.isEmpty || todas.length >= r.totalItems) return todas;
      pagina++;
    }
  }
}
