import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';
import 'package:produtos/presentantion/widgets/referencia_midias_widget.dart';
import 'package:produtos/presentantion/bloc/referencia_midias_bloc/referencia_midias_bloc.dart';

class ReferenciaPage extends StatefulWidget {
  final int idReferencia;

  const ReferenciaPage({super.key, required this.idReferencia});

  @override
  State<ReferenciaPage> createState() => _ReferenciaPageState();
}

class _ReferenciaPageState extends State<ReferenciaPage> {
  late final ReferenciaBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idController;
  late final TextEditingController _nomeController;
  late final TextEditingController _idExternoController;
  late final TextEditingController _unidadeMedidaController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _composicaoController;
  late final TextEditingController _cuidadosController;

  bool _salvando = false;
  Referencia? _referencia;
  Categoria? _categoriaSelecionada;
  SubCategoria? _subCategoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ReferenciaBloc>()
      ..add(ReferenciaIniciou(idReferencia: widget.idReferencia));
    _idController = TextEditingController();
    _nomeController = TextEditingController();
    _idExternoController = TextEditingController();
    _unidadeMedidaController = TextEditingController();
    _descricaoController = TextEditingController();
    _composicaoController = TextEditingController();
    _cuidadosController = TextEditingController();
  }

  @override
  void dispose() {
    _bloc.close();
    _idController.dispose();
    _nomeController.dispose();
    _idExternoController.dispose();
    _unidadeMedidaController.dispose();
    _descricaoController.dispose();
    _composicaoController.dispose();
    _cuidadosController.dispose();
    super.dispose();
  }

  void _aplicarReferencia(Referencia referencia) {
    _referencia = referencia;
    _idController.text = referencia.id?.toString() ?? '';
    _nomeController.text = referencia.nome;
    _idExternoController.text = referencia.idExterno ?? '';
    _unidadeMedidaController.text = referencia.unidadeMedida ?? '';
    _descricaoController.text = referencia.descricao ?? '';
    _composicaoController.text = referencia.composicao ?? '';
    _cuidadosController.text = referencia.cuidados ?? '';
    _categoriaSelecionada = referencia.categoria;
    _subCategoriaSelecionada = referencia.subCategoria;
  }

  Future<void> _salvar() async {
    final referenciaAtual = _referencia;
    if (referenciaAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carregando referência. Tente novamente.'),
        ),
      );
      return;
    }

    final referenciaId = referenciaAtual.id;
    final categoriaId =
        _categoriaSelecionada?.id ?? referenciaAtual.categoriaId;

    if (referenciaId == null || categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar: referência sem ID ou categoria.',
          ),
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final atualizarReferencia = sl<AtualizarReferencia>();
      final referenciaAtualizada = await atualizarReferencia.call(
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
      );

      if (!mounted) return;
      Navigator.of(context).pop(referenciaAtualizada);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao salvar referência.')),
      );
      setState(() {
        _salvando = false;
      });
    }
  }

  String? _sanitizeOptional(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<void> _editarCampoLongo({
    required TextEditingController controller,
    required String titulo,
    required String hintText,
  }) async {
    final textoAtualizado = await TextoLongoEdicaoModal.show(
      context: context,
      titulo: titulo,
      hintText: hintText,
      textoInicial: controller.text,
    );

    if (textoAtualizado == null) return;

    setState(() {
      controller.text = textoAtualizado;
    });
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
        BlocProvider<ReferenciaBloc>.value(value: _bloc),
        BlocProvider(create: (context) => sl<ReferenciaMidiasBloc>()),
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
            appBar: AppBar(title: const Text('Detalhes da Referência')),
            floatingActionButton: FloatingActionButton.extended(
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
            body: SafeArea(
              child: carregando
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : falha
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Falha ao carregar referência.'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                _bloc.add(
                                  ReferenciaIniciou(
                                    idReferencia: widget.idReferencia,
                                  ),
                                );
                              },
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações da Referência',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            // Widget de mídias da referência
                            if ((_referencia?.id ?? widget.idReferencia) > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ReferenciaMidiasWidget(
                                  referenciaId:
                                      _referencia?.id ?? widget.idReferencia,
                                ),
                              ),
                            TextFormField(
                              controller: _idController,
                              readOnly: true,
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'ID',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                labelText: 'Nome',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o nome da referência';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _idExternoController,
                              decoration: const InputDecoration(
                                labelText: 'ID Externo',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _unidadeMedidaController,
                              decoration: const InputDecoration(
                                labelText: 'Unidade de Medida',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(_categoriaSelecionada?.nome ?? '-'),
                            ),
                            const SizedBox(height: 12),
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Sub-Categoria',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _subCategoriaSelecionada?.nome ?? '-',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _editarCategoriaSubCategoria,
                                icon: const Icon(Icons.swap_horiz),
                                label: const Text(
                                  'Alterar categoria/sub-categoria',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Descrição',
                                border: OutlineInputBorder(),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _descricaoController.text.trim().isEmpty
                                        ? 'Sem descrição cadastrada'
                                        : _descricaoController.text,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        _editarCampoLongo(
                                          controller: _descricaoController,
                                          titulo: 'Editar descrição',
                                          hintText:
                                              'Informe a descrição completa da referência',
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit_note_outlined,
                                      ),
                                      label: const Text('Editar descrição'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Composição',
                                border: OutlineInputBorder(),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _composicaoController.text.trim().isEmpty
                                        ? 'Sem composição cadastrada'
                                        : _composicaoController.text,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        _editarCampoLongo(
                                          controller: _composicaoController,
                                          titulo: 'Editar composição',
                                          hintText:
                                              'Informe a composição completa da referência',
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit_note_outlined,
                                      ),
                                      label: const Text('Editar composição'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Cuidados',
                                border: OutlineInputBorder(),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _cuidadosController.text.trim().isEmpty
                                        ? 'Sem cuidados cadastrados'
                                        : _cuidadosController.text,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        _editarCampoLongo(
                                          controller: _cuidadosController,
                                          titulo: 'Editar cuidados',
                                          hintText:
                                              'Informe os cuidados completos da referência',
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit_note_outlined,
                                      ),
                                      label: const Text('Editar cuidados'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Produtos da referência',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed(
                                          '/produto',
                                          arguments: {
                                            'referenciaId':
                                                state.referencia?.id,
                                          },
                                        )
                                        .then((_) {
                                          // ignore: use_build_context_synchronously
                                          context.read<ReferenciaBloc>().add(
                                            ReferenciaIniciou(
                                              idReferencia: widget.idReferencia,
                                            ),
                                          );
                                        });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.add),
                                      const SizedBox(width: 4),
                                      Text('Cadastrar novo produto'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  (_referencia?.id ?? widget.idReferencia) > 0
                                  ? ProdutosDaReferenciaTabelaidget(
                                      permitirCriacaoDeNovoProduto: true,
                                      referenciaId:
                                          _referencia?.id ??
                                          widget.idReferencia,
                                    )
                                  : const Text(
                                      'ID da referência indisponível para carregar produtos.',
                                    ),
                            ),
                            const SizedBox(height: 96),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
