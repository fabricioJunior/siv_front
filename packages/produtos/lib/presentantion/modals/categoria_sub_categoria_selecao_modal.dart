import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class CategoriaSubCategoriaSelecaoResultado {
  final Categoria categoria;
  final SubCategoria? subCategoria;

  const CategoriaSubCategoriaSelecaoResultado({
    required this.categoria,
    required this.subCategoria,
  });
}

class CategoriaSubCategoriaSelecaoModal extends StatefulWidget {
  final int? categoriaAtualId;
  final int? subCategoriaAtualId;

  const CategoriaSubCategoriaSelecaoModal({
    super.key,
    this.categoriaAtualId,
    this.subCategoriaAtualId,
  });

  static Future<CategoriaSubCategoriaSelecaoResultado?> show({
    required BuildContext context,
    int? categoriaAtualId,
    int? subCategoriaAtualId,
  }) {
    return showDialog<CategoriaSubCategoriaSelecaoResultado>(
      context: context,
      builder: (_) => CategoriaSubCategoriaSelecaoModal(
        categoriaAtualId: categoriaAtualId,
        subCategoriaAtualId: subCategoriaAtualId,
      ),
    );
  }

  @override
  State<CategoriaSubCategoriaSelecaoModal> createState() =>
      _CategoriaSubCategoriaSelecaoModalState();
}

class _CategoriaSubCategoriaSelecaoModalState
    extends State<CategoriaSubCategoriaSelecaoModal> {
  final _categoriaSearchController = TextEditingController();
  final _subCategoriaSearchController = TextEditingController();

  String _categoriaQuery = '';
  String _subCategoriaQuery = '';

  @override
  void dispose() {
    _categoriaSearchController.dispose();
    _subCategoriaSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriaSubCategoriaSelecaoBloc>(
      create: (_) => sl<CategoriaSubCategoriaSelecaoBloc>()
        ..add(
          CategoriaSubCategoriaSelecaoIniciou(
            categoriaAtualId: widget.categoriaAtualId,
            subCategoriaAtualId: widget.subCategoriaAtualId,
          ),
        ),
      child: BlocBuilder<CategoriaSubCategoriaSelecaoBloc, CategoriaSubCategoriaSelecaoState>(
        builder: (context, state) {
          final carregando =
              state.carregandoCategorias || state.carregandoSubCategorias;
          final deveMostrarEtapaSubCategoria = state.subCategorias.isNotEmpty;

          final categoriasFiltradas = state.categorias
              .where(
                (categoria) => categoria.nome.toLowerCase().contains(
                  _categoriaQuery.toLowerCase().trim(),
                ),
              )
              .toList();

          final subCategoriasFiltradas = state.subCategorias
              .where(
                (subCategoria) => subCategoria.nome.toLowerCase().contains(
                  _subCategoriaQuery.toLowerCase().trim(),
                ),
              )
              .toList();

          return AlertDialog(
            title: Text(
              state.step == CategoriaSubCategoriaSelecaoStep.categoria
                  ? 'Selecionar categoria'
                  : 'Selecionar sub-categoria',
            ),
            content: SizedBox(
              width: 560,
              child: carregando
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.step ==
                            CategoriaSubCategoriaSelecaoStep.categoria)
                          TextField(
                            controller: _categoriaSearchController,
                            decoration: const InputDecoration(
                              labelText: 'Buscar categoria',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _categoriaQuery = value;
                              });
                            },
                          ),
                        if (state.step ==
                            CategoriaSubCategoriaSelecaoStep.categoria)
                          const SizedBox(height: 12),
                        if (state.step ==
                            CategoriaSubCategoriaSelecaoStep.categoria)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: categoriasFiltradas.isEmpty
                                ? Center(
                                    child: Text(
                                      'Nenhuma categoria encontrada',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: categoriasFiltradas.length,
                                    itemBuilder: (context, index) {
                                      final categoria =
                                          categoriasFiltradas[index];

                                      return CheckboxListTile(
                                        value:
                                            state.categoriaSelecionada?.id ==
                                            categoria.id,
                                        title: Text(categoria.nome),
                                        onChanged: (_) {
                                          context
                                              .read<
                                                CategoriaSubCategoriaSelecaoBloc
                                              >()
                                              .add(
                                                CategoriaSubCategoriaCategoriaSelecionada(
                                                  categoria: categoria,
                                                ),
                                              );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        if (state.step ==
                            CategoriaSubCategoriaSelecaoStep.categoria)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              deveMostrarEtapaSubCategoria
                                  ? 'Esta categoria possui sub-categorias. Clique em Próximo para selecionar.'
                                  : 'Esta categoria não possui sub-categorias cadastradas.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        if (state.step ==
                            CategoriaSubCategoriaSelecaoStep.subCategoria)
                          TextField(
                            controller: _subCategoriaSearchController,
                            decoration: const InputDecoration(
                              labelText: 'Buscar sub-categoria',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _subCategoriaQuery = value;
                              });
                            },
                          ),
                        if (state.step ==
                            CategoriaSubCategoriaSelecaoStep.subCategoria)
                          const SizedBox(height: 12),
                        if (state.step ==
                            CategoriaSubCategoriaSelecaoStep.subCategoria)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                CheckboxListTile(
                                  value: state.subCategoriaSelecionada == null,
                                  title: const Text('Sem sub-categoria'),
                                  onChanged: (_) {
                                    context
                                        .read<
                                          CategoriaSubCategoriaSelecaoBloc
                                        >()
                                        .add(
                                          const CategoriaSubCategoriaSubCategoriaSelecionada(
                                            subCategoria: null,
                                          ),
                                        );
                                  },
                                ),
                                if (subCategoriasFiltradas.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Nenhuma sub-categoria encontrada',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ...subCategoriasFiltradas.map(
                                  (subCategoria) => CheckboxListTile(
                                    value:
                                        state.subCategoriaSelecionada?.id ==
                                        subCategoria.id,
                                    title: Text(subCategoria.nome),
                                    onChanged: (_) {
                                      context
                                          .read<
                                            CategoriaSubCategoriaSelecaoBloc
                                          >()
                                          .add(
                                            CategoriaSubCategoriaSubCategoriaSelecionada(
                                              subCategoria: subCategoria,
                                            ),
                                          );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (state.mensagem != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              state.mensagem!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              if (state.step == CategoriaSubCategoriaSelecaoStep.subCategoria)
                TextButton(
                  onPressed: () {
                    context.read<CategoriaSubCategoriaSelecaoBloc>().add(
                      const CategoriaSubCategoriaEtapaVoltou(),
                    );
                  },
                  child: const Text('Voltar'),
                ),
              ElevatedButton(
                onPressed: carregando || state.categoriaSelecionada == null
                    ? null
                    : () {
                        if (state.step ==
                                CategoriaSubCategoriaSelecaoStep.categoria &&
                            deveMostrarEtapaSubCategoria) {
                          context.read<CategoriaSubCategoriaSelecaoBloc>().add(
                            const CategoriaSubCategoriaEtapaAvancou(),
                          );
                          return;
                        }

                        Navigator.of(context).pop(
                          CategoriaSubCategoriaSelecaoResultado(
                            categoria: state.categoriaSelecionada!,
                            subCategoria:
                                state.step ==
                                    CategoriaSubCategoriaSelecaoStep
                                        .subCategoria
                                ? state.subCategoriaSelecionada
                                : null,
                          ),
                        );
                      },
                child: Text(
                  state.step == CategoriaSubCategoriaSelecaoStep.categoria &&
                          deveMostrarEtapaSubCategoria
                      ? 'Próximo'
                      : 'Salvar',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
