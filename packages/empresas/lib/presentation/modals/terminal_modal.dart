import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:empresas/presentation.dart';
import 'package:flutter/material.dart';

class TerminalModal extends StatelessWidget {
  final int empresaId;
  final int? idTerminal;

  const TerminalModal({super.key, required this.empresaId, this.idTerminal});

  static Future<bool?> show({
    required BuildContext context,
    required int empresaId,
    int? idTerminal,
  }) async {
    return showModalBottomSheet<bool>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TerminalModal(empresaId: empresaId, idTerminal: idTerminal);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();

    return BlocProvider<TerminalBloc>(
      create: (context) => sl<TerminalBloc>()
        ..add(TerminalIniciou(empresaId: empresaId, idTerminal: idTerminal)),
      child: BlocListener<TerminalBloc, TerminalState>(
        listener: (context, state) {
          if (state.terminalStep == TerminalStep.criado ||
              state.terminalStep == TerminalStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: BlocBuilder<TerminalBloc, TerminalState>(
            builder: (context, state) {
              if (state.terminalStep == TerminalStep.carregando) {
                return const FloatingActionButton(
                  onPressed: null,
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              return FloatingActionButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<TerminalBloc>().add(const TerminalSalvou());
                  }
                },
              );
            },
          ),
          body: Padding(
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
              child: BlocBuilder<TerminalBloc, TerminalState>(
                builder: (context, state) {
                  if (state.terminalStep == TerminalStep.carregando) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (state.terminalStep == TerminalStep.falha &&
                      idTerminal != null &&
                      state.nome == null) {
                    return const Center(
                      child: Text('Erro ao carregar terminal'),
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
                          idTerminal == null
                              ? 'Novo Terminal'
                              : 'Editar Terminal',
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
                            const SizedBox(width: 16),
                            Text(
                              'Empresa',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (state.empresaId ?? empresaId).toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Nome'),
                        TextFormField(
                          controller: nomeController,
                          maxLength: 60,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Ex: Caixa 01, PDV 02',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o nome do terminal';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            context.read<TerminalBloc>().add(
                              TerminalEditou(nome: value),
                            );
                          },
                          onFieldSubmitted: (_) {
                            if (formKey.currentState?.validate() ?? false) {
                              context.read<TerminalBloc>().add(
                                const TerminalSalvou(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        if (state.terminalStep == TerminalStep.falha)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Erro ao salvar terminal',
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
      ),
    );
  }
}
