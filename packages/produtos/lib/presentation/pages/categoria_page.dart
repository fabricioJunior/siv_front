import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class CategoriaPage extends StatelessWidget {
  final int? idCategoria;

  const CategoriaPage({super.key, this.idCategoria});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();

    return BlocProvider<CategoriaBloc>(
      create: (context) =>
          sl<CategoriaBloc>()..add(CategoriaIniciou(idCategoria: idCategoria)),
      child: BlocListener<CategoriaBloc, CategoriaState>(
        listener: (context, state) {
          if (state.categoriaStep == CategoriaStep.criado ||
              state.categoriaStep == CategoriaStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              idCategoria == null ? 'Nova Categoria' : 'Editar Categoria',
            ),
          ),
          floatingActionButton: BlocBuilder<CategoriaBloc, CategoriaState>(
            builder: (context, state) {
              if (state.categoriaStep == CategoriaStep.carregando) {
                return const FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              return FloatingActionButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<CategoriaBloc>().add(CategoriaSalvou());
                  }
                },
              );
            },
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<CategoriaBloc, CategoriaState>(
                builder: (context, state) {
                  if (state.categoriaStep == CategoriaStep.carregando) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (state.categoriaStep == CategoriaStep.falha) {
                    return const Center(
                      child: Text('Erro ao carregar categoria'),
                    );
                  }

                  if (state.nome != null && nomeController.text.isEmpty) {
                    nomeController.text = state.nome!;
                  }

                  return Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações da Categoria',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        const Text('Nome'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nomeController,
                          maxLength: 50,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Ex: Roupas, Calcados, Acessorios',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o nome da categoria';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            context.read<CategoriaBloc>().add(
                              CategoriaEditou(nome: value),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (state.categoriaStep == CategoriaStep.falha)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Erro ao salvar categoria',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        if (state.id != null) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sub-Categorias',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) =>
                                        SubCategoriaPage(
                                          categoriaId: state.id!,
                                        ),
                                  ).then((_) {
                                    // Recarrega as sub-categorias após fechar o modal
                                    context.read<CategoriaBloc>().add(
                                      CategoriaIniciou(idCategoria: state.id),
                                    );
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Adicionar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _SubCategoriasSection(
                              categoriaId: state.id!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubCategoriasSection extends StatelessWidget {
  final int categoriaId;

  const _SubCategoriasSection({required this.categoriaId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<SubCategoriasBloc>()
            ..add(SubCategoriasIniciou(categoriaId: categoriaId)),
      child: BlocBuilder<SubCategoriasBloc, SubCategoriasState>(
        builder: (context, state) {
          if (state is SubCategoriasCarregarEmProgresso) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is SubCategoriasCarregarFalha) {
            return const Center(child: Text('Erro ao carregar sub-categorias'));
          }

          if (state.subCategorias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma sub-categoria cadastrada',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clique em "Adicionar" para criar uma nova sub-categoria',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.subCategorias.length,
            itemBuilder: (context, index) {
              final subCategoria = state.subCategorias[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: subCategoria.inativa
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    child: Text(
                      subCategoria.nome.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    subCategoria.nome,
                    style: TextStyle(
                      decoration: subCategoria.inativa
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: subCategoria.inativa ? const Text('Inativa') : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => SubCategoriaPage(
                              categoriaId: categoriaId,
                              idSubCategoria: subCategoria.id,
                            ),
                          ).then((_) {
                            // ignore: use_build_context_synchronously
                            context.read<SubCategoriasBloc>().add(
                              SubCategoriasIniciou(categoriaId: categoriaId),
                            );
                          });
                        },
                      ),
                      if (!subCategoria.inativa)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Desativar Sub-Categoria'),
                                content: Text(
                                  'Deseja realmente desativar a sub-categoria "${subCategoria.nome}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<SubCategoriasBloc>().add(
                                        SubCategoriasDesativar(
                                          categoriaId: categoriaId,
                                          id: subCategoria.id!,
                                        ),
                                      );
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text('Desativar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
