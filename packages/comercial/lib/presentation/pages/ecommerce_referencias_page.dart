import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/ecommerce_referencias_bloc/ecommerce_referencias_bloc.dart';
import 'package:comercial/presentation/pages/ecommerce_referencia_detalhe_page.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentantion/widgets/categoria_seletor.dart';
import 'package:produtos/presentantion/widgets/referencia_seletor.dart';

/// Motivos de bloqueio (`motivosBloqueio`) e o texto exibido pra cada um.
/// Se o backend mandar um código fora deste mapa, mostra o próprio código.
const Map<String, String> _textoMotivoBloqueio = {
  'SEM_PRECO': 'Falta preço na tabela do canal',
  'SEM_MIDIA': 'Falta mídia — sem imagem cadastrada',
  'SEM_SALDO': 'Sem saldo em estoque',
  'SEM_GRADE_ATIVA': 'Nenhum item da grade disponível',
};

String _formatarMoeda(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

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
  bool? _rascunhoFiltro;
  bool? _publicavelFiltro;
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
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(const EcommerceReferenciasCarregarMaisSolicitou());
      }
    });
    _atualizarTitulo();
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

  void _recarregar({String? busca}) {
    _bloc.add(
      EcommerceReferenciasIniciou(
        ecommerceId: widget.ecommerceId,
        busca: (busca ?? _buscaController.text.trim()).isEmpty
            ? null
            : (busca ?? _buscaController.text.trim()),
        categoriaIds: _categoriaIds.isEmpty ? null : _categoriaIds,
        rascunhoFiltro: _rascunhoFiltro,
        publicavelFiltro: _publicavelFiltro,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocProvider<EcommerceReferenciasBloc>.value(
      value: _bloc,
      child: BlocConsumer<EcommerceReferenciasBloc, EcommerceReferenciasState>(
        listener: (context, state) {
          if (state is EcommerceReferenciasLoteConcluiu) {
            setState(() => _idsSelecionados.clear());
            if (state.falhas.isNotEmpty) {
              _mostrarFalhasDoLote(context, state.falhas);
            } else {
              SivAviso.mostrar(
                context,
                mensagem: '${state.publicados} referência(s) atualizada(s).',
              );
            }
          }
          _atualizarAcoes(context, state);
        },
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
    );
  }

  void _atualizarAcoes(BuildContext context, EcommerceReferenciasState state) {
    SivPageAcoes.definir([
      OutlinedButton.icon(
        onPressed: state.referencias.any((r) => !r.rascunho) &&
                !state.processandoLote
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
        SegmentedButton<bool?>(
          segments: [
            ButtonSegment(
              value: null,
              label: Text(_labelSegmento('Todos', state.total)),
            ),
            ButtonSegment(
              value: false,
              label: Text(_labelSegmento('Publicados', state.totalPublicados)),
            ),
            ButtonSegment(
              value: true,
              label: Text(_labelSegmento('Rascunho', state.totalRascunho)),
            ),
          ],
          selected: {_rascunhoFiltro},
          onSelectionChanged: (selecao) {
            setState(() {
              _rascunhoFiltro = selecao.first;
              _publicavelFiltro = null;
            });
            _recarregar();
          },
        ),
        const SizedBox(height: 8),
        FilterChip(
          label: Text(
            _labelSegmento('Não publicáveis', state.totalNaoPublicaveis),
          ),
          selected: _publicavelFiltro == false,
          onSelected: (selecionado) {
            setState(() {
              _publicavelFiltro = selecionado ? false : null;
              if (selecionado) _rascunhoFiltro = null;
            });
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
        SivTabelaColuna(titulo: 'REFERÊNCIA', flex: 4),
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
          _buildCelulaReferencia(context, referencia),
          Text(referencia.categoriaNome ?? '-', style: context.sivTextos.apoio),
          Text(
            referencia.valor != null
                ? _formatarMoeda(referencia.valor!)
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
        ? (_textoMotivoBloqueio[motivos.first] ?? motivos.first)
        : 'REF ${referencia.referenciaId}';

    return Row(
      children: [
        Checkbox(
          value: referencia.id != null &&
              _idsSelecionados.contains(referencia.id),
          onChanged: referencia.id == null
              ? null
              : (_) => _alternarSelecao(referencia.id!),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          child: SizedBox(
            width: 34,
            height: 34,
            child: referencia.imagemUrl != null
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
    if ((referencia.saldo ?? 0) == 0) {
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
      if (total != null) '$total referências',
      if (state.totalRascunho != null) '${state.totalRascunho} em rascunho',
      if (state.totalNaoPublicaveis != null)
        '${state.totalNaoPublicaveis} não publicáveis',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(partes.isEmpty ? '${state.referencias.length} referências' : partes.join(' · '), style: textos),
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
    final prontas = selecionadas.where((r) => r.publicavel != false).length;
    final foraDoLote = selecionadas.length - prontas;
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: cores.acoEscuro),
      child: Row(
        children: [
          Text(
            '${_idsSelecionados.length} selecionada(s)',
            style: textos.corpo.copyWith(color: cores.textoSobreEscuroTitulo),
          ),
          const SizedBox(width: 12),
          if (foraDoLote > 0)
            Expanded(
              child: Text(
                foraDoLote == selecionadas.length
                    ? 'Nenhuma está pronta pra publicar.'
                    : '$foraDoLote de ${selecionadas.length} não pode ser publicada: falta preço ou mídia.',
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
            onPressed: prontas == 0 || state.processandoLote
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
        ),
      ),
    );
    if (mounted) _recarregar();
  }

  Future<void> _abrirFiltroCategoria(BuildContext context) async {
    var selecionadas = List<int>.from(_categoriaIds);

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
              CategoriaSeletor(
                modo: CategoriaSeletorModo.multipla,
                titulo: 'Filtrar por categoria',
                idCategoriasSelecionadasIniciais: _categoriaIds,
                onCategoriaChanged: (categorias) {
                  selecionadas = categorias
                      .map((categoria) => categoria.id)
                      .whereType<int>()
                      .toList();
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  setState(() => _categoriaIds = selecionadas);
                  _recarregar();
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
              ReferenciaSeletor(
                modo: ReferenciaSeletorModo.multipla,
                permitirCadastro: false,
                onReferenciaChanged: (selecionadas) {
                  idsSelecionados = selecionadas
                      .map((referencia) => referencia.id)
                      .whereType<int>()
                      .toList();
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  for (final referenciaId in idsSelecionados) {
                    _bloc.add(
                      EcommerceReferenciaAdicionou(
                        ecommerceId: widget.ecommerceId,
                        referenciaId: referenciaId,
                      ),
                    );
                  }
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
                child: Text(
                  'Referência #${falha.id}: ${falha.motivos.map((m) => _textoMotivoBloqueio[m] ?? m).join(', ').ifEmpty('motivo não informado')}',
                ),
              ),
          ],
        ),
      ),
    );
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
