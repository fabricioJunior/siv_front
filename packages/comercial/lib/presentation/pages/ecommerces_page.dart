import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class EcommercesPage extends StatelessWidget {
  const EcommercesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommercesBloc>(
      create: (_) => sl<EcommercesBloc>()
        ..add(const EcommercesCarregarSolicitado()),
      child: Scaffold(
        appBar: AppBar(title: const Text('E-commerces')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context)
              .pushNamed('/configuracao_ecommerce')
              .then((_) => context
                  .read<EcommercesBloc>()
                  .add(const EcommercesCarregarSolicitado())),
          icon: const Icon(Icons.add),
          label: const Text('Novo e-commerce'),
        ),
        body: BlocBuilder<EcommercesBloc, EcommercesState>(
          builder: (context, state) {
            return Column(
              children: [
                SwitchListTile(
                  title: const Text('Mostrar excluídos'),
                  value: state.incluirApagados,
                  onChanged: (value) => context.read<EcommercesBloc>().add(
                        EcommercesCarregarSolicitado(incluirApagados: value),
                      ),
                ),
                if (state.erro != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      state.erro!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                Expanded(child: _buildLista(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLista(BuildContext context, EcommercesState state) {
    if (state.status == EcommercesStatus.carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.ecommerces.isEmpty) {
      return const Center(child: Text('Nenhum e-commerce cadastrado.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: state.ecommerces.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final ecommerce = state.ecommerces[index];
        return Opacity(
          opacity: ecommerce.apagado ? 0.6 : 1,
          child: Card(
            child: ListTile(
              onTap: ecommerce.apagado
                  ? null
                  : () => Navigator.of(context)
                      .pushNamed(
                        '/configuracao_ecommerce',
                        arguments: {'ecommerceId': ecommerce.id},
                      )
                      .then((_) => context
                          .read<EcommercesBloc>()
                          .add(const EcommercesCarregarSolicitado())),
              title: Text(ecommerce.titulo),
              subtitle: ecommerce.subtitulo != null
                  ? Text(ecommerce.subtitulo!)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ecommerce.apagado)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Chip(label: Text('Excluído')),
                    ),
                  if (!ecommerce.apagado)
                    IconButton(
                      tooltip: 'Produtos no site',
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () => Navigator.of(context).pushNamed(
                        '/ecommerce_referencias',
                        arguments: {'ecommerceId': ecommerce.id},
                      ),
                    ),
                  if (ecommerce.apagado)
                    IconButton(
                      tooltip: 'Restaurar e-commerce',
                      icon: const Icon(Icons.restore),
                      onPressed: () => context.read<EcommercesBloc>().add(
                            EcommercesRestaurarSolicitado(id: ecommerce.id!),
                          ),
                    )
                  else
                    IconButton(
                      tooltip: 'Excluir e-commerce',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmarExclusao(context, ecommerce),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    Ecommerce ecommerce,
  ) async {
    final bloc = context.read<EcommercesBloc>();
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir e-commerce'),
          content: const Text(
            'Excluir este e-commerce? Sites integrados a ele vão parar de '
            'funcionar corretamente. Essa ação pode ser desfeita depois.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      bloc.add(EcommercesExcluirSolicitado(id: ecommerce.id!));
    }
  }
}
