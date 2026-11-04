import 'package:core/bloc.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/consultar_produto_bloc/consultar_produto_bloc.dart';
import 'package:produtos/presentantion/widgets/consulta/consulta_formato.dart';

/// Resultados agrupados por referência, com rolagem infinita. A posição é preservada
/// pelo [PageStorageKey].
class ConsultaLista extends StatefulWidget {
  final ValueChanged<ConsultaReferenciaItem> onAbrir;

  const ConsultaLista({super.key, required this.onAbrir});

  @override
  State<ConsultaLista> createState() => _ConsultaListaState();
}

class _ConsultaListaState extends State<ConsultaLista> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.extentAfter < 300) {
        context.read<ConsultarProdutoBloc>().add(ConsultarProdutoMaisCarregado());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConsultarProdutoBloc>().state;
    final theme = Theme.of(context);

    Widget msg(String texto, {bool erro = false}) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: erro ? TextStyle(color: theme.colorScheme.error) : theme.textTheme.bodyMedium,
        ),
      ),
    );

    if (state.carregando) return const Center(child: CircularProgressIndicator());
    if (state.erro != null) return msg(state.erro!, erro: true);
    if (!state.buscaValida) {
      return msg('Digite ao menos 2 caracteres ou escolha um filtro de cor, tamanho ou estampa.');
    }
    if (state.itens.isEmpty) return msg('Nenhum produto encontrado.');

    return ListView.separated(
      key: const PageStorageKey('consulta-lista'),
      controller: _controller,
      itemCount: state.itens.length + (state.carregandoMais ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        if (i >= state.itens.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        }
        final item = state.itens[i];
        return _ItemConsulta(
          item: item,
          selecionado: item.referenciaId == state.referenciaAbertaId,
          onTap: () => widget.onAbrir(item),
        );
      },
    );
  }
}

class _ItemConsulta extends StatelessWidget {
  final ConsultaReferenciaItem item;
  final bool selecionado;
  final VoidCallback onTap;

  const _ItemConsulta({required this.item, required this.selecionado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final batem = item.variacoes.where((v) => v.bateFiltro).toList();
    final resumo = batem.take(3).map((v) => v.descricao).join('  |  ') +
        (batem.length > 3 ? '  +${batem.length - 3}' : '');
    return ListTile(
      selected: selecionado,
      selectedTileColor: theme.colorScheme.primaryContainer,
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 56,
          height: 56,
          child: item.capaUrl != null
              ? Image.network(
                  item.capaUrl!,
                  fit: BoxFit.cover,
                  cacheWidth: 168, // decodifica pequeno: o original tem milhares de px e estoura a memória

                  errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported_outlined),
                )
              : const Icon(Icons.image_not_supported_outlined),
        ),
      ),
      title: Text(item.nome, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (item.idExterno != null) 'REF ${item.idExterno}',
          if (resumo.isNotEmpty) resumo,
        ].join('\n'),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(item.preco != null ? moeda(item.preco!) : 'Sem preço', style: theme.textTheme.titleSmall),
          Text('${item.saldoFiltrado} un.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
