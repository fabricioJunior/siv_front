import 'package:comercial/presentation/blocs/ecommerce_referencias_bloc/ecommerce_referencias_bloc.dart';
import 'package:comercial/presentation/pages/ecommerce_referencia_detalhe_page.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentantion/widgets/referencia_seletor.dart';

class EcommerceReferenciasPage extends StatelessWidget {
  final int ecommerceId;

  const EcommerceReferenciasPage({super.key, required this.ecommerceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceReferenciasBloc>(
      create: (context) => sl<EcommerceReferenciasBloc>()
        ..add(EcommerceReferenciasIniciou(ecommerceId: ecommerceId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Produtos no site')),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () => _adicionarReferencias(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar referências'),
          ),
        ),
        body: BlocBuilder<EcommerceReferenciasBloc, EcommerceReferenciasState>(
          builder: (context, state) {
            if (state is EcommerceReferenciasCarregarEmProgresso ||
                state is EcommerceReferenciasInitial) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is EcommerceReferenciasCarregarFalha) {
              return const Center(
                child: Text('Não foi possível carregar as referências.'),
              );
            }

            if (state.referencias.isEmpty) {
              return const Center(
                child: Text('Nenhuma referência vinculada ao e-commerce.'),
              );
            }

            return ListView.builder(
              itemCount: state.referencias.length,
              itemBuilder: (context, index) {
                final referencia = state.referencias[index];
                return ListTile(
                  title: Text(
                    referencia.referenciaNome ??
                        'Referência #${referencia.referenciaId}',
                  ),
                  trailing: Chip(
                    label: Text(referencia.rascunho ? 'Rascunho' : 'Publicado'),
                    backgroundColor: referencia.rascunho
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
                  ),
                  onTap: () async {
                    final bloc = context.read<EcommerceReferenciasBloc>();
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EcommerceReferenciaDetalhePage(
                          ecommerceId: ecommerceId,
                          referencia: referencia,
                        ),
                      ),
                    );
                    bloc.add(EcommerceReferenciasIniciou(ecommerceId: ecommerceId));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _adicionarReferencias(BuildContext context) async {
    final bloc = context.read<EcommerceReferenciasBloc>();
    List<int> idsSelecionados = [];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReferenciaSeletor(
                modo: ReferenciaSeletorModo.multipla,
                permitirCadastro: false,
                onReferenciaChanged: (selecionadas) {
                  idsSelecionados = selecionadas
                      .map((referencia) => referencia.id)
                      .whereType<int>()
                      .toList();
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  for (final referenciaId in idsSelecionados) {
                    bloc.add(
                      EcommerceReferenciaAdicionou(
                        ecommerceId: ecommerceId,
                        referenciaId: referenciaId,
                      ),
                    );
                  }
                },
                child: const Text('Adicionar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
