import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';
import 'package:produtos/presentantion/widgets/referencia_produtos_tab.dart';
import 'package:produtos/presentantion/widgets/referencia_precos_tab.dart';

/// Tela de detalhe da Referência -- Parte 1 (desktop, largura >= 1024).
/// A Parte 2 (mobile) reaproveita os mesmos blocs (`ReferenciaBloc`,
/// `ProdutosDaReferenciaBloc`, `AdicionarVariacoesBloc`,
/// `PrecosDaReferenciaBloc`), só muda a apresentação.
class ReferenciaPage extends StatefulWidget {
  final int idReferencia;

  const ReferenciaPage({super.key, required this.idReferencia});

  @override
  State<ReferenciaPage> createState() => _ReferenciaPageState();
}

class _ReferenciaPageState extends State<ReferenciaPage> {
  late final ReferenciaBloc _referenciaBloc;
  late final ProdutosDaReferenciaBloc _produtosBloc;
  late final PrecosDaReferenciaBloc _precosBloc;

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

          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalhes da Referência'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FilledButton.icon(
                    onPressed: _salvando || carregando || falha || _referencia == null
                        ? null
                        : _salvar,
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
              child: carregando
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : falha
                  ? Center(
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
                    )
                  : Row(
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
                          child: DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                _buildTabBar(),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: TabBarView(
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

  Widget _buildIdentidade(BuildContext context) {
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
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty)
                ? 'Informe o nome da referência'
                : null,
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Categoria › Sub-categoria',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: _editarCategoriaSubCategoria,
              ),
            ),
            child: Text(
              _subCategoriaSelecionada != null
                  ? '${_categoriaSelecionada?.nome ?? '-'} › ${_subCategoriaSelecionada!.nome}'
                  : (_categoriaSelecionada?.nome ?? '-'),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ncmController,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'NCM',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) {
              final texto = value?.trim() ?? '';
              if (texto.isEmpty) return null;
              if (texto.length != 8) return 'NCM deve conter exatamente 8 números.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pesoController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Peso (gramas)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalhesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _idExternoController,
                  decoration: const InputDecoration(
                    labelText: 'ID Externo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _unidadeMedidaController,
                  decoration: const InputDecoration(
                    labelText: 'Unidade de medida (UN, PC, KIT, PAR)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descricaoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _composicaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Composição',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cuidadosController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Cuidados',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
