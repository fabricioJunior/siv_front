import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class PedidosPage extends StatelessWidget {
  const PedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PedidosBloc>(
      create: (_) => sl<PedidosBloc>()..add(PedidosIniciou()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pedidos')),
            floatingActionButton: BlocBuilder<PedidosBloc, PedidosState>(
              builder: (context, state) {
                final carregando = state.step == PedidosStep.carregando;
                return FloatingActionButton(
                  onPressed: carregando
                      ? null
                      : () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/pedido',
                          );
                          if (result == true && context.mounted) {
                            context.read<PedidosBloc>().add(PedidosIniciou());
                          }
                        },
                  child: const Icon(Icons.add),
                );
              },
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<PedidosBloc>().add(PedidosIniciou());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SearchBar(
                    hintText: 'Buscar por id, pessoa ou situacao',
                    onChanged: (value) {
                      context
                          .read<PedidosBloc>()
                          .add(PedidosBuscaAlterada(value));
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<PedidosBloc, PedidosState>(
                    builder: (context, state) {
                      if (state.step == PedidosStep.carregando) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state.step == PedidosStep.falha) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            state.erro ?? 'Falha ao carregar pedidos.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (state.filtrados.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum pedido encontrado.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Column(
                        children: state.filtrados.map((pedido) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text('Pedido #${pedido.id ?? '-'}'),
                              subtitle: Text(
                                'Pessoa: ${pedido.pessoaId ?? '-'} | Tipo: ${pedido.tipo ?? '-'}\nSituacao: ${pedido.situacao ?? '-'}',
                              ),
                              onTap: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/pedido',
                                  arguments: {'idPedido': pedido.id},
                                );
                                if (result == true && context.mounted) {
                                  context
                                      .read<PedidosBloc>()
                                      .add(PedidosIniciou());
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
