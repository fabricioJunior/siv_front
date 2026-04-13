import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:empresas/domain/entities/terminal.dart';
import 'package:empresas/presentation.dart';
import 'package:flutter/material.dart';

class TerminaisPage extends StatelessWidget {
  final int empresaId;
  final bloc = sl<TerminaisBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  TerminaisPage({super.key, required this.empresaId});

  @override
  Widget build(BuildContext context) {
    if (empresaId <= 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Terminais')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Selecione uma empresa válida para gerenciar os terminais.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return BlocProvider<TerminaisBloc>(
      create: (context) => bloc..add(TerminaisIniciou(empresaId: empresaId)),
      child: Scaffold(
        floatingActionButton: BlocBuilder<TerminaisBloc, TerminaisState>(
          builder: (context, state) {
            if (state is TerminaisCarregarEmProgresso) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await TerminalModal.show(
                  context: context,
                  empresaId: empresaId,
                );

                if (result == true) {
                  // ignore: use_build_context_synchronously
                  context.read<TerminaisBloc>().add(
                    TerminaisIniciou(empresaId: empresaId),
                  );
                }
              },
            );
          },
        ),
        appBar: AppBar(title: const Text('Terminais')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gerencie os terminais da empresa $empresaId',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      autoFocus: false,
                      hintText: 'Buscar terminal por nome',
                      onChanged: (value) {
                        debouncer.run(() {
                          bloc.add(
                            TerminaisIniciou(
                              empresaId: empresaId,
                              busca: value,
                            ),
                          );
                        });
                      },
                      onSubmitted: (value) {
                        bloc.add(
                          TerminaisIniciou(empresaId: empresaId, busca: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<TerminaisBloc, TerminaisState>(
                  builder: (context, state) {
                    if (state is TerminaisCarregarEmProgresso ||
                        state is TerminaisDesativarEmProgresso) {
                      return _buildLoading();
                    }

                    if (state is TerminaisCarregarFalha ||
                        state is TerminaisDesativarFalha) {
                      return _buildError();
                    }

                    if (state is TerminaisCarregarSucesso ||
                        state is TerminaisDesativarSucesso) {
                      if (state.terminais.isEmpty) {
                        return _buildEmpty();
                      }

                      return ListView.builder(
                        itemCount: state.terminais.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemBuilder: (context, index) {
                          final terminal = state.terminais[index];
                          return _buildTerminalCard(context, terminal);
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalCard(BuildContext context, Terminal terminal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: terminal.inativo == true
              ? Colors.grey.shade300
              : Colors.deepPurple.shade100,
          child: Icon(
            Icons.point_of_sale,
            color: terminal.inativo == true
                ? Colors.grey.shade700
                : Colors.deepPurple,
          ),
        ),
        onTap: () async {
          final result = await TerminalModal.show(
            context: context,
            empresaId: empresaId,
            idTerminal: terminal.id,
          );

          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<TerminaisBloc>().add(
              TerminaisIniciou(empresaId: empresaId),
            );
          }
        },
        title: Text(
          terminal.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${terminal.id ?? '-'}'),
            Text(
              terminal.inativo == true ? 'Inativo' : 'Ativo',
              style: TextStyle(
                color: terminal.inativo == true
                    ? Colors.grey
                    : Colors.deepPurple,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: terminal.id == null
              ? null
              : () {
                  _showDeleteConfirmation(context, terminal);
                },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Terminal terminal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar terminal'),
        content: Text('Deseja desativar o terminal "${terminal.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TerminaisBloc>().add(
                TerminaisDesativar(empresaId: empresaId, id: terminal.id!),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  Widget _buildError() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 12),
            Text(
              'Falha ao carregar terminais',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.point_of_sale_outlined, size: 44, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Nenhum terminal cadastrado.\nToque no botão + para criar um novo terminal.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
