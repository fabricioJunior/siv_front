import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class FormasDePagamentoPage extends StatelessWidget {
  final bloc = sl<FormasDePagamentoBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  FormasDePagamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormasDePagamentoBloc>(
      create: (context) => bloc..add(FormasDePagamentoIniciou()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Formas de pagamento')),
        floatingActionButton:
            BlocBuilder<FormasDePagamentoBloc, FormasDePagamentoState>(
          builder: (context, state) {
            final carregando = state is FormasDePagamentoCarregarEmProgresso;

            return FloatingActionButton(
              onPressed: carregando
                  ? null
                  : () async {
                      final result = await Navigator.of(context).pushNamed(
                        '/forma_de_pagamento',
                      );

                      if (result == true) {
                        // ignore: use_build_context_synchronously
                        context.read<FormasDePagamentoBloc>().add(
                              FormasDePagamentoIniciou(),
                            );
                      }
                    },
              child: carregando
                  ? const CircularProgressIndicator.adaptive()
                  : const Icon(Icons.add),
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cadastre e mantenha os meios aceitos no caixa.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SearchBar(
                      hintText: 'Buscar por descricao',
                      onChanged: (value) {
                        debouncer.run(() {
                          bloc.add(FormasDePagamentoIniciou(busca: value));
                        });
                      },
                      onSubmitted: (value) {
                        bloc.add(FormasDePagamentoIniciou(busca: value));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    BlocBuilder<FormasDePagamentoBloc, FormasDePagamentoState>(
                  builder: (context, state) {
                    if (state is FormasDePagamentoCarregarEmProgresso) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (state is FormasDePagamentoCarregarFalha) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Falha ao carregar formas de pagamento.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    final itens = state.formasDePagamento;
                    if (itens.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Nenhuma forma de pagamento cadastrada.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: itens.length,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemBuilder: (context, index) {
                        final item = itens[index];
                        return _FormaDePagamentoCard(item: item);
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
}

class _FormaDePagamentoCard extends StatelessWidget {
  final FormaDePagamento item;

  const _FormaDePagamentoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              item.inativa ? Colors.grey.shade300 : Colors.green.shade100,
          child: Icon(
            _iconForTipo(item.tipo),
            color: item.inativa ? Colors.grey.shade700 : Colors.green.shade700,
          ),
        ),
        title: Text(
          item.descricao,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${item.tipo}'),
            Text('Inicio: ${item.inicio} | Parcelas: ${item.parcelas}'),
            Text(
              item.inativa ? 'Inativa' : 'Ativa',
              style: TextStyle(
                color: item.inativa ? Colors.grey : Colors.green,
              ),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            '/forma_de_pagamento',
            arguments: {'idFormaDePagamento': item.id},
          );

          if (result == true && context.mounted) {
            context.read<FormasDePagamentoBloc>().add(
                  FormasDePagamentoIniciou(),
                );
          }
        },
      ),
    );
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'Pix':
        return Icons.pix;
      case 'Cartão':
        return Icons.credit_card;
      case 'Dinheiro':
        return Icons.payments;
      case 'Fatura':
        return Icons.receipt_long;
      case 'Cheque':
        return Icons.request_page;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
