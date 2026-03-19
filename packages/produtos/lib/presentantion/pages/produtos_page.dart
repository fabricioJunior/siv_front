import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class ProdutosPage extends StatelessWidget {
  final bloc = sl<ProdutosBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  ProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProdutosBloc>(
      create: (_) => bloc..add(ProdutosIniciou()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Produtos')),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const ProdutoPage()),
            );

            if (result == true) {
              // ignore: use_build_context_synchronously
              context.read<ProdutosBloc>().add(ProdutosIniciou());
            }
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SearchBar(
                  hintText: 'Buscar por ID externo',
                  onChanged: (value) {
                    debouncer.run(() {
                      bloc.add(ProdutosIniciou(idExterno: value));
                    });
                  },
                  onSubmitted: (value) {
                    bloc.add(ProdutosIniciou(idExterno: value));
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<ProdutosBloc, ProdutosState>(
                  builder: (context, state) {
                    if (state is ProdutosCarregarEmProgresso ||
                        state is ProdutosExcluirEmProgresso) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (state is ProdutosCarregarFalha ||
                        state is ProdutosExcluirFalha) {
                      return _buildError(context);
                    }

                    if (state.produtos.isEmpty) {
                      return _buildEmpty();
                    }

                    return ListView.builder(
                      itemCount: state.produtos.length,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemBuilder: (context, index) {
                        final produto = state.produtos[index];
                        return _buildProdutoCard(context, produto);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProdutoCard(BuildContext context, Produto produto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          'Referência:  ${produto.referencia?.id ?? '-'} - ${produto.referencia?.nome ?? '-'}',
        ),
        subtitle: Text(
          'Cor: ${produto.cor?.nome ?? '-'} · Tamanho: ${produto.tamanho?.nome ?? '-'} · ID: ${produto.id ?? '-'} ',
        ),
        isThreeLine: true,
        onTap: () async {
          final result = await ProdutoVisualizacaoModal.show(
            context: context,
            produto: produto,
          );

          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<ProdutosBloc>().add(ProdutosIniciou());
          }
        },
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 12),
          const Text('Erro ao carregar produtos'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              bloc.add(ProdutosIniciou());
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(child: Text('Nenhum produto encontrado.'));
  }
}
