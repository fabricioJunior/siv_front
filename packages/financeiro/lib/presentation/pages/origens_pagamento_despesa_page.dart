import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class OrigensPagamentoDespesaPage extends StatelessWidget {
  final bloc = sl<OrigensPagamentoDespesaBloc>();
  final debouncer = Debouncer(milliseconds: 400);

  OrigensPagamentoDespesaPage({super.key});

  int get _empresaId => sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrigensPagamentoDespesaBloc>(
      create: (context) =>
          bloc..add(OrigensPagamentoDespesaIniciou(empresaId: _empresaId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Origens de pagamento')),
        floatingActionButton:
            BlocBuilder<OrigensPagamentoDespesaBloc, OrigensPagamentoDespesaState>(
          builder: (context, state) {
            final carregando =
                state is OrigensPagamentoDespesaCarregarEmProgresso;
            return FloatingActionButton(
              onPressed: carregando
                  ? null
                  : () async {
                      final result = await Navigator.of(context)
                          .pushNamed('/origem_pagamento_despesa');
                      if (result == true) {
                        // ignore: use_build_context_synchronously
                        context.read<OrigensPagamentoDespesaBloc>().add(
                              OrigensPagamentoDespesaIniciou(
                                empresaId: _empresaId,
                              ),
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
                child: SearchBar(
                  hintText: 'Buscar por nome',
                  onChanged: (value) {
                    debouncer.run(() {
                      bloc.add(
                        OrigensPagamentoDespesaIniciou(
                          empresaId: _empresaId,
                          busca: value,
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<OrigensPagamentoDespesaBloc,
                    OrigensPagamentoDespesaState>(
                  builder: (context, state) {
                    if (state is OrigensPagamentoDespesaCarregarEmProgresso) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (state is OrigensPagamentoDespesaCarregarFalha) {
                      return const Center(
                        child: Text('Falha ao carregar origens de pagamento.'),
                      );
                    }

                    if (state.origens.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma origem de pagamento cadastrada.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.origens.length,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemBuilder: (context, index) {
                        final origem = state.origens[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(origem.nome),
                            subtitle: Text(
                              origem.tipo.diaVencimentoObrigatorio
                                  ? '${origem.tipo.label} • vence dia ${origem.diaVencimento}'
                                  : origem.tipo.label,
                            ),
                            onTap: () async {
                              final result = await Navigator.of(context)
                                  .pushNamed(
                                '/origem_pagamento_despesa',
                                arguments: {'id': origem.id},
                              );
                              if (result == true && context.mounted) {
                                context.read<OrigensPagamentoDespesaBloc>().add(
                                      OrigensPagamentoDespesaIniciou(
                                        empresaId: _empresaId,
                                      ),
                                    );
                              }
                            },
                          ),
                        );
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
