import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:precos/models.dart';
import 'package:precos/presentation.dart';

class SelecionarTabelaDePrecoPage extends StatelessWidget {
  final bloc = sl<TabelasDePrecoBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  SelecionarTabelaDePrecoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TabelasDePrecoBloc>(
      create: (context) => bloc..add(TabelasDePrecoIniciou()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Selecionar Tabela de Preço')),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Escolha a tabela de preço para visualizar os preços das referências',
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
                    if (state is TabelasDePrecoCarregarEmProgresso) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (state is TabelasDePrecoCarregarFalha) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
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

                    if (state is TabelasDePrecoCarregarSucesso) {
                      if (state.tabelas.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.price_change_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma tabela de preço encontrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
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
        onTap: tabela.id == null
            ? null
            : () => Navigator.of(context).pop<int>(tabela.id),
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
              'ID: ${tabela.id ?? '-'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
