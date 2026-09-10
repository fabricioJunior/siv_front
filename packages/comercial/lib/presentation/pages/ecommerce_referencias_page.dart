import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/ecommerce_referencias_bloc/ecommerce_referencias_bloc.dart';
import 'package:comercial/presentation/pages/ecommerce_referencia_detalhe_page.dart';
import 'package:comercial/presentation/widgets/ecommerce_formatadores.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentantion/widgets/categoria_seletor.dart';
import 'package:produtos/presentantion/widgets/referencia_seletor.dart';

/// Um único controle pra situação da referência -- nunca dois estados
/// (segmento + chip) que podem discordar entre si.
enum _FiltroSituacao { todos, publicados, rascunho, naoPublicaveis }

class EcommerceReferenciasPage extends StatefulWidget {
  final int ecommerceId;
  final String? tituloCanal;

  const EcommerceReferenciasPage({
    super.key,
    required this.ecommerceId,
    this.tituloCanal,
  });

  @override
  State<EcommerceReferenciasPage> createState() =>
      _EcommerceReferenciasPageState();
}

class _EcommerceReferenciasPageState extends State<EcommerceReferenciasPage> {
  late final EcommerceReferenciasBloc _bloc;
  final _buscaController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 350);
  final _scrollController = ScrollController();

  List<int> _categoriaIds = [];
  _FiltroSituacao _filtroSituacao = _FiltroSituacao.todos;
  String? _tituloCanal;

  final Set<int> _idsSelecionados = {};
  bool get _modoSelecao => _idsSelecionados.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tituloCanal = widget.tituloCanal;
    _bloc = sl<EcommerceReferenciasBloc>()
      ..add(EcommerceReferenciasIniciou(ecommerceId: widget.ecommerceId));
    _scrollController.addListener(() {
      final state = _bloc.state;
      if (state.carregandoMais || !state.temMaisPaginas) return;
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(const EcommerceReferenciasCarregarMaisSolicitou());
      }
    });
    _atualizarTitulo();
    // Não chama _atualizarAcoes aqui -- ela lê _telaDesktop (MediaQuery),
    // proibido durante initState (context ainda não montado). O primeiro
    // build do BlocBuilder já chama _atualizarAcoes(state) sozinho.
    if (_tituloCanal == null) _buscarTituloCanal();
  }

  Future<void> _buscarTituloCanal() async {
    try {
      final ecommerce = await sl<RecuperarEcommerce>().call(widget.ecommerceId);
      if (!mounted) return;
      setState(() => _tituloCanal = ecommerce.titulo);
      _atualizarTitulo();
    } catch (_) {
      // Sem título, a migalha cai pra "E-commerces / Produtos no site".
    }
  }

  void _atualizarTitulo() {
    final canal = _tituloCanal;
    SivPageTitulo.definir(
      canal == null
          ? 'E-commerces / Produtos no site'
          : 'E-commerces / $canal / Produtos no site',
    );
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _debouncer.cancel();
    _scrollController.dispose();
    _bloc.close();
    SivPageTitulo.limpar();
    SivPageAcoes.limpar();
    super.dispose();
  }

  void _onBuscaAlterada(String valor) {
    _debouncer.run(() => _recarregar(busca: valor.trim()));
  }

  ({bool? rascunho, bool? publicavel}) get _filtroRequest =>
      switch (_filtroSituacao) {
        _FiltroSituacao.todos => (rascunho: null, publicavel: null),
        _FiltroSituacao.publicados => (rascunho: false, publicavel: null),
        _FiltroSituacao.rascunho => (rascunho: true, publicavel: null),
        _FiltroSituacao.naoPublicaveis => (rascunho: null, publicavel: false),
      };

  void _recarregar({String? busca}) {
    final filtro = _filtroRequest;
    _bloc.add(
      EcommerceReferenciasIniciou(
        ecommerceId: widget.ecommerceId,
        busca: (busca ?? _buscaController.text.trim()).isEmpty
            ? null
            : (busca ?? _buscaController.text.trim()),
        categoriaIds: _categoriaIds.isEmpty ? null : _categoriaIds,
        rascunhoFiltro: filtro.rascunho,
        publicavelFiltro: filtro.publicavel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocProvider<EcommerceReferenciasBloc>.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<EcommerceReferenciasBloc, EcommerceReferenciasState>(
            listenWhen: (previous, current) =>
                current is EcommerceReferenciasLoteConcluiu ||
                current is EcommerceReferenciasAdicionarLoteConcluiu,
            listener: (context, state) {
              setState(() => _idsSelecionados.clear());
              if (state is EcommerceReferenciasLoteConcluiu) {
                if (state.falhas.isNotEmpty) {
                  _mostrarFalhasDoLote(context, state, state.falhas);
                } else {
                  SivAviso.mostrar(
                    context,
                    mensagem:
                        '${pluralizarEcommerce(state.publicados, 'referência atualizada', 'referências atualizadas')}.',
                  );
                }
              } else if (state is EcommerceReferenciasAdicionarLoteConcluiu) {
                if (state.falhas.isNotEmpty) {
                  _mostrarFalhasDoLote(context, state, state.falhas);
                } else {
                  SivAviso.mostrar(
                    context,
                    mensagem:
                        '${pluralizarEcommerce(state.adicionados, 'referência adicionada', 'referências adicionadas')}.',
                  );
                }
              }
            },
          ),
          BlocListener<EcommerceReferenciasBloc, EcommerceReferenciasState>(
            listenWhen: (previous, current) =>
                previous.totalPublicados != current.totalPublicados ||
                previous.processandoLote != current.processandoLote ||
                previous.referencias.length != current.referencias.length,
            listener: (context, state) => _atualizarAcoes(state),
          ),
        ],
        child: BlocBuilder<EcommerceReferenciasBloc, EcommerceReferenciasState>(
          builder: (context, state) {
            // SivPageAcoes é compartilhado/global -- EcommercesPage (que
            // fica montada por trás, no shell) reafirma os botões dela em
            // todo build próprio. Se essa página não reafirma os seus a
            // cada build também, um rebuild da página de baixo (ex:
            // resize de janela via MediaQuery) rouba a barra de volta.
            _atualizarAcoes(state);
            if (state is EcommerceReferenciasCarregarEmProgresso ||
                state is EcommerceReferenciasInitial) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is EcommerceReferenciasCarregarFalha) {
              return Center(
                child: Text(
                  'Não foi possível carregar as referências.',
                  style: textos.corpo,
                ),
              );
            }

            // Scaffold próprio (não só Padding+Column) -- o body do Scaffold
            // sempre recebe altura limitada calculada internamente, não
            // depende do ancestral garantir isso. Sem ele, o Expanded/
            // SingleChildScrollView abaixo podia herdar altura ilimitada
            // dependendo de onde a página é montada, causando RenderFlex
            // overflow gigante (visto em produção). bottomNavigationBar
            // cobre a barra de seleção/rodapé fixo sem gymnastics de Column.
            return Scaffold(
              backgroundColor: cores.superficie,
              floatingActionButton: _telaDesktop || _modoSelecao
                  ? null
                  : FloatingActionButton(
                      onPressed: () => _adicionarReferencias(context),
                      tooltip: 'Adicionar referências',
                      child: const Icon(Icons.add),
                    ),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SivDimensoes.paginaHorizontal,
                  vertical: SivDimensoes.paginaVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFiltros(context, state),
                    const SizedBox(height: SivDimensoes.gapCards),
                    if (state.processandoLote)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LinearProgressIndicator(color: cores.aco),
                            if (state.loteTotal != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Processando ${state.loteAtual} de ${state.loteTotal}...',
                                  style: textos.apoio,
                                ),
                              ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: state.referencias.isEmpty
                          ? Center(
                              child: Text(
                                (state.busca ?? '').isEmpty
                                    ? 'Nenhuma referência vinculada a este e-commerce.'
                                    : 'Nenhuma referência encontrada pra "${state.busca}".',
                                style: textos.corpo,
                              ),
                            )
                          : SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildTabela(context, state),
                                  if (_telaDesktop)
                                    _buildRodapeTabelaDesktop(context, state)
                                  else ...[
                                    const SizedBox(height: 8),
                                    _buildRodapeTabela(context, state),
                                  ],
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: _modoSelecao
                  ? _buildBarraSelecao(context, state)
                  : (!_telaDesktop
                      // Fora do modo seleção -- no desktop "Publicar aptas"
                      // já vive em SivPageAcoes (cabe no topo); no mobile
                      // essas ações dividem espaço com o título e ficam
                      // pouco descobríveis, daí o rodapé complementar.
                      ? _buildRodapeFixo(context, state)
                      : null),
            );
          },
        ),
      ),
    );
  }

  void _atualizarAcoes(EcommerceReferenciasState state) {
    // Mobile: barra de título não tem espaço pra 3 botões (mesmo com Wrap,
    // fica poluído numa tela estreita) -- some com a barra de ações e usa
    // FAB só pra a ação primária (adicionar). "Publicar aptas" continua
    // acessível no rodapé fixo (_buildRodapeFixo) e na barra de seleção.
    if (!_telaDesktop) {
      SivPageAcoes.definir(const []);
      return;
    }

    final podeDespublicar = state.totalPublicados != null
        ? state.totalPublicados! > 0
        : state.referencias.any((r) => !r.rascunho);
    final aptasIds = _idsAptasParaPublicar(state);
    SivPageAcoes.definir([
      OutlinedButton.icon(
        onPressed: aptasIds.isEmpty || state.processandoLote
            ? null
            : () => _publicarAptas(context, aptasIds),
        icon: const Icon(Icons.publish_outlined, size: 18),
        label: Text('Publicar aptas (${aptasIds.length})'),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: podeDespublicar && !state.processandoLote
            ? () => _despublicarTodas(context)
            : null,
        icon: const Icon(Icons.visibility_off_outlined, size: 18),
        label: const Text('Despublicar todas'),
      ),
      const SizedBox(width: 8),
      FilledButton.icon(
        onPressed: () => _adicionarReferencias(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Adicionar referências'),
      ),
    ]);
  }

  Widget _buildFiltros(BuildContext context, EcommerceReferenciasState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _buscaController,
                onChanged: _onBuscaAlterada,
                onSubmitted: _onBuscaAlterada,
                decoration: InputDecoration(
                  hintText: 'Buscar referência por nome ou código',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _buscaController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _buscaController.clear();
                            _recarregar(busca: '');
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _abrirFiltroCategoria(context),
              icon: const Icon(Icons.filter_alt_outlined, size: 15),
              label: Text(
                _categoriaIds.isEmpty
                    ? 'Categorias'
                    : 'Categorias · ${_categoriaIds.length}',
                style: const TextStyle(fontSize: 12.5),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                iconSize: 15,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFiltroSituacao(context, state),
      ],
    );
  }

  String _labelSegmento(String rotulo, int? contagem) =>
      contagem == null ? rotulo : '$rotulo $contagem';

  // Segmentos retangulares com preenchimento sólido no selecionado (visual
  // "blueprint") -- SegmentedButton padrão do Material não estica os
  // segmentos em partes iguais nem aceita fundo 100% sólido sem borda
  // residual, por isso vira um Row customizado em vez de tentar forçar o
  // estilo do widget pronto.
  Widget _buildFiltroSituacao(
      BuildContext context, EcommerceReferenciasState state) {
    final cores = context.sivColors;
    final segmentos = [
      (_FiltroSituacao.todos, 'Todos', state.total),
      (
        _FiltroSituacao.publicados,
        _telaDesktop ? 'Publicados' : 'Public.',
        state.totalPublicados,
      ),
      (
        _FiltroSituacao.rascunho,
        _telaDesktop ? 'Rascunho' : 'Rasc.',
        state.totalRascunho,
      ),
      (
        _FiltroSituacao.naoPublicaveis,
        _telaDesktop ? 'Não publicáveis' : 'Bloq.',
        state.totalNaoPublicaveis,
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segmentos.length; i++)
            Expanded(
              child: _segmentoSituacao(
                context,
                rotulo: segmentos[i].$2,
                contagem: segmentos[i].$3,
                selecionado: _filtroSituacao == segmentos[i].$1,
                comBordaEsquerda: i > 0,
                onTap: () {
                  setState(() => _filtroSituacao = segmentos[i].$1);
                  _recarregar();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _segmentoSituacao(
    BuildContext context, {
    required String rotulo,
    required int? contagem,
    required bool selecionado,
    required bool comBordaEsquerda,
    required VoidCallback onTap,
  }) {
    final cores = context.sivColors;
    // InkWell precisa de um Material ancestor pra pintar o ripple --
    // SegmentedButton (widget anterior) já carregava o dele embutido; este
    // Row customizado não, então declara explicitamente (transparent, não
    // adiciona nenhuma superfície visual nova).
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selecionado ? cores.aco : null,
            border: comBordaEsquerda
                ? Border(left: BorderSide(color: cores.hairline))
                : null,
          ),
          child: Text(
            _labelSegmento(rotulo.toUpperCase(), contagem),
            textAlign: TextAlign.center,
            style: context.sivTextos.rotulo.copyWith(
              color: selecionado ? cores.textoSobreEscuroTitulo : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabela(BuildContext context, EcommerceReferenciasState state) {
    if (!_telaDesktop) return _buildListaCartoes(context, state);
    return SivTabela(
      colunas: const [
        SivTabelaColuna(titulo: '', flex: 1),
        SivTabelaColuna(titulo: 'REFERÊNCIA', flex: 3),
        SivTabelaColuna(titulo: 'CATEGORIA', flex: 2),
        SivTabelaColuna.numerica(titulo: 'PREÇO', flex: 1),
        SivTabelaColuna(
          titulo: 'GRADE ATIVA',
          alinhamento: TextAlign.center,
          flex: 1,
        ),
        SivTabelaColuna(
          titulo: 'SITUAÇÃO',
          alinhamento: TextAlign.right,
          flex: 1,
        ),
      ],
      quantidadeLinhas: state.referencias.length,
      linhaSelecionada: (indice) {
        final id = state.referencias[indice].id;
        return id != null && _idsSelecionados.contains(id);
      },
      onLinhaTap: (indice) => _abrirDetalhe(context, state.referencias[indice]),
      linhaBuilder: (context, indice) {
        final referencia = state.referencias[indice];
        return [
          Checkbox(
            value: referencia.id != null &&
                _idsSelecionados.contains(referencia.id),
            onChanged: referencia.id == null
                ? null
                : (_) => _alternarSelecao(referencia.id!),
          ),
          _buildCelulaReferencia(context, referencia),
          Text(referencia.categoriaNome ?? '-', style: context.sivTextos.apoio),
          Text(
            referencia.valor != null
                ? formatarMoedaEcommerce(referencia.valor!)
                : 'Sem preço',
            style: context.sivTextos.corpo,
          ),
          _buildGradeAtiva(context, referencia),
          _buildSituacao(context, referencia),
        ];
      },
    );
  }

  Widget _buildListaCartoes(
      BuildContext context, EcommerceReferenciasState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final referencia in state.referencias)
          _buildCartaoReferencia(context, referencia),
      ],
    );
  }

  Widget _buildCartaoReferencia(
    BuildContext context,
    EcommerceReferencia referencia,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final selecionada =
        referencia.id != null && _idsSelecionados.contains(referencia.id);
    final naoPublicavel = referencia.publicavel == false;
    final motivos = referencia.motivosBloqueio;
    final subtitulo = naoPublicavel && motivos != null && motivos.isNotEmpty
        ? (textoMotivoBloqueioEcommerce[motivos.first] ?? motivos.first)
        : 'REF ${referencia.referenciaId}'
            '${referencia.categoriaNome != null ? ' · ${referencia.categoriaNome}' : ''}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _abrirDetalhe(context, referencia),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              // Alerta laranja pra não publicável reaproveita os tokens já
              // usados no selo (atencaoFundo/atencaoBorda) -- bate perto o
              // suficiente do mock pra não justificar cor nova hardcoded.
              color: naoPublicavel
                  ? cores.atencaoFundo
                  : (selecionada ? cores.selecaoFundo : cores.superficie),
              border: Border.all(
                color: naoPublicavel
                    ? cores.atencaoBorda
                    : (selecionada ? cores.aco : cores.hairline),
              ),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: selecionada,
                  onChanged: referencia.id == null
                      ? null
                      : (_) => _alternarSelecao(referencia.id!),
                ),
                _buildMiniatura(context, referencia),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        referencia.referenciaNome ??
                            'Referência #${referencia.referenciaId}',
                        style: textos.corpo,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitulo,
                        style: textos.apoio.copyWith(
                          color: naoPublicavel ? cores.atencao : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      referencia.valor != null
                          ? formatarMoedaEcommerce(referencia.valor!)
                          : 'Sem preço',
                      style: textos.corpo,
                    ),
                    const SizedBox(height: 6),
                    _buildSituacao(context, referencia),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniatura(BuildContext context, EcommerceReferencia referencia) {
    final naoPublicavel = referencia.publicavel == false;
    return ClipRRect(
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      child: SizedBox(
        width: 34,
        height: 34,
        child: naoPublicavel
            ? _iconeMotivo(context, referencia.motivosBloqueio)
            : referencia.imagemUrl != null
                ? Image.network(
                    referencia.imagemUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImagem(context),
                  )
                : _placeholderImagem(context),
      ),
    );
  }

  Widget _buildCelulaReferencia(
    BuildContext context,
    EcommerceReferencia referencia,
  ) {
    final textos = context.sivTextos;
    final motivos = referencia.motivosBloqueio;
    final naoPublicavel = referencia.publicavel == false;
    final subtitulo = naoPublicavel && motivos != null && motivos.isNotEmpty
        ? (textoMotivoBloqueioEcommerce[motivos.first] ?? motivos.first)
        : 'REF ${referencia.referenciaId}';

    return Row(
      children: [
        _buildMiniatura(context, referencia),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                referencia.referenciaNome ??
                    'Referência #${referencia.referenciaId}',
                style: textos.corpo,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitulo,
                style: textos.apoio.copyWith(
                  color: naoPublicavel ? context.sivColors.atencao : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Miniatura da linha não publicável mostra o que falta em vez da
  /// imagem -- a linha se explica sem precisar ler o texto de apoio.
  Widget _iconeMotivo(BuildContext context, List<String>? motivos) {
    final cores = context.sivColors;
    final motivo = (motivos == null || motivos.isEmpty) ? null : motivos.first;
    final icone = switch (motivo) {
      'SEM_PRECO' => Icons.attach_money,
      'SEM_MIDIA' => Icons.image_not_supported_outlined,
      'SEM_SALDO' => Icons.inventory_2_outlined,
      'SEM_GRADE_ATIVA' => Icons.grid_off_outlined,
      _ => Icons.error_outline,
    };
    return Container(
      color: cores.atencaoFundo,
      child: Icon(icone, color: cores.atencao, size: 18),
    );
  }

  Widget _buildGradeAtiva(
      BuildContext context, EcommerceReferencia referencia) {
    final total = referencia.produtosTotal;
    final disponiveis = referencia.produtosDisponiveis;
    if (total == null || disponiveis == null) {
      return Text('-', style: context.sivTextos.apoio);
    }
    return Text(
      '$disponiveis / $total',
      textAlign: TextAlign.center,
      style: context.sivTextos.secao.copyWith(fontSize: 17),
    );
  }

  Widget _buildSituacao(BuildContext context, EcommerceReferencia referencia) {
    final cores = context.sivColors;
    final textos = context.sivTextos.rotulo;

    if (referencia.publicavel == false) {
      // Selo em vinho (não no laranja de alerta do card) -- o mock isola a
      // urgência da tag do aviso geral do card, cores.vinho já bate exato
      // com o vermelho pedido (#8a2f2f).
      final fundoVinho = cores.vinho.withValues(alpha: 0.12);
      return _selo(
          'NÃO PUBLICÁVEL', textos, fundoVinho, fundoVinho, cores.vinho);
    }
    if (referencia.saldo == 0) {
      return _selo(
          'SEM ESTOQUE', textos, null, cores.hairline, cores.textoPrincipal);
    }
    if (!referencia.rascunho) {
      return _selo('PUBLICADO', textos, cores.acoEscuro, cores.acoEscuro,
          cores.textoSobreEscuroTitulo);
    }
    return _selo(
        'RASCUNHO', textos, null, cores.hairline, cores.textoPrincipal);
  }

  Widget _selo(
    String texto,
    TextStyle estilo,
    Color? fundo,
    Color borda,
    Color corTexto,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        border: Border.all(color: borda),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Text(texto, style: estilo.copyWith(color: corTexto)),
    );
  }

  Widget _buildRodapeTabela(
      BuildContext context, EcommerceReferenciasState state) {
    final textos = context.sivTextos.apoio;
    final total = state.total;
    final partes = <String>[
      if (total != null)
        pluralizarEcommerce(total, 'referência', 'referências'),
      if (state.totalRascunho != null) '${state.totalRascunho} em rascunho',
      if (state.totalNaoPublicaveis != null)
        '${state.totalNaoPublicaveis} não publicáveis',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Expanded + ellipsis -- os contadores concatenados (referências +
        // rascunho + não publicáveis) não cabem ao lado de "Mostrando X de Y"
        // em telas estreitas (overflow observado em teste); trunca em vez de
        // vazar.
        Expanded(
          child: Text(
            partes.isEmpty
                ? pluralizarEcommerce(
                    state.referencias.length, 'referência', 'referências')
                : partes.join(' · '),
            style: textos,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          total == null
              ? 'Mostrando ${state.referencias.length}'
              : 'Mostrando ${state.referencias.length} de $total',
          style: textos,
        ),
      ],
    );
  }

  // Desktop: rodapé emendado embaixo da SivTabela (borda superior + fundo
  // recuado), como no mock. Mobile mantém o rodapé solto sem esse invólucro
  // -- já aprovado, não mexe.
  Widget _buildRodapeTabelaDesktop(
      BuildContext context, EcommerceReferenciasState state) {
    final cores = context.sivColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SivDimensoes.cabecalhoTabelaHorizontal,
        vertical: SivDimensoes.cabecalhoTabelaVertical,
      ),
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: cores.superficieRecuada,
        border: Border(top: BorderSide(color: cores.hairline)),
      ),
      child: _buildRodapeTabela(context, state),
    );
  }

  Widget _buildRodapeFixo(
      BuildContext context, EcommerceReferenciasState state) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final total = state.total;
    final aptasIds = _idsAptasParaPublicar(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: cores.hairline))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            total == null
                ? 'Mostrando ${state.referencias.length}'
                : 'Mostrando ${state.referencias.length} de $total',
            style: textos.apoio,
          ),
          FilledButton(
            onPressed: aptasIds.isEmpty || state.processandoLote
                ? null
                : () => _publicarAptas(context, aptasIds),
            child: Text('PUBLICAR APTAS (${aptasIds.length})'),
          ),
        ],
      ),
    );
  }

  Widget _buildBarraSelecao(
      BuildContext context, EcommerceReferenciasState state) {
    final selecionadas = state.referencias
        .where((r) => r.id != null && _idsSelecionados.contains(r.id))
        .toList();
    final prontas = selecionadas.where((r) => r.publicavel == true).length;
    final bloqueadas = selecionadas.where((r) => r.publicavel == false).length;
    final indeterminadas = selecionadas.length - prontas - bloqueadas;
    final cores = context.sivColors;
    final textos = context.sivTextos;

    String? mensagem;
    if (bloqueadas > 0) {
      mensagem = bloqueadas == selecionadas.length
          ? 'Nenhuma está pronta pra publicar.'
          : '$bloqueadas de ${selecionadas.length} não pode ser publicada: falta preço ou mídia.';
    } else if (indeterminadas > 0) {
      mensagem = 'Não é possível verificar antes de publicar.';
    } else if (selecionadas.isNotEmpty) {
      mensagem =
          '${pluralizarEcommerce(prontas, 'está pronta', 'estão prontas')} para publicar.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: cores.acoEscuro),
      child: Row(
        children: [
          Text(
            pluralizarEcommerce(
                _idsSelecionados.length, 'selecionada', 'selecionadas'),
            style: textos.secao.copyWith(color: cores.textoSobreEscuroTitulo),
          ),
          const SizedBox(width: 14),
          if (mensagem != null)
            Expanded(
              child: Text(
                mensagem,
                style:
                    textos.apoio.copyWith(color: cores.textoSobreEscuroApoio),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          TextButton(
            onPressed: () => setState(() => _idsSelecionados.clear()),
            // #BDD8F2 hardcoded -- sem token exato pra esse azul claro sobre
            // aço escuro (textoSobreEscuroApoio/ceu é #94BCE3, mais escuro
            // que o pedido no mock).
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFBDD8F2)),
            child: const Text('Limpar seleção'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: state.processandoLote
                ? null
                : () => _bloc.add(
                      EcommerceReferenciasPublicarEmLoteSolicitou(
                        ecommerceId: widget.ecommerceId,
                        referenciaEcommerceIds: _idsSelecionados.toList(),
                        rascunho: true,
                      ),
                    ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cores.textoSobreEscuroTitulo,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Text('Despublicar'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            // Bloqueadas (publicavel == false) nunca entram no lote -- nem
            // indeterminadas quando há bloqueadas junto; a decisão do backend
            // é a única fonte, não o palpite local.
            onPressed:
                (prontas == 0 && indeterminadas == 0) || state.processandoLote
                    ? null
                    : () => _bloc.add(
                          EcommerceReferenciasPublicarEmLoteSolicitou(
                            ecommerceId: widget.ecommerceId,
                            referenciaEcommerceIds: selecionadas
                                .where((r) => r.publicavel != false)
                                .map((r) => r.id!)
                                .toList(),
                            rascunho: false,
                          ),
                        ),
            style: FilledButton.styleFrom(
              backgroundColor: cores.ceu,
              foregroundColor: cores.acoEscuro,
              disabledBackgroundColor: cores.ceu.withValues(alpha: 0.35),
              disabledForegroundColor: cores.acoEscuro.withValues(alpha: 0.5),
            ),
            child: const Text('Publicar selecionadas'),
          ),
        ],
      ),
    );
  }

  void _alternarSelecao(int id) {
    setState(() {
      if (!_idsSelecionados.remove(id)) {
        _idsSelecionados.add(id);
      }
    });
  }

  void _abrirDetalhe(
      BuildContext context, EcommerceReferencia referencia) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EcommerceReferenciaDetalhePage(
          ecommerceId: widget.ecommerceId,
          referencia: referencia,
          tituloCanal: _tituloCanal,
        ),
      ),
    );
    if (mounted) _recarregar();
  }

  bool get _telaDesktop =>
      MediaQuery.sizeOf(context).width >= SivDimensoes.breakpointMenuDrawer;

  Future<void> _abrirFiltroCategoria(BuildContext context) async {
    var selecionadas = List<int>.from(_categoriaIds);

    final conteudo = CategoriaSeletor(
      modo: CategoriaSeletorModo.multipla,
      titulo: 'Filtrar por categoria',
      idCategoriasSelecionadasIniciais: _categoriaIds,
      onCategoriaChanged: (categorias) {
        selecionadas = categorias
            .map((categoria) => categoria.id)
            .whereType<int>()
            .toList();
      },
    );

    void aplicar() {
      setState(() => _categoriaIds = selecionadas);
      _recarregar();
    }

    if (_telaDesktop) {
      await SivDialogo.mostrar(
        context,
        titulo: 'Filtrar por categoria',
        corpo: SizedBox(height: 420, child: conteudo),
        textoAcao: 'Aplicar',
        onConfirmar: (_) => aplicar(),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              conteudo,
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  aplicar();
                },
                child: const Text('Aplicar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _adicionarReferencias(BuildContext context) async {
    List<int> idsSelecionados = [];

    void adicionar() {
      if (idsSelecionados.isEmpty) return;
      _bloc.add(
        EcommerceReferenciasAdicionarEmLoteSolicitou(
          ecommerceId: widget.ecommerceId,
          referenciaIds: idsSelecionados,
        ),
      );
    }

    final conteudo = ReferenciaSeletor(
      modo: ReferenciaSeletorModo.multipla,
      permitirCadastro: false,
      onReferenciaChanged: (selecionadas) {
        idsSelecionados = selecionadas
            .map((referencia) => referencia.id)
            .whereType<int>()
            .toList();
      },
    );

    if (_telaDesktop) {
      await SivDialogo.mostrar(
        context,
        titulo: 'Adicionar referências',
        corpo: SizedBox(height: 420, child: conteudo),
        textoAcao: 'Adicionar',
        onConfirmar: (_) => adicionar(),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              conteudo,
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  adicionar();
                },
                child: const Text('Adicionar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Só considera as referências já carregadas (mesma limitação de
  // _despublicarTodas) -- não busca páginas restantes.
  List<int> _idsAptasParaPublicar(EcommerceReferenciasState state) {
    return state.referencias
        .where((r) => r.id != null && r.rascunho && r.publicavel == true)
        .map((r) => r.id!)
        .toList();
  }

  Future<void> _publicarAptas(BuildContext context, List<int> ids) async {
    await SivDialogo.mostrar(
      context,
      titulo: 'Publicar todas as aptas',
      corpo: Text(
        '${pluralizarEcommerce(ids.length, 'referência será publicada', 'referências serão publicadas')} no site.',
      ),
      textoAcao: 'Publicar',
      onConfirmar: (_) => _bloc.add(
        EcommerceReferenciasPublicarEmLoteSolicitou(
          ecommerceId: widget.ecommerceId,
          referenciaEcommerceIds: ids,
          rascunho: false,
        ),
      ),
    );
  }

  Future<void> _despublicarTodas(BuildContext context) async {
    await SivDialogo.mostrar(
      context,
      titulo: 'Despublicar todas as referências',
      variante: SivDialogoVariante.destrutivo,
      corpo: const Text(
        'Todas as referências publicadas deste e-commerce vão sair do '
        'site imediatamente. Essa ação pode ser desfeita depois, '
        'republicando cada referência.',
      ),
      textoAcao: 'Despublicar todas',
      onConfirmar: (_) => _bloc.add(
        EcommerceReferenciasDespublicarTodasSolicitou(
          ecommerceId: widget.ecommerceId,
        ),
      ),
    );
  }

  void _mostrarFalhasDoLote(
    BuildContext context,
    EcommerceReferenciasState state,
    List<EcommerceLoteFalha> falhas,
  ) {
    SivDialogo.mostrar(
      context,
      titulo: 'Algumas referências não foram publicadas',
      onConfirmar: (_) {},
      textoAcao: 'Entendi',
      corpo: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final falha in falhas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(_textoFalha(state, falha)),
              ),
          ],
        ),
      ),
    );
  }

  String _textoFalha(
      EcommerceReferenciasState state, EcommerceLoteFalha falha) {
    final candidatas =
        state.referencias.where((r) => r.id == falha.id).toList();
    final nome = candidatas.isEmpty
        ? 'Referência #${falha.id}'
        : (candidatas.first.referenciaNome ??
            'Referência #${candidatas.first.referenciaId}');
    final motivos = falha.motivos
        .map((m) => textoMotivoBloqueioEcommerce[m] ?? m)
        .join(', ')
        .ifEmpty('motivo não informado');
    return '$nome: $motivos';
  }

  Widget _placeholderImagem(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      color: cores.superficieRecuada,
      child: Icon(Icons.image_not_supported_outlined, color: cores.textoApoio),
    );
  }
}

extension _StringOrDefault on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
