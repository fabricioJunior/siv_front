import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/ecommerce_referencia_detalhe_bloc/ecommerce_referencia_detalhe_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class EcommerceReferenciaDetalhePage extends StatelessWidget {
  final int ecommerceId;
  final EcommerceReferencia referencia;

  const EcommerceReferenciaDetalhePage({
    super.key,
    required this.ecommerceId,
    required this.referencia,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceReferenciaDetalheBloc>(
      create: (context) => sl<EcommerceReferenciaDetalheBloc>()
        ..add(
          EcommerceReferenciaDetalheIniciou(
            ecommerceId: ecommerceId,
            referenciaEcommerceId: referencia.id!,
            referenciaId: referencia.referenciaId,
            rascunho: referencia.rascunho,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            referencia.referenciaNome ?? 'Referência #${referencia.referenciaId}',
          ),
        ),
        body: BlocConsumer<EcommerceReferenciaDetalheBloc, EcommerceReferenciaDetalheState>(
          listener: (context, state) {
            if (state.step == EcommerceReferenciaDetalheStep.falha &&
                state.erro != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.erro!)),
              );
            }
          },
          builder: (context, state) {
            if (state.step == EcommerceReferenciaDetalheStep.carregando ||
                state.step == EcommerceReferenciaDetalheStep.inicial) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            return ListView(
              children: [
                SwitchListTile(
                  title: const Text('Publicar no site'),
                  subtitle: const Text(
                    'Requer preço e mídia cadastrados -- o backend valida ao publicar.',
                  ),
                  value: !state.rascunho,
                  onChanged: (publicar) {
                    context.read<EcommerceReferenciaDetalheBloc>().add(
                          EcommercePublicacaoAlterou(rascunho: !publicar),
                        );
                  },
                ),
                const Divider(),
                ...state.produtos.map(
                  (produto) => SwitchListTile(
                    title: Text(
                      [
                        if ((produto.corNome ?? '').isNotEmpty)
                          'Cor: ${produto.corNome}',
                        if ((produto.tamanhoNome ?? '').isNotEmpty)
                          'Tamanho: ${produto.tamanhoNome}',
                      ].join('  •  ').ifEmpty('Produto #${produto.produtoId}'),
                    ),
                    subtitle: const Text('Disponível'),
                    value: produto.disponivel,
                    onChanged: (disponivel) {
                      context.read<EcommerceReferenciaDetalheBloc>().add(
                            EcommerceProdutoDisponibilidadeAlterou(
                              produtoId: produto.produtoId,
                              disponivel: disponivel,
                            ),
                          );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

extension _IfEmpty on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
