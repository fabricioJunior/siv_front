import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Aba "Grupos" da tela de listas do e-commerce.
class GruposAba extends StatefulWidget {
  const GruposAba({super.key});

  @override
  State<GruposAba> createState() => _GruposAbaState();
}

class _GruposAbaState extends State<GruposAba> {
  late final ListasGruposBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ListasGruposBloc>()..add(const ListasGruposIniciou());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _abrir([int? id]) async {
    await Navigator.pushNamed(context, '/lista_grupo', arguments: {'id': id});
    if (mounted) _bloc.add(const ListasGruposIniciou());
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return BlocProvider<ListasGruposBloc>.value(
      value: _bloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const Key('grupos-novo'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: _abrir,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo grupo'),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocConsumer<ListasGruposBloc, ListasGruposState>(
              listener: (context, state) {
                if (state.erro?.isNotEmpty == true &&
                    state.step != ListasGruposStep.falha) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.erro!)));
                }
              },
              builder: (context, state) {
                if (state.step == ListasGruposStep.carregando ||
                    state.step == ListasGruposStep.inicial) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (state.step == ListasGruposStep.falha) {
                  return Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(state.erro ?? 'Falha ao carregar.'),
                      onPressed: () => _bloc.add(const ListasGruposIniciou()),
                    ),
                  );
                }
                if (state.itens.isEmpty) {
                  return Center(
                    child:
                        Text('Nenhum grupo criado ainda.', style: textos.apoio),
                  );
                }
                return ListView.separated(
                  itemCount: state.itens.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final g = state.itens[i];
                    return ListTile(
                      leading: g.icone == null
                          ? const CircleAvatar(
                              child: Icon(Icons.folder_outlined))
                          : CircleAvatar(
                              backgroundImage: NetworkImage(g.icone!)),
                      title: Text(g.nome),
                      subtitle: g.descricao?.isNotEmpty == true
                          ? Text(g.descricao!,
                              maxLines: 1, overflow: TextOverflow.ellipsis)
                          : null,
                      trailing: IconButton(
                        tooltip: 'Excluir grupo',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmarExclusao(g),
                      ),
                      onTap: () => _abrir(g.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusao(ListaGrupo g) => SivDialogo.mostrar(
        context,
        titulo: 'Excluir grupo',
        corpo: Text('Excluir "${g.nome}"? As listas dele não são apagadas.'),
        textoAcao: 'Excluir',
        onConfirmar: (_) => _bloc.add(ListasGruposExcluiu(g.id)),
      );
}
