import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class TamanhosPage extends StatelessWidget {
  final bloc = sl<TamanhosBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  TamanhosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TamanhosBloc>(
      create: (context) => bloc..add(TamanhosIniciou()),
      child: Scaffold(
        floatingActionButton: BlocBuilder<TamanhosBloc, TamanhosState>(
          builder: (context, state) {
            if (state is TamanhosCarregarEmProgresso) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await TamanhoModal.show(context: context);

                if (result == true) {
                  // ignore: use_build_context_synchronously
                  context.read<TamanhosBloc>().add(TamanhosIniciou());
                }
              },
            );
          },
        ),
        appBar: AppBar(title: const Text('Tamanhos')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gerencie seus tamanhos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      autoFocus: false,
                      hintText: 'Buscar tamanho por nome',
                      onChanged: (value) {
                        debouncer.run(() {
                          bloc.add(TamanhosIniciou(busca: value));
                        });
                      },
                      onSubmitted: (value) {
                        bloc.add(TamanhosIniciou(busca: value));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<TamanhosBloc, TamanhosState>(
                  builder: (context, state) {
                    if (state is TamanhosCarregarEmProgresso ||
                        state is TamanhosDesativarEmProgresso) {
                      return _buildLoading();
                    }

                    if (state is TamanhosCarregarFalha ||
                        state is TamanhosDesativarFalha) {
                      return _buildError();
                    }

                    if (state is TamanhosCarregarSucesso ||
                        state is TamanhosDesativarSucesso) {
                      if (state.tamanhos.isEmpty) {
                        return _buildEmpty();
                      }

                      return ListView.builder(
                        itemCount: state.tamanhos.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemBuilder: (context, index) {
                          final tamanho = state.tamanhos[index];
                          return _buildTamanhoCard(context, tamanho);
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

  Widget _buildTamanhoCard(BuildContext context, Tamanho tamanho) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: tamanho.inativo
              ? Colors.grey.shade300
              : Colors.blue.shade100,
          child: Text(
            tamanho.id?.toString() ??
                (tamanho.nome.isNotEmpty
                    ? tamanho.nome.substring(0, 1).toUpperCase()
                    : '-'),
            style: TextStyle(
              color: tamanho.inativo ? Colors.grey.shade700 : Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () async {
          final result = await TamanhoModal.show(
            context: context,
            idTamanho: tamanho.id,
          );

          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<TamanhosBloc>().add(TamanhosIniciou());
          }
        },
        title: Text(
          tamanho.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tamanho.inativo ? 'Inativo' : 'Ativo',
              style: TextStyle(
                color: tamanho.inativo ? Colors.grey : Colors.blue,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _showDeleteConfirmation(context, tamanho);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Tamanho tamanho) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar Tamanho'),
        content: Text('Deseja desativar o tamanho "${tamanho.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TamanhosBloc>().add(
                TamanhosDesativar(id: tamanho.id!),
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
              'Falha ao carregar tamanhos',
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
            Icon(Icons.straighten_outlined, size: 44, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Nenhum tamanho cadastrado.\nToque no botao + para criar um novo tamanho.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
