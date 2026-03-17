import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class CorModal extends StatelessWidget {
  final int? idCor;

  static Future<bool?> show({required BuildContext context, int? idCor}) async {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CorModal(idCor: idCor);
      },
    );
  }

  const CorModal({super.key, this.idCor});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();

    return BlocProvider<CorBloc>(
      create: (context) => sl<CorBloc>()..add(CorIniciou(idCor: idCor)),
      child: BlocListener<CorBloc, CorState>(
        listener: (context, state) {
          if (state.corStep == CorStep.criado ||
              state.corStep == CorStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: BlocBuilder<CorBloc, CorState>(
            builder: (context, state) {
              if (state.corStep == CorStep.carregando) {
                return const FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              return FloatingActionButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<CorBloc>().add(CorSalvou());
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
            child: BlocBuilder<CorBloc, CorState>(
              builder: (context, state) {
                if (state.corStep == CorStep.carregando) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (state.corStep == CorStep.falha) {
                  return const Center(child: Text('Erro ao carregar cor'));
                }

                // Atualiza o controller quando o estado carrega uma cor
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
                        idCor == null ? 'Nova Cor' : 'Editar Cor',
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
                          hintText: 'Ex: Vermelho, Azul, Verde',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o nome da cor';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<CorBloc>().add(CorEditou(nome: value));
                        },
                        onFieldSubmitted: (_) {
                          if (formKey.currentState?.validate() ?? false) {
                            context.read<CorBloc>().add(CorSalvou());
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      if (state.corStep == CorStep.falha)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Erro ao salvar cor',
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
