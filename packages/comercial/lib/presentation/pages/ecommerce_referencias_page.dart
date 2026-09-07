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
    _atualizarAcoes(_bloc.state);
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

  ({bool? rascunho, bool? publicavel}) get _filtroRequest => switch (_filtroSituacao) {
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

            return Padding(
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
                                const SizedBox(height: 8),
                                _buildRodapeTabela(context, state),
                              ],
                            ),
                          ),
                  ),
                  if (_modoSelecao) _buildBarraSelecao(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _atualizarAcoes(EcommerceReferenciasState state) {
    final podeDespublicar = state.totalPublicados != null
        ? state.totalPublicados! > 0
        : state.referencias.any((r) => !r.rascunho);
    SivPageAcoes.definir([
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
                  hintText: 'Buscar referência...',
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
              icon: const Icon(Icons.filter_list, size: 18),
              label: Text(
                _categoriaIds.isEmpty
                    ? 'Categoria'
                    : 'Categoria (${_categoriaIds.length})',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SegmentedButton<_FiltroSituacao>(
          segments: [
            ButtonSegment(
              value: _FiltroSituacao.todos,
              label: Text(_labelSegmento('Todos', state.total)),
            ),
            ButtonSegment(
              value: _FiltroSituacao.publicados,
              label: Text(_labelSegmento('Publicados', state.totalPublicados)),
            ),
            ButtonSegment(
              value: _FiltroSituacao.rascunho,
              label: Text(_labelSegmento('Rascunho', state.totalRascunho)),
            ),
            ButtonSegment(
              value: _FiltroSituacao.naoPublicaveis,
              label: Text(
                _labelSegmento('Não publicáveis', state.totalNaoPublicaveis),
              ),
            ),
          ],
          selected: {_filtroSituacao},
          onSelectionChanged: (selecao) {
            setState(() => _filtroSituacao = selecao.first);
            _recarregar();
          },
        ),
      ],
    );
  }

  String _labelSegmento(String rotulo, int? contagem) =>
      contagem == null ? rotulo : '$rotulo $contagem';

  Widget _buildTabela(BuildContext context, EcommerceReferenciasState state) {
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
        SivTabelaColuna(titulo: 'SITUAÇÃO', flex: 1),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          child: SizedBox(
            width: 34,
            height: 34,
            child: naoPublicavel
                ? _iconeMotivo(context, motivos)
                : referencia.imagemUrl != null
                    ? Image.network(
                        referencia.imagemUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImagem(context),
                      )
                    : _placeholderImagem(context),
          ),
        ),
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

  Widget _buildGradeAtiva(BuildContext context, EcommerceReferencia referencia) {
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
      return _selo('NÃO PUBLICÁVEL', textos, cores.atencaoFundo, cores.atencaoBorda, cores.atencao);
    }
    if (referencia.saldo == 0) {
      return _selo('SEM ESTOQUE', textos, null, cores.hairline, cores.textoPrincipal);
    }
    if (!referencia.rascunho) {
      return _selo('PUBLICADO', textos, cores.acoEscuro, cores.acoEscuro, cores.textoSobreEscuroTitulo);
    }
    return _selo('RASCUNHO', textos, null, cores.hairline, cores.textoPrincipal);
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

  Widget _buildRodapeTabela(BuildContext context, EcommerceReferenciasState state) {
    final textos = context.sivTextos.apoio;
    final total = state.total;
    final partes = <String>[
      if (total != null) pluralizarEcommerce(total, 'referência', 'referências'),
      if (state.totalRascunho != null) '${state.totalRascunho} em rascunho',
      if (state.totalNaoPublicaveis != null)
        '${state.totalNaoPublicaveis} não publicáveis',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          partes.isEmpty
              ? pluralizarEcommerce(state.referencias.length, 'referência', 'referências')
              : partes.join(' · '),
          style: textos,
        ),
        Text(
          total == null
              ? 'Mostrando ${state.referencias.length}'
              : 'Mostrando ${state.referencias.length} de $total',
          style: textos,
        ),
      ],
    );
  }

  Widget _buildBarraSelecao(BuildContext context, EcommerceReferenciasState state) {
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
            pluralizarEcommerce(_idsSelecionados.length, 'selecionada', 'selecionadas'),
            style: textos.corpo.copyWith(color: cores.textoSobreEscuroTitulo),
          ),
          const SizedBox(width: 12),
          if (mensagem != null)
            Expanded(
              child: Text(
                mensagem,
                style: textos.apoio.copyWith(color: cores.textoSobreEscuroApoio),
              ),
            )
          else
            const Spacer(),
          TextButton(
            onPressed: () => setState(() => _idsSelecionados.clear()),
            child: Text(
              'Limpar seleção',
              style: TextStyle(color: cores.textoSobreEscuroTitulo),
            ),
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
            child: const Text('Despublicar'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            // Bloqueadas (publicavel == false) nunca entram no lote -- nem
            // indeterminadas quando há bloqueadas junto; a decisão do backend
            // é a única fonte, não o palpite local.
            onPressed: (prontas == 0 && indeterminadas == 0) || state.processandoLote
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

  void _abrirDetalhe(BuildContext context, EcommerceReferencia referencia) async {
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
        selecionadas =
            categorias.map((categoria) => categoria.id).whereType<int>().toList();
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
        idsSelecionados =
            selecionadas.map((referencia) => referencia.id).whereType<int>().toList();
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

  String _textoFalha(EcommerceReferenciasState state, EcommerceLoteFalha falha) {
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
