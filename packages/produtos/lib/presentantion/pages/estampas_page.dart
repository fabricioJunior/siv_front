import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class EstampasPage extends StatelessWidget {
  final bloc = sl<EstampasBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  EstampasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EstampasBloc>(
      create: (context) => bloc..add(EstampasIniciou()),
      child: Scaffold(
        floatingActionButton: BlocBuilder<EstampasBloc, EstampasState>(
          builder: (context, state) {
            if (state is EstampasCarregarEmProgresso) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await EstampaModal.show(context: context);

                if (result == true) {
                  // ignore: use_build_context_synchronously
                  context.read<EstampasBloc>().add(EstampasIniciou());
                }
              },
            );
          },
        ),
        appBar: AppBar(title: const Text('Estampas')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gerencie suas estampas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      autoFocus: false,
                      hintText: 'Buscar estampa por nome',
                      onChanged: (value) {
                        debouncer.run(() {
                          bloc.add(EstampasIniciou(busca: value));
                        });
                      },
                      onSubmitted: (value) {
                        bloc.add(EstampasIniciou(busca: value));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<EstampasBloc, EstampasState>(
                  builder: (context, state) {
                    if (state is EstampasCarregarEmProgresso ||
                        state is EstampasDesativarEmProgresso) {
                      return _buildLoading();
                    }

                    if (state is EstampasCarregarFalha ||
                        state is EstampasDesativarFalha) {
                      return _buildError();
                    }

                    if (state is EstampasCarregarSucesso ||
                        state is EstampasDesativarSucesso) {
                      if (state.estampas.isEmpty) {
                        return _buildEmpty();
                      }

                      return ListView.builder(
                        itemCount: state.estampas.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemBuilder: (context, index) {
                          final estampa = state.estampas[index];
                          return _buildEstampaCard(context, estampa);
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstampaCard(BuildContext context, Estampa estampa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: estampa.inativo
              ? Colors.grey.shade300
              : Colors.blue.shade100,
          child: Text(
            estampa.id?.toString() ??
                (estampa.nome.isNotEmpty
                    ? estampa.nome.substring(0, 1).toUpperCase()
                    : '-'),
            style: TextStyle(
              color: estampa.inativo ? Colors.grey.shade700 : Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () async {
          final result = await EstampaModal.show(
            context: context,
            idEstampa: estampa.id,
          );

          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<EstampasBloc>().add(EstampasIniciou());
          }
        },
        title: Text(
          estampa.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              estampa.inativo ? 'Inativo' : 'Ativo',
              style: TextStyle(
                color: estampa.inativo ? Colors.grey : Colors.blue,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _showDeleteConfirmation(context, estampa);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Estampa estampa) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar Estampa'),
        content: Text('Deseja desativar a estampa "${estampa.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<EstampasBloc>().add(
                EstampasDesativar(id: estampa.id!),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 12),
            Text(
              'Falha ao carregar estampas',
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
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.texture_outlined, size: 44, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Nenhuma estampa cadastrada.\nToque no botao + para criar uma nova estampa.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
