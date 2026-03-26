import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation.dart';

class TabelasDePrecoPage extends StatelessWidget {
  final bloc = sl<TabelasDePrecoBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  TabelasDePrecoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TabelasDePrecoBloc>(
      create: (context) => bloc..add(TabelasDePrecoIniciou()),
      child: Scaffold(
        floatingActionButton:
            BlocBuilder<TabelasDePrecoBloc, TabelasDePrecoState>(
              builder: (context, state) {
                if (state is TabelasDePrecoCarregarEmProgresso) {
                  return const FloatingActionButton(
                    onPressed: null,
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                return FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await TabelaDePrecoModal.show(
                      context: context,
                    );

                    if (result == true) {
                      // ignore: use_build_context_synchronously
                      context.read<TabelasDePrecoBloc>().add(
                        TabelasDePrecoIniciou(),
                      );
                    }
                  },
                );
              },
            ),
        appBar: AppBar(title: const Text('Tabelas de Preço')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gerencie suas tabelas de preço',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      autoFocus: false,
                      hintText: 'Buscar tabela por nome',
                      onChanged: (value) {
                        debouncer.run(() {
                          bloc.add(TabelasDePrecoIniciou(busca: value));
                        });
                      },
                      onSubmitted: (value) {
                        bloc.add(TabelasDePrecoIniciou(busca: value));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<TabelasDePrecoBloc, TabelasDePrecoState>(
                  builder: (context, state) {
                    if (state is TabelasDePrecoCarregarEmProgresso ||
                        state is TabelasDePrecoDesativarEmProgresso) {
                      return _buildLoading();
                    }

                    if (state is TabelasDePrecoCarregarFalha ||
                        state is TabelasDePrecoDesativarFalha) {
                      return _buildError();
                    }

                    if (state is TabelasDePrecoCarregarSucesso ||
                        state is TabelasDePrecoDesativarSucesso) {
                      if (state.tabelas.isEmpty) {
                        return _buildEmpty();
                      }

                      return ListView.builder(
                        itemCount: state.tabelas.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemBuilder: (context, index) {
                          final tabela = state.tabelas[index];
                          return _buildTabelaCard(context, tabela);
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

  Widget _buildTabelaCard(BuildContext context, TabelaDePreco tabela) {
    final isInativa = tabela.inativa;

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
            tabela.nome.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) =>
                  TabelaDePrecoDetalhePage(idTabelaDePreco: tabela.id!),
            ),
          );

          // ignore: use_build_context_synchronously
          context.read<TabelasDePrecoBloc>().add(TabelasDePrecoIniciou());
        },
        title: Text(
          tabela.nome,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isInativa ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isInativa ? 'Inativa' : 'Ativa',
              style: TextStyle(color: isInativa ? Colors.grey : Colors.green),
            ),
            if (tabela.terminador != null)
              Text(
                'Terminador: ${tabela.terminador}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: !isInativa
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _showDeleteConfirmation(context, tabela);
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
          const Text('Erro ao carregar tabelas de preço'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              bloc.add(TabelasDePrecoIniciou());
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
          Icon(Icons.price_change_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tabela de preço encontrada',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique em + para adicionar uma nova tabela',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TabelaDePreco tabela) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desativar Tabela de Preço'),
        content: Text('Deseja realmente desativar a tabela "${tabela.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TabelasDePrecoBloc>().add(
                TabelasDePrecoDesativar(id: tabela.id!),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }
}
