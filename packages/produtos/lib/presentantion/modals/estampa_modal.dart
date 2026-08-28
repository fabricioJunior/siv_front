import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentation.dart';

class EstampaModal extends StatelessWidget {
  final int? idEstampa;

  static Future<bool?> show({
    required BuildContext context,
    int? idEstampa,
  }) async {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EstampaModal(idEstampa: idEstampa);
      },
    );
  }

  const EstampaModal({super.key, this.idEstampa});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();

    return BlocProvider<EstampaBloc>(
      create: (context) =>
          sl<EstampaBloc>()..add(EstampaIniciou(idEstampa: idEstampa)),
      child: BlocListener<EstampaBloc, EstampaState>(
        listener: (context, state) {
          if (state.estampaStep == EstampaStep.criado ||
              state.estampaStep == EstampaStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: BlocBuilder<EstampaBloc, EstampaState>(
                builder: (context, state) {
                  if (state.estampaStep == EstampaStep.carregando) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }

                  if (state.estampaStep == EstampaStep.falha) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Erro ao carregar estampa')),
                    );
                  }

                  // Atualiza o controller quando o estado carrega uma estampa
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
                          idEstampa == null
                              ? 'Nova Estampa'
                              : 'Editar Estampa',
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
                            hintText: 'Ex: Floral, Poá, Listrado',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o nome da estampa';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            context.read<EstampaBloc>().add(
                              EstampaEditou(nome: value),
                            );
                          },
                          onFieldSubmitted: (_) {
                            if (formKey.currentState?.validate() ?? false) {
                              context.read<EstampaBloc>().add(
                                EstampaSalvou(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        if (state.estampaStep == EstampaStep.falha)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Erro ao salvar estampa',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                context.read<EstampaBloc>().add(
                                  EstampaSalvou(),
                                );
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Salvar'),
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
      ),
    );
  }
}
