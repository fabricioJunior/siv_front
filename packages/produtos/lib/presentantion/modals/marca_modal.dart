import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class MarcaModal extends StatelessWidget {
  final int? idMarca;

  static Future<bool?> show({
    required BuildContext context,
    int? idMarca,
  }) async {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return MarcaModal(idMarca: idMarca);
      },
    );
  }

  const MarcaModal({super.key, this.idMarca});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();

    return BlocProvider<MarcaBloc>(
      create: (context) => sl<MarcaBloc>()..add(MarcaIniciou(idMarca: idMarca)),
      child: BlocListener<MarcaBloc, MarcaState>(
        listener: (context, state) {
          if (state.marcaStep == MarcaStep.criado ||
              state.marcaStep == MarcaStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: BlocBuilder<MarcaBloc, MarcaState>(
            builder: (context, state) {
              if (state.marcaStep == MarcaStep.carregando) {
                return const FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              return FloatingActionButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<MarcaBloc>().add(MarcaSalvou());
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
            child: BlocBuilder<MarcaBloc, MarcaState>(
              builder: (context, state) {
                if (state.marcaStep == MarcaStep.carregando) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (state.marcaStep == MarcaStep.falha) {
                  return const Center(child: Text('Erro ao carregar marca'));
                }

                // Atualiza o controller quando o estado carrega uma marca
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
                        idMarca == null ? 'Nova Marca' : 'Editar Marca',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'ID',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.id?.toString() ?? 'Novo',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Nome'),
                      TextFormField(
                        controller: nomeController,
                        maxLength: 50,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Nike, Adidas, Puma',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o nome da marca';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<MarcaBloc>().add(
                            MarcaEditou(nome: value),
                          );
                        },
                        onFieldSubmitted: (_) {
                          if (formKey.currentState?.validate() ?? false) {
                            context.read<MarcaBloc>().add(MarcaSalvou());
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      if (state.marcaStep == MarcaStep.falha)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Erro ao salvar marca',
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
