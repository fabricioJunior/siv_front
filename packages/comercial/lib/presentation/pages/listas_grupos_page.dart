import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

class ListasGruposPage extends StatefulWidget {
  const ListasGruposPage({super.key});

  @override
  State<ListasGruposPage> createState() => _ListasGruposPageState();
}

class _ListasGruposPageState extends State<ListasGruposPage> {
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
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _abrir,
          icon: const Icon(Icons.add),
          label: const Text('Novo grupo'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SivDimensoes.paginaHorizontal,
            vertical: SivDimensoes.paginaVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SivTituloPagina(titulo: 'Grupos de listas'),
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
                      return const Center(child: CircularProgressIndicator.adaptive());
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
                        child: Text('Nenhum grupo criado ainda.', style: textos.apoio),
                      );
                    }
                    return ListView.separated(
                      itemCount: state.itens.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final g = state.itens[i];
                        return ListTile(
                          leading: g.icone == null
                              ? const CircleAvatar(child: Icon(Icons.folder_outlined))
                              : CircleAvatar(backgroundImage: NetworkImage(g.icone!)),
                          title: Text(g.nome),
                          subtitle: g.descricao?.isNotEmpty == true
                              ? Text(g.descricao!, maxLines: 1, overflow: TextOverflow.ellipsis)
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
        ),
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
