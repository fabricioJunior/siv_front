import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

class ReferenciaPage extends StatefulWidget {
  final Referencia referencia;

  const ReferenciaPage({super.key, required this.referencia});

  @override
  State<ReferenciaPage> createState() => _ReferenciaPageState();
}

class _ReferenciaPageState extends State<ReferenciaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idController;
  late final TextEditingController _nomeController;
  late final TextEditingController _idExternoController;
  late final TextEditingController _unidadeMedidaController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _composicaoController;
  late final TextEditingController _cuidadosController;

  bool _salvando = false;
  late Referencia _referencia;
  Categoria? _categoriaSelecionada;
  SubCategoria? _subCategoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _referencia = widget.referencia;
    _idController = TextEditingController(
      text: _referencia.id?.toString() ?? '',
    );
    _nomeController = TextEditingController(text: _referencia.nome);
    _idExternoController = TextEditingController(
      text: _referencia.idExterno ?? '',
    );
    _unidadeMedidaController = TextEditingController(
      text: _referencia.unidadeMedida ?? '',
    );
    _descricaoController = TextEditingController(
      text: _referencia.descricao ?? '',
    );
    _composicaoController = TextEditingController(
      text: _referencia.composicao ?? '',
    );
    _cuidadosController = TextEditingController(
      text: _referencia.cuidados ?? '',
    );
    _categoriaSelecionada = _referencia.categoria;
    _subCategoriaSelecionada = _referencia.subCategoria;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _idExternoController.dispose();
    _unidadeMedidaController.dispose();
    _descricaoController.dispose();
    _composicaoController.dispose();
    _cuidadosController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final referenciaId = _referencia.id;
    final categoriaId = _categoriaSelecionada?.id ?? _referencia.categoriaId;

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
        marcaId: _referencia.marcaId,
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
      categoriaAtualId: _categoriaSelecionada?.id ?? _referencia.categoriaId,
      subCategoriaAtualId:
          _subCategoriaSelecionada?.id ?? _referencia.subCategoriaId,
    );

    if (resultado == null) return;

    setState(() {
      _categoriaSelecionada = resultado.categoria;
      _subCategoriaSelecionada = resultado.subCategoria;
      _referencia = _referencia.copyWith(
        categoriaId: resultado.categoria.id,
        categoria: resultado.categoria,
        subCategoriaId: resultado.subCategoria?.id,
        subCategoria: resultado.subCategoria,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Referência')),
      floatingActionButton: FloatingActionButton.extended(
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
      body: SafeArea(
        child: SingleChildScrollView(
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
                  child: Text(_subCategoriaSelecionada?.nome ?? '-'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _editarCategoriaSubCategoria,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Alterar categoria/sub-categoria'),
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
                          icon: const Icon(Icons.edit_note_outlined),
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
                          icon: const Icon(Icons.edit_note_outlined),
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
                          icon: const Icon(Icons.edit_note_outlined),
                          label: const Text('Editar cuidados'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
