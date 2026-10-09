import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

class ListaGrupoPage extends StatefulWidget {
  final int? grupoId;

  const ListaGrupoPage({super.key, this.grupoId});

  @override
  State<ListaGrupoPage> createState() => _ListaGrupoPageState();
}

class _ListaGrupoPageState extends State<ListaGrupoPage> {
  late final ListaGrupoBloc _bloc;
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  List<int> _listaIds = [];
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ListaGrupoBloc>()..add(ListaGrupoAbriu(id: widget.grupoId));
  }

  @override
  void dispose() {
    _bloc.close();
    _nome.dispose();
    _descricao.dispose();
    super.dispose();
  }

  void _inicializar(ListaGrupoState state) {
    if (_inicializado || state.step != ListaGrupoStep.pronto) return;
    _inicializado = true;
    final g = state.grupo;
    if (g == null) return;
    _nome.text = g.nome;
    _descricao.text = g.descricao ?? '';
    final ordenadas = [...g.listas]..sort((a, b) => a.ordem.compareTo(b.ordem));
    _listaIds = ordenadas.map((l) => l.listaId).toList();
  }

  void _mover(int i, int delta) {
    final j = i + delta;
    if (j < 0 || j >= _listaIds.length) return;
    setState(() {
      final id = _listaIds.removeAt(i);
      _listaIds.insert(j, id);
    });
  }

  String _nomeDa(ListaGrupoState state, int id) {
    for (final o in state.opcoes) {
      if (o.id == id) return o.titulo?.isNotEmpty == true ? o.titulo! : o.hash;
    }
    for (final l in state.grupo?.listas ?? const <ListaGrupoLista>[]) {
      if (l.listaId == id) return l.nome;
    }
    return 'Lista $id';
  }

  Future<void> _adicionarLista(ListaGrupoState state) async {
    final candidatas = state.opcoes.where((o) => !_listaIds.contains(o.id)).toList();
    final escolhida = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => candidatas.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nenhuma lista de catálogo disponível.'),
            )
          : ListView(
              children: [
                for (final o in candidatas)
                  ListTile(
                    title: Text(o.titulo?.isNotEmpty == true ? o.titulo! : o.hash),
                    onTap: () => Navigator.pop(ctx, o.id),
                  ),
              ],
            ),
    );
    if (escolhida != null) setState(() => _listaIds.add(escolhida));
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return BlocProvider<ListaGrupoBloc>.value(
      value: _bloc,
      child: BlocConsumer<ListaGrupoBloc, ListaGrupoState>(
        listener: (context, state) {
          if (state.erro?.isNotEmpty == true) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.erro!)));
          }
          if (state.step == ListaGrupoStep.salvo) Navigator.of(context).pop();
          if (state.step == ListaGrupoStep.pronto && !_inicializado) {
            setState(() => _inicializar(state));
          }
        },
        builder: (context, state) {
          final carregando = state.step == ListaGrupoStep.carregando ||
              state.step == ListaGrupoStep.inicial;
          final salvando = state.step == ListaGrupoStep.salvando;
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.paginaHorizontal,
              vertical: SivDimensoes.paginaVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SivTituloPagina(
                  titulo: widget.grupoId == null ? 'Novo grupo' : 'Editar grupo',
                ),
                Expanded(
                  child: carregando
                      ? const Center(child: CircularProgressIndicator.adaptive())
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: ListView(
                            children: [
                              TextField(
                                key: const Key('grupo-nome'),
                                controller: _nome,
                                maxLength: 255,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(labelText: 'Nome'),
                              ),
                              TextField(
                                key: const Key('grupo-descricao'),
                                controller: _descricao,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Descrição (opcional)',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (state.grupo?.icone != null &&
                                      state.iconeLocal == null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(state.grupo!.icone!),
                                      ),
                                    ),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(0, 44),
                                      ),
                                      onPressed: salvando
                                          ? null
                                          : () => _bloc
                                              .add(const ListaGrupoIconeEscolheu()),
                                      icon: const Icon(Icons.image_outlined, size: 18),
                                      label: Text(
                                        state.iconeLocal?.nome ??
                                            (state.grupo?.icone == null
                                                ? 'Escolher ícone'
                                                : 'Trocar ícone'),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Listas do grupo (${_listaIds.length})',
                                      style: textos.rotulo,
                                    ),
                                  ),
                                  FilledButton.icon(
                                    key: const Key('grupo-adicionar-lista'),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(0, 44),
                                    ),
                                    onPressed: () => _adicionarLista(state),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Adicionar'),
                                  ),
                                ],
                              ),
                              if (_listaIds.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'Nenhuma lista no grupo.',
                                    style: textos.apoio,
                                  ),
                                ),
                              for (var i = 0; i < _listaIds.length; i++)
                                ListTile(
                                  key: ValueKey('grupo-lista-${_listaIds[i]}'),
                                  leading: CircleAvatar(child: Text('${i + 1}')),
                                  title: Text(_nomeDa(state, _listaIds[i])),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Subir',
                                        constraints: const BoxConstraints(
                                            minWidth: 44, minHeight: 44),
                                        onPressed: i == 0 ? null : () => _mover(i, -1),
                                        icon: const Icon(Icons.arrow_upward),
                                      ),
                                      IconButton(
                                        tooltip: 'Descer',
                                        constraints: const BoxConstraints(
                                            minWidth: 44, minHeight: 44),
                                        onPressed: i == _listaIds.length - 1
                                            ? null
                                            : () => _mover(i, 1),
                                        icon: const Icon(Icons.arrow_downward),
                                      ),
                                      IconButton(
                                        tooltip: 'Remover do grupo',
                                        constraints: const BoxConstraints(
                                            minWidth: 44, minHeight: 44),
                                        onPressed: () =>
                                            setState(() => _listaIds.removeAt(i)),
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                key: const Key('grupo-salvar'),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                ),
                                onPressed: salvando || _nome.text.trim().isEmpty
                                    ? null
                                    : () => _bloc.add(
                                          ListaGrupoSalvou(
                                            nome: _nome.text,
                                            descricao: _descricao.text,
                                            listaIds: _listaIds,
                                          ),
                                        ),
                                icon: salvando
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator.adaptive(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.check),
                                label: const Text('Salvar grupo'),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
