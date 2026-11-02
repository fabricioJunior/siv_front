import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Seletor de tamanhos em tela cheia (7b): blocos de 52px, sem teclado, em
/// NUMÉRICOS e LETRAS, com MARCAR FAIXA. Devolve os ids marcados (voltar = null).
class TamanhosTelaCheia extends StatefulWidget {
  final String? subtitulo;
  final List<TamanhoOpcao> opcoes;
  final Set<int> selecionados;

  const TamanhosTelaCheia({
    super.key,
    required this.opcoes,
    required this.selecionados,
    this.subtitulo,
  });

  static Future<Set<int>?> abrir(
          BuildContext context, TamanhosTelaCheia tela) =>
      Navigator.of(context).push<Set<int>>(
        MaterialPageRoute(fullscreenDialog: true, builder: (_) => tela),
      );

  @override
  State<TamanhosTelaCheia> createState() => _TamanhosTelaCheiaState();
}

class _TamanhosTelaCheiaState extends State<TamanhosTelaCheia> {
  late final _sel = {...widget.selecionados};
  late final _numericos = _ordenados(true);
  late final _letras = _ordenados(false);
  bool _faixa = false;
  TamanhoOpcao? _inicio;

  List<TamanhoOpcao> _ordenados(bool numerico) =>
      widget.opcoes.where((t) => t.numerico == numerico).toList()
        ..sort((a, b) => compararTamanhos(a.nome, b.nome));

  void _tocar(TamanhoOpcao t, List<TamanhoOpcao> grupo) => setState(() {
        if (!_faixa) {
          _sel.contains(t.id) ? _sel.remove(t.id) : _sel.add(t.id);
        } else if (_inicio == null || !grupo.contains(_inicio)) {
          _inicio = t;
        } else {
          final a = grupo.indexOf(_inicio!), b = grupo.indexOf(t);
          _sel.addAll(grupo
              .sublist(a < b ? a : b, (a < b ? b : a) + 1)
              .map((e) => e.id));
          _faixa = false;
          _inicio = null;
        }
      });

  Widget _grupo(String rotulo, List<TamanhoOpcao> grupo, SivColors cores,
      SivTextStyles textos) {
    if (grupo.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: textos.rotulo.copyWith(color: cores.textoApoio)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.5,
            children: [
              for (final t in grupo) _bloco(t, grupo, cores, textos),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bloco(TamanhoOpcao t, List<TamanhoOpcao> grupo, SivColors cores,
      SivTextStyles textos) {
    final marcado = _sel.contains(t.id);
    final ini = _faixa && _inicio?.id == t.id;
    final fundo =
        ini ? cores.acoEscuro : (marcado ? cores.aco : cores.superficie);
    return InkWell(
      key: Key('tam_${t.id}'),
      onTap: () => _tocar(t, grupo),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          border: Border.all(color: ini || marcado ? fundo : cores.hairline),
        ),
        child: Text(t.nome,
            style: textos.secao
                .copyWith(color: ini || marcado ? Colors.white : null)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final rotuloFaixa = !_faixa
        ? 'MARCAR FAIXA'
        : _inicio == null
            ? 'Toque no primeiro tamanho da faixa'
            : 'Agora toque no último (início: ${_inicio!.nome})';
    return Scaffold(
      backgroundColor: cores.superficie,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  IconButton(
                    key: const Key('tam_voltar'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tamanhos', style: textos.secao),
                        if (widget.subtitulo != null)
                          Text(widget.subtitulo!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textos.apoio),
                      ],
                    ),
                  ),
                  TextButton(
                    key: const Key('tam_limpar'),
                    onPressed: () => setState(_sel.clear),
                    child: const Text('Limpar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  OutlinedButton.icon(
                    key: const Key('tam_faixa'),
                    onPressed: () => setState(() {
                      _faixa = !_faixa;
                      _inicio = null;
                    }),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: _faixa ? cores.acoEscuro : null,
                      foregroundColor: _faixa ? Colors.white : cores.acoEscuro,
                    ),
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(rotuloFaixa),
                  ),
                  const SizedBox(height: 18),
                  _grupo('NUMÉRICOS', _numericos, cores, textos),
                  _grupo('LETRAS', _letras, cores, textos),
                  Text(
                    'Só os tamanhos marcados viram colunas na grade.',
                    style: textos.apoio,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cores.hairline)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  key: const Key('tam_confirmar'),
                  onPressed: () => Navigator.of(context).pop(_sel),
                  child: Text('CONFIRMAR · ${_sel.length} TAMANHOS'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
