import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/ecommerce_referencia_detalhe_bloc/ecommerce_referencia_detalhe_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';
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
            referencia.referenciaNome ??
                'Referência #${referencia.referenciaId}',
          ),
        ),
        body: BlocConsumer<EcommerceReferenciaDetalheBloc,
            EcommerceReferenciaDetalheState>(
          listenWhen: (previous, current) =>
              current.step == EcommerceReferenciaDetalheStep.falha ||
              (previous.processandoLote && !current.processandoLote),
          listener: (context, state) {
            if (state.step == EcommerceReferenciaDetalheStep.falha &&
                state.erro != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.erro!)),
              );
            } else if (!state.processandoLote) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Produtos atualizados.')),
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
                _CabecalhoReferencia(referencia: referencia),
                PermissaoPorNome(
                  idComponente: 'PRDFM003',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(
                        '/referencia',
                        arguments: {'idReferencia': referencia.referenciaId},
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar referência'),
                    ),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Publicar no site'),
                  subtitle: const Text(
                    'Requer preço e mídia cadastrados, caso a referência não tenha as informações a publicação será recusada.',
                  ),
                  value: !state.rascunho,
                  onChanged: (publicar) {
                    context.read<EcommerceReferenciaDetalheBloc>().add(
                          EcommercePublicacaoAlterou(rascunho: !publicar),
                        );
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.processandoLote
                              ? null
                              : () => context
                                  .read<EcommerceReferenciaDetalheBloc>()
                                  .add(
                                    const EcommercePublicarDisponiveisSolicitou(),
                                  ),
                          child: const Text('Publicar disponíveis'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.processandoLote
                              ? null
                              : () => context
                                  .read<EcommerceReferenciaDetalheBloc>()
                                  .add(
                                    const EcommerceRemoverSemEstoqueSolicitou(),
                                  ),
                          child: const Text('Remover sem estoque'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.processandoLote)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
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
                    subtitle: Text('Disponível  •  Estoque: ${produto.saldo}'),
                    value: produto.disponivel,
                    onChanged: state.processandoLote
                        ? null
                        : (disponivel) {
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

class _CabecalhoReferencia extends StatelessWidget {
  final EcommerceReferencia referencia;

  const _CabecalhoReferencia({required this.referencia});

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 96,
              height: 96,
              child: referencia.imagemUrl != null
                  ? Image.network(
                      referencia.imagemUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImagem(theme),
                    )
                  : _placeholderImagem(theme),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referencia.referenciaNome ??
                      'Referência #${referencia.referenciaId}',
                  style: theme.textTheme.titleMedium,
                ),
                if (referencia.unidadeMedida != null)
                  Text(
                    'Unidade: ${referencia.unidadeMedida}',
                    style: theme.textTheme.bodySmall,
                  ),
                if ((referencia.descricao ?? '').isNotEmpty)
                  Text(
                    referencia.descricao!,
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
                Text(
                  referencia.valor != null
                      ? _formatarMoeda(referencia.valor!)
                      : 'Preço não cadastrado',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImagem(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
