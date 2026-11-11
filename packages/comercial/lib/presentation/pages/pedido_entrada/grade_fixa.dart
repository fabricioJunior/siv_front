import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Grade cor × tamanho com cabeçalho de tamanhos e coluna de cores fixos:
/// dois controllers espelham a rolagem do corpo (horizontal -> cabeçalho,
/// vertical -> coluna de cores). Células 58×48, coluna de cores 88px.
class GradeFixa extends StatefulWidget {
  static const larguraCelula = 62.0;
  static const alturaLinha = 52.0;
  static const larguraCores = 92.0;
  static const alturaCabecalho = 30.0;

  final List<String> cores;
  final List<String> tamanhos;

  /// Subtotal por cor (ex.: "12 pç").
  final List<String> subtotais;
  final int? linhaFoco;
  final int? colunaFoco;
  final Widget Function(int linha, int coluna) celula;

  /// Altura máxima do corpo; acima disso a grade rola na vertical.
  final double alturaMax;

  const GradeFixa({
    super.key,
    required this.cores,
    required this.tamanhos,
    required this.subtotais,
    required this.celula,
    this.linhaFoco,
    this.colunaFoco,
    this.alturaMax = 360,
  });

  @override
  State<GradeFixa> createState() => _GradeFixaState();
}

class _GradeFixaState extends State<GradeFixa> {
  final _hCabecalho = ScrollController();
  final _hCorpo = ScrollController();
  final _vCores = ScrollController();
  final _vCorpo = ScrollController();

  @override
  void initState() {
    super.initState();
    _hCorpo.addListener(() => _espelhar(_hCorpo, _hCabecalho));
    _vCorpo.addListener(() => _espelhar(_vCorpo, _vCores));
  }

  void _espelhar(ScrollController de, ScrollController para) {
    if (!de.hasClients || !para.hasClients) return;
    final o = de.offset.clamp(0.0, para.position.maxScrollExtent);
    if (para.offset != o) para.jumpTo(o);
  }

  @override
  void dispose() {
    _hCabecalho.dispose();
    _hCorpo.dispose();
    _vCores.dispose();
    _vCorpo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final w = widget;
    final alturaCorpo =
        (w.cores.length * GradeFixa.alturaLinha).clamp(0.0, w.alturaMax);
    const nada = NeverScrollableScrollPhysics();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          key: const Key('grade_cabecalho'),
          height: GradeFixa.alturaCabecalho,
          child: Row(
            children: [
              SizedBox(
                width: GradeFixa.larguraCores,
                child: Text('COR \\ TAM',
                    style: textos.rotulo
                        .copyWith(fontSize: 10.5, color: cores.textoApoio)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _hCabecalho,
                  physics: nada,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var c = 0; c < w.tamanhos.length; c++)
                        _cabecalho(
                            w.tamanhos[c], c == w.colunaFoco, cores, textos),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: alturaCorpo,
          child: Row(
            children: [
              SizedBox(
                key: const Key('grade_coluna_cores'),
                width: GradeFixa.larguraCores,
                child: SingleChildScrollView(
                  controller: _vCores,
                  physics: nada,
                  child: Column(
                    children: [
                      for (var l = 0; l < w.cores.length; l++)
                        _nome(l, l == w.linhaFoco, cores, textos),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _hCorpo,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: w.tamanhos.length * GradeFixa.larguraCelula,
                    child: SingleChildScrollView(
                      controller: _vCorpo,
                      child: Column(
                        children: [
                          for (var l = 0; l < w.cores.length; l++)
                            Row(
                              children: [
                                for (var c = 0; c < w.tamanhos.length; c++)
                                  SizedBox(
                                    width: GradeFixa.larguraCelula,
                                    height: GradeFixa.alturaLinha,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: w.celula(l, c),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cabecalho(
      String t, bool foco, SivColors cores, SivTextStyles textos) {
    return Container(
      width: 58,
      height: 26,
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: foco ? cores.acoEscuro : null,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(t,
          maxLines: 1,
          style: textos.secao
              .copyWith(fontSize: 15, color: foco ? cores.superficie : null)),
    );
  }

  Widget _nome(int l, bool foco, SivColors cores, SivTextStyles textos) {
    return Container(
      width: 88,
      height: 48,
      margin: const EdgeInsets.fromLTRB(0, 2, 4, 2),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: foco ? cores.acoEscuro : cores.superficie,
        border: foco ? null : Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.cores[l],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textos.corpo.copyWith(
                fontSize: 13.5,
                height: 1.1,
                fontWeight: FontWeight.w600,
                color: foco ? cores.superficie : null,
              )),
          Text(widget.subtotais[l],
              maxLines: 1,
              style: textos.apoio.copyWith(
                fontSize: 11,
                height: 1.1,
                color: foco
                    ? cores.superficie.withValues(alpha: 0.7)
                    : cores.textoApoio,
              )),
        ],
      ),
    );
  }
}
