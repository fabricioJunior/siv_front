import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';
import 'package:produtos/presentantion/widgets/referencia_produtos_tab.dart';
import 'package:produtos/presentantion/widgets/referencia_precos_tab.dart';
import 'package:produtos/presentantion/widgets/referencia_mobile.dart';
import 'package:produtos/presentantion/widgets/adicionar_variacoes_painel.dart';

/// Tela de detalhe da Referência -- Parte 1 (desktop, largura >= 1024) e
/// Parte 2 (mobile, largura < [SivDimensoes.breakpointMenuDrawer]). Ambas
/// reaproveitam os mesmos blocs (`ReferenciaBloc`, `ProdutosDaReferenciaBloc`,
/// `AdicionarVariacoesBloc`, `PrecosDaReferenciaBloc`), só muda a apresentação.
class ReferenciaPage extends StatefulWidget {
  final int idReferencia;

  const ReferenciaPage({super.key, required this.idReferencia});

  @override
  State<ReferenciaPage> createState() => _ReferenciaPageState();
}

class _ReferenciaPageState extends State<ReferenciaPage>
    with SingleTickerProviderStateMixin {
  late final ReferenciaBloc _referenciaBloc;
  late final ProdutosDaReferenciaBloc _produtosBloc;
  late final PrecosDaReferenciaBloc _precosBloc;
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _idExternoController = TextEditingController();
  final _unidadeMedidaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _composicaoController = TextEditingController();
  final _cuidadosController = TextEditingController();
  final _ncmController = TextEditingController();
  final _pesoController = TextEditingController();

  bool _salvando = false;
  Referencia? _referencia;
  Categoria? _categoriaSelecionada;
  SubCategoria? _subCategoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _referenciaBloc = sl<ReferenciaBloc>()
      ..add(ReferenciaIniciou(idReferencia: widget.idReferencia));
    _produtosBloc = sl<ProdutosDaReferenciaBloc>()
      ..add(ProdutosDaReferenciaIniciou(referenciaId: widget.idReferencia));
    _precosBloc = sl<PrecosDaReferenciaBloc>()
      ..add(PrecosDaReferenciaIniciou(referenciaId: widget.idReferencia));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _referenciaBloc.close();
    _produtosBloc.close();
    _precosBloc.close();
    _nomeController.dispose();
    _idExternoController.dispose();
    _unidadeMedidaController.dispose();
    _descricaoController.dispose();
    _composicaoController.dispose();
    _cuidadosController.dispose();
    _ncmController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void _aplicarReferencia(Referencia referencia) {
    _referencia = referencia;
    _nomeController.text = referencia.nome;
    _idExternoController.text = referencia.idExterno ?? '';
    _unidadeMedidaController.text = referencia.unidadeMedida ?? '';
    _descricaoController.text = referencia.descricao ?? '';
    _composicaoController.text = referencia.composicao ?? '';
    _cuidadosController.text = referencia.cuidados ?? '';
    _ncmController.text = referencia.ncm ?? '';
    _pesoController.text = referencia.pesoGramas?.toString() ?? '';
    _categoriaSelecionada = referencia.categoria;
    _subCategoriaSelecionada = referencia.subCategoria;
  }

  Future<void> _salvar() async {
    final referenciaAtual = _referencia;
    if (referenciaAtual == null) return;

    final referenciaId = referenciaAtual.id;
    final categoriaId = _categoriaSelecionada?.id ?? referenciaAtual.categoriaId;

    if (referenciaId == null || categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar: referência sem ID ou categoria.'),
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _salvando = true);
    try {
      final atualizada = await sl<AtualizarReferencia>().call(
        id: referenciaId,
        nome: _nomeController.text.trim(),
        categoriaId: categoriaId,
        subCategoriaId: _subCategoriaSelecionada?.id,
        marcaId: referenciaAtual.marcaId,
        idExterno: _sanitizeOptional(_idExternoController.text),
        unidadeMedida: _sanitizeOptional(_unidadeMedidaController.text),
        descricao: _sanitizeOptional(_descricaoController.text),
        composicao: _sanitizeOptional(_composicaoController.text),
        cuidados: _sanitizeOptional(_cuidadosController.text),
        ncm: _sanitizeOptional(_ncmController.text),
        pesoGramas: int.tryParse(_pesoController.text.trim()),
      );

      if (!mounted) return;
      setState(() {
        _aplicarReferencia(atualizada);
        _salvando = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Referência salva.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Falha ao salvar referência.')));
    }
  }

  String? _sanitizeOptional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _editarCategoriaSubCategoria() async {
    final resultado = await CategoriaSubCategoriaSelecaoModal.show(
      context: context,
      categoriaAtualId: _categoriaSelecionada?.id ?? _referencia?.categoriaId,
      subCategoriaAtualId:
          _subCategoriaSelecionada?.id ?? _referencia?.subCategoriaId,
    );
    if (resultado == null) return;

    setState(() {
      _categoriaSelecionada = resultado.categoria;
      _subCategoriaSelecionada = resultado.subCategoria;
      _referencia = _referencia?.copyWith(
        categoriaId: resultado.categoria.id,
        categoria: resultado.categoria,
        subCategoriaId: resultado.subCategoria?.id,
        subCategoria: resultado.subCategoria,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ReferenciaBloc>.value(value: _referenciaBloc),
        BlocProvider<ProdutosDaReferenciaBloc>.value(value: _produtosBloc),
        BlocProvider<PrecosDaReferenciaBloc>.value(value: _precosBloc),
      ],
      child: BlocConsumer<ReferenciaBloc, ReferenciaState>(
        listener: (context, state) {
          if (state is ReferenciaCarregarSucesso) {
            _aplicarReferencia(state.referencia);
          }
        },
        builder: (context, state) {
          final carregando = state is ReferenciaCarregarEmProgresso;
          final falha = state is ReferenciaCarregarFalha;
          final mobile =
              MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

          if (carregando) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (falha) {
            return Scaffold(
              appBar: AppBar(title: const Text('Detalhes da Referência')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Falha ao carregar referência.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _referenciaBloc.add(
                        ReferenciaIniciou(idReferencia: widget.idReferencia),
                      ),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (mobile) return _buildMobile(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalhes da Referência'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_salvando ? 'Salvando...' : 'Salvar'),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 340,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildIdentidade(context),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTabBar(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                ReferenciaProdutosTab(
                                  referenciaId: widget.idReferencia,
                                ),
                                ReferenciaPrecosTab(
                                  referenciaId: widget.idReferencia,
                                ),
                                _buildDetalhesTab(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<ProdutosDaReferenciaBloc, ProdutosDaReferenciaState>(
      builder: (context, produtosState) {
        return BlocBuilder<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
          builder: (context, precosState) {
            return TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text:
                      'Produtos (${produtosState.totalCombinacoesComProduto}/${produtosState.totalCombinacoesDaGrade})',
                ),
                Tab(
                  text:
                      'Tabela de preços (${precosState.totalComPreco}/${precosState.totalTabelas})',
                ),
                const Tab(text: 'Detalhes'),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMobile(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Scaffold(
      appBar: AppBar(
        title: Text(_referencia?.nome ?? '', style: textos.secao.copyWith(fontSize: 22)),
        actions: [
          TextButton(
            onPressed: _salvando ? null : _salvar,
            child: Text(
              _salvando ? 'Salvando...' : 'Salvar',
              style: TextStyle(color: cores.acoAtivo),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ReferenciaResumoMobileCard(
                referencia: _referencia,
                onEditar: () => _tabController.animateTo(2),
              ),
            ),
            const SizedBox(height: 12),
            _buildSegmentedTabsMobile(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ReferenciaProdutosMobileTab(referenciaId: widget.idReferencia),
                    ReferenciaPrecosMobileTab(referenciaId: widget.idReferencia),
                    SingleChildScrollView(child: _buildDetalhesTab(compacto: true)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: () async {
                  final produtosBloc = context.read<ProdutosDaReferenciaBloc>();
                  final state = produtosBloc.state;
                  final criouAlgo = await AdicionarVariacoesPainel.showMobile(
                    context: context,
                    referenciaId: widget.idReferencia,
                    corIdsNaGrade: state.cores.map((c) => c.id).toSet(),
                    tamanhoIdsNaGrade: state.tamanhos.map((t) => t.id).toSet(),
                    estampaIdsNaGrade: state.estampas
                        .where((e) => e.id != null)
                        .map((e) => e.id!)
                        .toSet(),
                    chavesNaGrade: state.mapaProduto.keys.toSet(),
                  );
                  if (criouAlgo == true) {
                    produtosBloc.add(
                      ProdutosDaReferenciaIniciou(referenciaId: widget.idReferencia),
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('ADICIONAR VARIAÇÕES'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSegmentedTabsMobile(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocBuilder<ProdutosDaReferenciaBloc, ProdutosDaReferenciaState>(
      builder: (context, produtosState) {
        return BlocBuilder<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
          builder: (context, precosState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                labelColor: cores.acoEscuro,
                unselectedLabelColor: cores.textoApoio,
                labelStyle: textos.rotulo,
                indicatorColor: cores.aco,
                tabs: [
                  Tab(
                    text:
                        'PRODUTOS (${produtosState.totalCombinacoesComProduto}/${produtosState.totalCombinacoesDaGrade})',
                  ),
                  Tab(
                    text:
                        'PREÇOS (${precosState.totalComPreco}/${precosState.totalTabelas})',
                  ),
                  const Tab(text: 'DETALHES'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIdentidade(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((_referencia?.id ?? widget.idReferencia) > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReferenciaMidiasWidget(
                referenciaId: _referencia?.id ?? widget.idReferencia,
                permiteEditar: true,
              ),
            ),
          const _RotuloCampo('NOME'),
          const SizedBox(height: 4),
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(),
            validator: (value) =>
                (value == null || value.trim().isEmpty)
                ? 'Informe o nome da referência'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildChipCampo(
                  context,
                  rotulo: 'CATEGORIA',
                  valor: _categoriaSelecionada?.nome ?? '-',
                  onTap: _editarCategoriaSubCategoria,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChipCampo(
                  context,
                  rotulo: 'SUBCATEGORIA',
                  valor: _subCategoriaSelecionada?.nome ?? '-',
                  onTap: _editarCategoriaSubCategoria,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ponytail: sem lookup de nome de marca no domínio ainda, mostra
          // só o rótulo/valor fixo "-"; adicionar quando existir cadastro
          // de marca com busca por id.
          _buildChipCampo(context, rotulo: 'MARCA', valor: '-', onTap: null),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _RotuloCampo('NCM'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _ncmController,
                      maxLength: 8,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(counterText: ''),
                      validator: (value) {
                        final texto = value?.trim() ?? '';
                        if (texto.isEmpty) return null;
                        if (texto.length != 8) {
                          return 'NCM deve conter exatamente 8 números.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _RotuloCampo('PESO (G)'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _pesoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: textos.apoio.copyWith(color: cores.textoApoio),
              children: [
                const TextSpan(
                  text: 'Composição, cuidados e ID externo ficam na aba ',
                ),
                TextSpan(
                  text: 'Detalhes',
                  style: TextStyle(color: cores.acoProfundo),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _tabController.animateTo(2),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipCampo(
    BuildContext context, {
    required String rotulo,
    required String valor,
    required VoidCallback? onTap,
  }) {
    final cores = context.sivColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RotuloCampo(rotulo),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cores.superficie,
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              border: Border.all(color: cores.hairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(valor, overflow: TextOverflow.ellipsis),
                ),
                if (onTap != null)
                  Icon(Icons.expand_more, size: 18, color: cores.textoApoio),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetalhesTab({bool compacto = false}) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final linhasDescricao = compacto ? 2 : 4;
    final linhasTextarea = compacto ? 2 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETALHES DA REFERÊNCIA',
          style: textos.secao.copyWith(fontSize: 16, color: cores.acoAtivo),
        ),
        const SizedBox(height: 4),
        Text(
          'Aparecem na etiqueta, no e-commerce e na nota fiscal.',
          style: textos.apoio.copyWith(color: cores.textoApoio),
        ),
        const SizedBox(height: 16),
        const _RotuloCampo('DESCRIÇÃO'),
        const SizedBox(height: 4),
        TextFormField(
          controller: _descricaoController,
          maxLines: linhasDescricao,
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RotuloCampo('COMPOSIÇÃO'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _composicaoController,
                    maxLines: linhasTextarea,
                    decoration: const InputDecoration(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RotuloCampo('CUIDADOS'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _cuidadosController,
                    maxLines: linhasTextarea,
                    decoration: const InputDecoration(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RotuloCampo('ID EXTERNO'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _idExternoController,
                    decoration: const InputDecoration(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RotuloCampo('UNIDADE DE MEDIDA'),
                  const SizedBox(height: 4),
                  _buildUnidadeMedidaDropdown(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnidadeMedidaDropdown() {
    const opcoes = {
      'UN': 'UN — unidade',
      'PC': 'PC — peça',
      'KIT': 'KIT — kit',
      'PAR': 'PAR — par',
    };
    final atual = _unidadeMedidaController.text.trim();
    final itens = {...opcoes.keys, if (atual.isNotEmpty) atual};

    return DropdownButtonFormField<String>(
      initialValue: atual.isEmpty ? null : atual,
      decoration: const InputDecoration(),
      items: itens
          .map(
            (valor) => DropdownMenuItem(
              value: valor,
              child: Text(opcoes[valor] ?? valor),
            ),
          )
          .toList(),
      onChanged: (valor) => setState(() {
        _unidadeMedidaController.text = valor ?? '';
      }),
    );
  }
}

class _RotuloCampo extends StatelessWidget {
  final String texto;

  const _RotuloCampo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: context.sivTextos.rotulo.copyWith(
        color: context.sivColors.textoApoio,
        fontSize: 11,
      ),
    );
  }
}
