import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class TamanhoModal extends StatelessWidget {
  final int? idTamanho;

  static Future<bool?> show({
    required BuildContext context,
    int? idTamanho,
  }) async {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TamanhoModal(idTamanho: idTamanho);
      },
    );
  }

  const TamanhoModal({super.key, this.idTamanho});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();

    return BlocProvider<TamanhoBloc>(
      create: (context) =>
          sl<TamanhoBloc>()..add(TamanhoIniciou(idTamanho: idTamanho)),
      child: BlocListener<TamanhoBloc, TamanhoState>(
        listener: (context, state) {
          if (state.tamanhoStep == TamanhoStep.criado ||
              state.tamanhoStep == TamanhoStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: BlocBuilder<TamanhoBloc, TamanhoState>(
            builder: (context, state) {
              if (state.tamanhoStep == TamanhoStep.carregando) {
                return const FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              return FloatingActionButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<TamanhoBloc>().add(TamanhoSalvou());
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
            child: BlocBuilder<TamanhoBloc, TamanhoState>(
              builder: (context, state) {
                if (state.tamanhoStep == TamanhoStep.carregando) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (state.tamanhoStep == TamanhoStep.falha) {
                  return const Center(child: Text('Erro ao carregar tamanho'));
                }

                // Atualiza o controller quando o estado carrega um tamanho
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
                        idTamanho == null ? 'Novo Tamanho' : 'Editar Tamanho',
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
                        decoration: const InputDecoration(
                          hintText: 'Ex: P, M, G, XG',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o nome do tamanho';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<TamanhoBloc>().add(
                            TamanhoEditou(nome: value),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      if (state.tamanhoStep == TamanhoStep.falha)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Erro ao salvar tamanho',
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
