import 'package:comercial/presentation/blocs/variacoes_produto_bloc/variacoes_produto_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Abre a folha de seleção de cores (múltipla) ligada ao [VariacoesProdutoBloc].
/// Devolve os itens marcados (null = cancelou).
Future<Map<int, String>?> abrirFolhaCores({
  required BuildContext context,
  required VariacoesProdutoBloc bloc,
  required Map<int, String> selecionados,
  Set<int> usadas = const {},
}) async {
  final r = await showModalBottomSheet<Map<int, String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (ctx) => _FolhaCores(
      bloc: bloc,
      selecionados: selecionados,
      usadas: usadas,
    ),
  );
  return r;
}

/// Abre a folha de seleção de tamanhos (múltipla) ligada ao [VariacoesProdutoBloc].
Future<Map<int, String>?> abrirFolhaTamanhos({
  required BuildContext context,
  required VariacoesProdutoBloc bloc,
  required Map<int, String> selecionados,
}) async {
  return showModalBottomSheet<Map<int, String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (ctx) => _FolhaTamanhos(
      bloc: bloc,
      selecionados: selecionados,
    ),
  );
}

/// Abre a folha de seleção de estampa (única) ligada ao [VariacoesProdutoBloc].
/// Devolve `{}` para "Sem estampa", `{id: nome}` para estampa escolhida, null = cancelou.
Future<Map<int, String>?> abrirFolhaEstampa({
  required BuildContext context,
  required VariacoesProdutoBloc bloc,
  required Map<int, String> selecionados,
}) async {
  return showModalBottomSheet<Map<int, String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (ctx) => _FolhaEstampa(
      bloc: bloc,
      selecionados: selecionados,
    ),
  );
}

// ---------------------------------------------------------------------------
// Helpers internos
// ---------------------------------------------------------------------------

class _FolhaCores extends StatefulWidget {
  final VariacoesProdutoBloc bloc;
  final Map<int, String> selecionados;
  final Set<int> usadas;

  const _FolhaCores({
    required this.bloc,
    required this.selecionados,
    required this.usadas,
  });

  @override
  State<_FolhaCores> createState() => _FolhaCoresState();
}

