import 'package:flutter/material.dart';

import '../tema.dart';
import 'generic_seletor.dart' show SeletorGenericoModo, normalizarBusca;

/// Seletor em tela cheia (mobile): busca no topo, chips dos selecionados e
/// lista inline (sem overlay) acima do teclado. Abra com [SeletorTelaCheia.abrir].
///
/// Múltipla: checkbox + rodapé "CONFIRMAR · N"; devolve a lista final (voltar
/// = cancelar, devolve null). Única: tocar escolhe e fecha, devolvendo `[item]`.
class SeletorTelaCheia<T> extends StatefulWidget {
  final String titulo;
  final String? subtitulo;
  final List<T> itens;
  final String Function(T item) itemLabel;
  final Object? Function(T item)? itemKey;
  final SeletorGenericoModo modo;
  final List<T> selecionadosIniciais;

  /// Itens exibidos no topo em "JÁ USADAS NESTA REFERÊNCIA".
  final List<T> jaUsados;

  /// "cor"/"cores": rótulos de "TODAS AS CORES", "CONFIRMAR · N CORES" e
  /// "Cadastrar “x” como nova cor". Nulos = sem cabeçalho/sufixo.
  final String? nomeSingular;
  final String? nomePlural;
  final bool feminino;
  final String hintText;

  /// Cadastra [texto] e devolve o item criado (null = só recarregar `itens`).
  /// Sem callback, a linha "+ Cadastrar…" não aparece.
  final Future<T?> Function(String texto)? onCadastrar;

  /// Quando informado, `itens` já vem filtrado pelo servidor: não refiltra.
  final ValueChanged<String>? onBuscaChanged;

  const SeletorTelaCheia({
    super.key,
    required this.titulo,
    required this.itens,
    required this.itemLabel,
    this.subtitulo,
    this.itemKey,
    this.modo = SeletorGenericoModo.multipla,
    this.selecionadosIniciais = const [],
    this.jaUsados = const [],
    this.nomeSingular,
    this.nomePlural,
    this.feminino = true,
    this.hintText = 'Buscar',
    this.onCadastrar,
    this.onBuscaChanged,
  });

  static Future<List<T>?> abrir<T>(
    BuildContext context,
    SeletorTelaCheia<T> seletor,
  ) =>
      Navigator.of(context).push<List<T>>(
        MaterialPageRoute(fullscreenDialog: true, builder: (_) => seletor),
      );

  @override
  State<SeletorTelaCheia<T>> createState() => _SeletorTelaCheiaState<T>();
}

class _SeletorTelaCheiaState<T> extends State<SeletorTelaCheia<T>> {
  final _busca = TextEditingController();
  late final List<T> _selecionados = [...widget.selecionadosIniciais];
  final _criados = <T>[];

  bool get _multipla => widget.modo == SeletorGenericoModo.multipla;

  Object? _chave(T i) => widget.itemKey?.call(i) ?? widget.itemLabel(i);
  bool _marcado(T i) => _selecionados.any((s) => _chave(s) == _chave(i));

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  List<T> get _todos => [
        ...widget.itens,
        ..._criados
            .where((c) => !widget.itens.any((i) => _chave(i) == _chave(c))),
      ];

  void _alternar(T item) {
    if (!_multipla) return Navigator.of(context).pop([item]);
    setState(() {
      _marcado(item)
          ? _selecionados.removeWhere((s) => _chave(s) == _chave(item))
          : _selecionados.add(item);
    });
  }

  Future<void> _cadastrar(String texto) async {
    final novo = await widget.onCadastrar!(texto);
    if (novo == null || !mounted) return;
    _criados.add(novo);
    _busca.clear();
    _alternar(novo);
  }

  String _plural(int n) => n == 1
      ? (widget.nomeSingular ?? '').toUpperCase()
      : (widget.nomePlural ?? '').toUpperCase();

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final texto = _busca.text.trim();
    final nBusca = normalizarBusca(texto);
    bool casa(T i) =>
        widget.onBuscaChanged != null ||
        normalizarBusca(widget.itemLabel(i)).contains(nBusca);
    final todos = _todos;
    final usadas = widget.jaUsados.where(casa).toList();
    final restantes = todos
        .where((i) =>
            !widget.jaUsados.any((u) => _chave(u) == _chave(i)) && casa(i))
        .toList()
      ..sort((a, b) => normalizarBusca(widget.itemLabel(a))
          .compareTo(normalizarBusca(widget.itemLabel(b))));
    final podeCadastrar = widget.onCadastrar != null &&
        nBusca.isNotEmpty &&
        !todos.any((i) => normalizarBusca(widget.itemLabel(i)) == nBusca);
    final n = _selecionados.length;

    Widget cabecalho(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child:
              Text(t, style: textos.rotulo.copyWith(color: cores.textoApoio)),
        );

    Widget linha(T item) {
      final marcado = _marcado(item);
      return InkWell(
        key: Key('sel_item_${_chave(item)}'),
        onTap: () => _alternar(item),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: marcado ? cores.selecaoFundo : null,
          child: Row(
            children: [
              if (_multipla) ...[
                Icon(
                  marcado ? Icons.check_box : Icons.check_box_outline_blank,
                  color: marcado ? cores.aco : cores.textoDesabilitado,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(widget.itemLabel(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textos.corpo),
              ),
              if (!_multipla && marcado) Icon(Icons.check, color: cores.aco),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cores.superficie,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.only(left: 4, right: 16),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('sel_voltar'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.titulo, maxLines: 1, style: textos.secao),
                        if (widget.subtitulo != null)
                          Text(widget.subtitulo!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textos.apoio),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                key: const Key('sel_busca'),
                controller: _busca,
                autofocus: true,
                onChanged: (t) {
                  setState(() {});
                  widget.onBuscaChanged?.call(t);
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: texto.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _busca.clear();
                            widget.onBuscaChanged?.call('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            if (_multipla && _selecionados.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 96),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      children: [
                        for (final s in _selecionados)
                          InputChip(
                            key: Key('sel_chip_${_chave(s)}'),
                            label: Text(widget.itemLabel(s)),
                            onDeleted: () => _alternar(s),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                key: const Key('sel_lista'),
                padding: EdgeInsets.zero,
                children: [
                  if (podeCadastrar)
                    InkWell(
                      key: const Key('sel_cadastrar'),
                      onTap: () => _cadastrar(texto),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.add, color: cores.acoEscuro),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cadastrar “$texto”'
                                '${widget.nomeSingular == null ? '' : ' como ${widget.feminino ? 'nova' : 'novo'} ${widget.nomeSingular}'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textos.corpo
                                    .copyWith(color: cores.acoEscuro),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (usadas.isNotEmpty) ...[
                    cabecalho('JÁ USADAS NESTA REFERÊNCIA'),
                    ...usadas.map(linha),
                  ],
                  if (widget.nomePlural != null && restantes.isNotEmpty)
                    cabecalho(
                        '${widget.feminino ? 'TODAS AS' : 'TODOS OS'} ${widget.nomePlural!.toUpperCase()}'),
                  ...restantes.map(linha),
                ],
              ),
            ),
            if (_multipla)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: cores.hairline)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    key: const Key('sel_confirmar'),
                    onPressed: () => Navigator.of(context).pop(_selecionados),
                    child: Text(widget.nomePlural == null
                        ? 'CONFIRMAR · $n'
                        : 'CONFIRMAR · $n ${_plural(n)}'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
