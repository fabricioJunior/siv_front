import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class CategoriaModal extends StatelessWidget {
  final int? idCategoria;

  static Future<bool?> show({
    required BuildContext context,
    int? idCategoria,
  }) async {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CategoriaModal(idCategoria: idCategoria);
      },
    );
  }

  const CategoriaModal({super.key, this.idCategoria});

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
          backgroundColor: Colors.transparent,
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
          body: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        idCategoria == null
                            ? 'Nova Categoria'
                            : 'Editar Categoria',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text('Nome'),
                      TextFormField(
                        controller: nomeController,
                        maxLength: 50,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Roupas, Calcados, Acessorios',
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
                      const SizedBox(height: 8),
                      if (state.categoriaStep == CategoriaStep.falha)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Erro ao salvar categoria',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