class _FolhaCoresState extends State<_FolhaCores> {
  late final _sel = Map<int, String>.from(widget.selecionados);
  final _busca = TextEditingController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return BlocProvider<VariacoesProdutoBloc>.value(
      value: widget.bloc,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: Column(
            children: [
              _cabecalho(context, 'Cores', textos),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _campoBusca(_busca, 'Buscar cor'),
              ),
              Expanded(
                child: BlocBuilder<VariacoesProdutoBloc, VariacoesProdutoState>(
                  builder: (_, state) {
                    final busca = normalizarBusca(_busca.text);
                    final todasOrdenadas = state.cores.itens.where((c) {
                      return normalizarBusca(c.nome).contains(busca);
                    }).toList();

                    // "Já usadas nesta referência" primeiro
                    final usadas = todasOrdenadas
                        .where((c) => widget.usadas.contains(c.id))
                        .toList();
                    final demais = todasOrdenadas
                        .where((c) => !widget.usadas.contains(c.id))
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        if (usadas.isNotEmpty) ...[
                          _rotuloSecao('JÁ USADAS NESTA REFERÊNCIA', context),
                          for (final c in usadas)
                            _linhaOpcao(
                              c.id, c.nome, _sel.containsKey(c.id),
                              () => setState(() {
                                _sel.containsKey(c.id)
                                    ? _sel.remove(c.id)
                                    : _sel[c.id] = c.nome;
                              }),
                              context,
                            ),
                          _rotuloSecao('TODAS', context),
                        ],
                        for (final c in demais)
                          _linhaOpcao(
                            c.id, c.nome, _sel.containsKey(c.id),
                            () => setState(() {
                              _sel.containsKey(c.id)
                                  ? _sel.remove(c.id)
                                  : _sel[c.id] = c.nome;
                            }),
                            context,
                          ),
                        if (state.cores.status == VariacaoStatus.carregando)
                          const Center(child: CircularProgressIndicator.adaptive()),
                      ],
                    );
                  },
                ),
              ),
              _botaoConfirmar(context, _sel.length, () {
                Navigator.of(context).pop(Map<int, String>.from(_sel));
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolhaTamanhos extends StatefulWidget {
  final VariacoesProdutoBloc bloc;
  final Map<int, String> selecionados;

  const _FolhaTamanhos({
    required this.bloc,
    required this.selecionados,
  });

  @override
  State<_FolhaTamanhos> createState() => _FolhaTamanhosState();
}

class _FolhaTamanhosState extends State<_FolhaTamanhos> {
  late final _sel = Map<int, String>.from(widget.selecionados);

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return BlocProvider<VariacoesProdutoBloc>.value(
      value: widget.bloc,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Column(
          children: [
            _cabecalho(context, 'Tamanhos', textos),
            Expanded(
              child: BlocBuilder<VariacoesProdutoBloc, VariacoesProdutoState>(
                builder: (_, state) {
                  if (state.tamanhos.status == VariacaoStatus.carregando) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  final numericos = state.tamanhos.itens
                      .where((t) => t.numerico)
                      .toList()
                        ..sort((a, b) => compararTamanhos(a.nome, b.nome));
                  final letras = state.tamanhos.itens
                      .where((t) => !t.numerico)
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (numericos.isNotEmpty) ...[
                        _rotuloSecao('NUMÉRICOS', context),
                        const SizedBox(height: 8),
                        _blocoTamanhos(numericos, cores, textos),
                        const SizedBox(height: 16),
                      ],
                      if (letras.isNotEmpty) ...[
                        _rotuloSecao('LETRAS', context),
                        const SizedBox(height: 8),
                        _blocoTamanhos(letras, cores, textos),
                        const SizedBox(height: 16),
                      ],
                      // Marcar todos por grupo
                      if (numericos.isNotEmpty)
                        TextButton(
                          key: const Key('tam_marcar_todos_numericos'),
                          onPressed: () => setState(() {
                            final todos = numericos.map((t) => t.id).toSet();
                            final todosMarc = todos.every(_sel.containsKey);
                            if (todosMarc) {
                              for (final id in todos) {
                                _sel.remove(id);
                              }
                            } else {
                              for (final t in numericos) {
                                _sel[t.id] = t.nome;
                              }
                            }
                          }),
                          child: const Text('Marcar/desmarcar todos numéricos'),
                        ),
                      if (letras.isNotEmpty)
                        TextButton(
                          key: const Key('tam_marcar_todos_letras'),
                          onPressed: () => setState(() {
                            final todos = letras.map((t) => t.id).toSet();
                            final todosMarc = todos.every(_sel.containsKey);
                            if (todosMarc) {
                              for (final id in todos) {
                                _sel.remove(id);
                              }
                            } else {
                              for (final t in letras) {
                                _sel[t.id] = t.nome;
                              }
                            }
                          }),
                          child: const Text('Marcar/desmarcar todos em letras'),
                        ),
                    ],
                  );
                },
              ),
            ),
            _botaoConfirmar(context, _sel.length, () {
              Navigator.of(context).pop(Map<int, String>.from(_sel));
            }),
          ],
        ),
      ),
    );
  }

  Widget _blocoTamanhos(
    List<TamanhoOpcao> opcoes,
    SivColors cores,
    SivTextStyles textos,
  ) =>
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.5,
        children: [
          for (final t in opcoes)
            InkWell(
              key: Key('tam_sel_${t.id}'),
              onTap: () => setState(() {
                _sel.containsKey(t.id) ? _sel.remove(t.id) : _sel[t.id] = t.nome;
              }),
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _sel.containsKey(t.id) ? cores.aco : cores.superficie,
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                  border: Border.all(
                    color: _sel.containsKey(t.id) ? cores.aco : cores.hairline,
                  ),
                ),
                child: Text(
                  t.nome,
                  style: textos.secao.copyWith(
                    color: _sel.containsKey(t.id) ? Colors.white : null,
                  ),
                ),
              ),
            ),
        ],
      );
}

