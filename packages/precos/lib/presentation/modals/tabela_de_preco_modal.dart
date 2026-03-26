import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:precos/presentation.dart';

class TabelaDePrecoModal extends StatelessWidget {
  final int? idTabelaDePreco;

  static Future<bool?> show({
    required BuildContext context,
    int? idTabelaDePreco,
  }) async {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TabelaDePrecoModal(idTabelaDePreco: idTabelaDePreco);
      },
    );
  }

  const TabelaDePrecoModal({super.key, this.idTabelaDePreco});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();
    final terminadorController = TextEditingController();

    return BlocProvider<TabelaDePrecoBloc>(
      create: (context) =>
          sl<TabelaDePrecoBloc>()
            ..add(TabelaDePrecoIniciou(idTabelaDePreco: idTabelaDePreco)),
      child: BlocListener<TabelaDePrecoBloc, TabelaDePrecoState>(
        listener: (context, state) {
          if (state.tabelaDePrecoStep == TabelaDePrecoStep.criado ||
              state.tabelaDePrecoStep == TabelaDePrecoStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: BlocBuilder<TabelaDePrecoBloc, TabelaDePrecoState>(
            builder: (context, state) {
              if (state.tabelaDePrecoStep == TabelaDePrecoStep.carregando) {
                return const FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              return FloatingActionButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<TabelaDePrecoBloc>().add(TabelaDePreceSalvou());
                  }
                },
              );
            },
          ),
          body: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: BlocBuilder<TabelaDePrecoBloc, TabelaDePrecoState>(
              builder: (context, state) {
                if (state.tabelaDePrecoStep == TabelaDePrecoStep.carregando) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                if (state.tabelaDePrecoStep == TabelaDePrecoStep.falha) {
                  return const Center(
                    child: Text('Erro ao carregar tabela de preço'),
                  );
                }

                if (state.nome != null && nomeController.text.isEmpty) {
                  nomeController.text = state.nome!;
                }
                if (state.terminador != null &&
                    terminadorController.text.isEmpty) {
                  terminadorController.text = state.terminador.toString();
                }

                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        idTabelaDePreco == null
                            ? 'Nova Tabela de Preço'
                            : 'Editar Tabela de Preço',
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
                        maxLength: 100,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Tabela Varejo, Atacado',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o nome da tabela de preço';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<TabelaDePrecoBloc>().add(
                            TabelaDePrecoEditou(
                              nome: value,
                              terminador: double.tryParse(
                                terminadorController.text,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text('Terminador (opcional)'),
                      TextFormField(
                        controller: terminadorController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'Ex: 0.9, 0.99',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Informe um valor numérico válido';
                            }
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<TabelaDePrecoBloc>().add(
                            TabelaDePrecoEditou(
                              nome: nomeController.text,
                              terminador: double.tryParse(value),
                            ),
                          );
                        },
                        onFieldSubmitted: (_) {
                          if (formKey.currentState?.validate() ?? false) {
                            context
                                .read<TabelaDePrecoBloc>()
                                .add(TabelaDePreceSalvou());
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      if (state.tabelaDePrecoStep == TabelaDePrecoStep.falha)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Erro ao salvar tabela de preço',
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
