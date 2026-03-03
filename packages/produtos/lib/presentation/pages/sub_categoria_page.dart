import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class SubCategoriaPage extends StatelessWidget {
  final int categoriaId;
  final int? idSubCategoria;

  const SubCategoriaPage({
    super.key,
    required this.categoriaId,
    this.idSubCategoria,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();

    return BlocProvider<SubCategoriaBloc>(
      create: (context) => sl<SubCategoriaBloc>()
        ..add(
          SubCategoriaIniciou(
            categoriaId: categoriaId,
            idSubCategoria: idSubCategoria,
          ),
        ),
      child: BlocListener<SubCategoriaBloc, SubCategoriaState>(
        listener: (context, state) {
          if (state.subCategoriaStep == SubCategoriaStep.criado ||
              state.subCategoriaStep == SubCategoriaStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
            child: BlocBuilder<SubCategoriaBloc, SubCategoriaState>(
              builder: (context, state) {
                if (state.subCategoriaStep == SubCategoriaStep.carregando) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }

                if (state.nome != null && nomeController.text.isEmpty) {
                  nomeController.text = state.nome!;
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              idSubCategoria == null
                                  ? 'Nova Sub-Categoria'
                                  : 'Editar Sub-Categoria',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Nome da Sub-Categoria',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: nomeController,
                                maxLength: 50,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Ex: Camisetas, Calças, Bonés',
                                  border: OutlineInputBorder(),
                                  counterText: '',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe o nome da sub-categoria';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context.read<SubCategoriaBloc>().add(
                                    SubCategoriaEditou(nome: value),
                                  );
                                },
                                onFieldSubmitted: (_) {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    context.read<SubCategoriaBloc>().add(
                                      SubCategoriaSalvou(),
                                    );
                                  }
                                },
                              ),
                              if (state.subCategoriaStep ==
                                  SubCategoriaStep.falha)
                                const Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    'Erro ao salvar sub-categoria',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed:
                                state.subCategoriaStep ==
                                    SubCategoriaStep.carregando
                                ? null
                                : () {
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      context.read<SubCategoriaBloc>().add(
                                        SubCategoriaSalvou(),
                                      );
                                    }
                                  },
                            icon:
                                state.subCategoriaStep ==
                                    SubCategoriaStep.carregando
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(
                              idSubCategoria == null ? 'Criar' : 'Salvar',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