class _FolhaEstampa extends StatefulWidget {
  final VariacoesProdutoBloc bloc;
  final Map<int, String> selecionados;

  const _FolhaEstampa({
    required this.bloc,
    required this.selecionados,
  });

  @override
  State<_FolhaEstampa> createState() => _FolhaEstampaState();
}

class _FolhaEstampaState extends State<_FolhaEstampa> {
  // null = nada escolhido ainda; {} = "Sem estampa"; {id: nome} = estampa
  Map<int, String>? _sel;
  final _busca = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sel = Map<int, String>.from(widget.selecionados);
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final semEstampaSelecionada = _sel != null && _sel!.isEmpty;
    return BlocProvider<VariacoesProdutoBloc>.value(
      value: widget.bloc,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: Column(
            children: [
              _cabecalho(context, 'Estampa', textos),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _campoBusca(_busca, 'Buscar estampa'),
              ),
              Expanded(
                child: BlocBuilder<VariacoesProdutoBloc, VariacoesProdutoState>(
                  builder: (_, state) {
                    final busca = normalizarBusca(_busca.text);
                    final filtradas = state.estampas.itens
                        .where(
                          (e) => normalizarBusca(e.nome).contains(busca),
                        )
                        .toList();
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        // "Sem estampa" como primeira opção
                        InkWell(
                          key: const Key('estampa_sem'),
                          onTap: () {
                            Navigator.of(context).pop(<int, String>{});
                          },
                          child: Container(
                            height: 52,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            color: semEstampaSelecionada
                                ? cores.selecaoFundo
                                : null,
                            child: Row(
                              children: [
                                Icon(
                                  semEstampaSelecionada
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: semEstampaSelecionada
                                      ? cores.aco
                                      : cores.textoDesabilitado,
                                ),
                                const SizedBox(width: 12),
                                Text('Sem estampa', style: textos.corpo),
                              ],
                            ),
                          ),
                        ),
                        if (state.estampas.status == VariacaoStatus.carregando)
                          const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        for (final e in filtradas)
                          InkWell(
                            key: Key('estampa_${e.id}'),
                            onTap: () {
                              Navigator.of(context).pop({e.id: e.nome});
                            },
                            child: Container(
                              height: 52,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              color: (_sel?.containsKey(e.id) ?? false)
                                  ? cores.selecaoFundo
                                  : null,
                              child: Row(
                                children: [
                                  Icon(
                                    (_sel?.containsKey(e.id) ?? false)
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: (_sel?.containsKey(e.id) ?? false)
                                        ? cores.aco
                                        : cores.textoDesabilitado,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      e.nome,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textos.corpo,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
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

// ---------------------------------------------------------------------------
// Widgets auxiliares compartilhados
// ---------------------------------------------------------------------------

Widget _cabecalho(BuildContext context, String titulo, SivTextStyles textos) {
  return Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        Expanded(
          child: Text(titulo, style: textos.secao),
        ),
      ],
    ),
  );
}

Widget _campoBusca(TextEditingController controller, String hint) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search, size: 18),
      isDense: true,
    ),
  );
}

Widget _rotuloSecao(String texto, BuildContext context) {
  final textos = context.sivTextos;
  final cores = context.sivColors;
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
    child: Text(
      texto,
      style: textos.rotulo.copyWith(color: cores.textoApoio),
    ),
  );
}

Widget _linhaOpcao(
  int id,
  String nome,
  bool marcada,
  VoidCallback onTap,
  BuildContext context,
) {
  final cores = context.sivColors;
  final textos = context.sivTextos;
  return InkWell(
    key: Key('cor_sel_$id'),
    onTap: onTap,
    child: Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: marcada ? cores.selecaoFundo : null,
      child: Row(
        children: [
          Icon(
            marcada ? Icons.check_box : Icons.check_box_outline_blank,
            color: marcada ? cores.aco : cores.textoDesabilitado,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textos.corpo,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _botaoConfirmar(BuildContext context, int n, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onTap,
        child: Text('CONFIRMAR · $n'),
      ),
    ),
  );
}
