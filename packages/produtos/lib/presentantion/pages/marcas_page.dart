import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class MarcasPage extends StatelessWidget {
  final bloc = sl<MarcasBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  MarcasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MarcasBloc>(
      create: (context) => bloc..add(MarcasIniciou()),
      child: Scaffold(
        floatingActionButton: BlocBuilder<MarcasBloc, MarcasState>(
          builder: (context, state) {
            if (state is MarcasCarregarEmProgresso) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await MarcaModal.show(context: context);

                if (result == true) {
                  // ignore: use_build_context_synchronously
                  context.read<MarcasBloc>().add(MarcasIniciou());
                }
              },
            );
          },
        ),
        appBar: AppBar(title: const Text('Marcas')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gerencie suas marcas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      autoFocus: false,
                      hintText: 'Buscar marca por nome',
                      onChanged: (value) {
                        debouncer.run(() {
                          bloc.add(MarcasIniciou(busca: value));
                        });
                      },
                      onSubmitted: (value) {
                        bloc.add(MarcasIniciou(busca: value));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<MarcasBloc, MarcasState>(
                  builder: (context, state) {
                    if (state is MarcasCarregarEmProgresso ||
                        state is MarcasDesativarEmProgresso) {
                      return _buildLoading();
                    }

                    if (state is MarcasCarregarFalha ||
                        state is MarcasDesativarFalha) {
                      return _buildError();
                    }

                    if (state is MarcasCarregarSucesso ||
                        state is MarcasDesativarSucesso) {
                      if (state.marcas.isEmpty) {
                        return _buildEmpty();
                      }

                      return ListView.builder(
                        itemCount: state.marcas.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemBuilder: (context, index) {
                          final marca = state.marcas[index];
                          return _buildMarcaCard(context, marca);
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

  Widget _buildMarcaCard(BuildContext context, Marca marca) {
    final isInativa = marca.inativa;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isInativa
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          child: Text(
            marca.nome.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () async {
          final result = await MarcaModal.show(
            context: context,
            idMarca: marca.id,
          );

          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<MarcasBloc>().add(MarcasIniciou());
          }
        },
        title: Text(
          marca.nome,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isInativa ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          isInativa ? 'Inativa' : 'Ativa',
          style: TextStyle(color: isInativa ? Colors.grey : Colors.green),
        ),
        trailing: !isInativa
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _showDeleteConfirmation(context, marca);
                },
              )
            : null,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Erro ao carregar marcas'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              bloc.add(MarcasIniciou());
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma marca encontrada',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique em + para adicionar uma nova marca',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Marca marca) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar Marca'),
        content: Text('Deseja realmente desativar a marca "${marca.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<MarcasBloc>().add(MarcasDesativar(id: marca.id!));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }
}
