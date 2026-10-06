import 'package:core/tema.dart';
import 'package:estoque/domain/models/parametros_giro.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_formatacao.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_widgets.dart';
import 'package:flutter/material.dart';

class _Col {
  final String rotulo;
  final String? chave; // valor de `ordenarPor`; null = não ordena
  final double? largura;
  final bool direita;
  const _Col(this.rotulo, this.chave, this.largura, {this.direita = false});
}

const _colRanking = [
  _Col('#', 'score', 28),
  _Col('Produto', 'nome', null),
  _Col('Entrada', 'dataEntrada', 62),
  _Col('Inicial', 'inicial', 56, direita: true),
  _Col('Vendido', 'vendido', 62, direita: true),
  _Col('% vendido', 'pctVendido', 136),
  _Col('Estoque', 'estoque', 60, direita: true),
  _Col('Dias', 'diasGiro', 44, direita: true),
  _Col('Un./dia', 'velocidade', 60, direita: true),
  _Col('Previsão', 'diasParaEsgotar', 78, direita: true),
  _Col('Classificação', 'classificacao', 112),
  _Col('', null, 18),
];
const _colReposicao = [
  _Col('Produto', 'nome', null),
  _Col('Estoque', 'estoque', 84, direita: true),
  _Col('Un./dia', 'velocidade', 84, direita: true),
  _Col('Esgota em', 'diasParaEsgotar', 100, direita: true),
  _Col('Última entrada', 'dataEntrada', 120, direita: true),
  _Col('Vendido', 'vendido', 84, direita: true),
  _Col('Giro', 'classificacao', 112),
  _Col('Sugestão', 'sugestao', 160, direita: true),
];
const _colParado = [
  _Col('Produto', 'nome', null),
  _Col('Entrada', 'dataEntrada', 84),
  _Col('Dias em estoque', null, 110, direita: true),
  _Col('Inicial', 'inicial', 70, direita: true),
  _Col('Vendido', 'vendido', 70, direita: true),
  _Col('Estoque', 'estoque', 70, direita: true),
  _Col('% vendido', 'pctVendido', 130),
  _Col('Giro', 'classificacao', 112),
  _Col('Valor parado', 'valorParado', 130, direita: true),
];

/// Tabela desktop das três abas, com ordenação no backend, expansão de
/// variações (aba ranking, visão produto) e paginador.
class GiroTabela extends StatelessWidget {
  final AbaGiro aba;
  final bool visaoVariacao;
  final PaginaGiroEstoque pagina;
  final String ordenarPor;
  final String ordem;
  final Map<int, GiroEstoqueVariacoes> variacoes;
  final Set<int> abertos;
  final Set<int> carregandoVariacoes;
  final ParametrosGiro parametros;
  final ValueChanged<String> onOrdenar;
  final ValueChanged<int> onExpandir;
  final ValueChanged<int> onPagina;

  const GiroTabela({
    super.key,
    required this.aba,
    required this.visaoVariacao,
    required this.pagina,
    required this.ordenarPor,
    required this.ordem,
    required this.variacoes,
    required this.abertos,
    required this.carregandoVariacoes,
    required this.parametros,
    required this.onOrdenar,
    required this.onExpandir,
    required this.onPagina,
  });

  List<_Col> get _colunas => switch (aba) {
        AbaGiro.ranking => _colRanking,
        AbaGiro.reposicao => _colReposicao,
        AbaGiro.parado => _colParado,
      };

  @override
  Widget build(BuildContext context) {
    final meta = pagina.meta;
    final unidade = visaoVariacao ? 'variações' : 'produtos';
    return GiroPainel(
      child: Column(children: [
        if (aba == AbaGiro.reposicao) _FaixaReposicao(parametros),
        _Cabecalho(
          colunas: _colunas,
          ordenarPor: ordenarPor,
          ordem: ordem,
          onOrdenar: onOrdenar,
        ),
        for (final l in pagina.items) _linha(context, l),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(children: [
            Expanded(
              child: Text(
                '${fmtN(meta.totalItems)} $unidade · página ${meta.currentPage} de ${meta.totalPages}',
                style: giroCorpo(context, 12.5, cor: giroApoio),
              ),
            ),
            _Paginador(
              atual: meta.currentPage,
              total: meta.totalPages,
              onPagina: onPagina,
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _linha(BuildContext context, GiroEstoqueLinha l) => switch (aba) {
        AbaGiro.ranking => _LinhaRanking(
            linha: l,
            expansivel: !visaoVariacao && l.temVariacoes && !l.semHistorico,
            aberta: abertos.contains(l.referenciaId),
            carregando: carregandoVariacoes.contains(l.referenciaId),
            variacoes: variacoes[l.referenciaId],
            onTap: () => onExpandir(l.referenciaId),
          ),
        AbaGiro.reposicao => _LinhaReposicao(l),
        AbaGiro.parado => _LinhaParado(l),
      };
}

class _Cabecalho extends StatelessWidget {
  final List<_Col> colunas;
  final String ordenarPor;
  final String ordem;
  final ValueChanged<String> onOrdenar;
  const _Cabecalho({
    required this.colunas,
    required this.ordenarPor,
    required this.ordem,
    required this.onOrdenar,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: giroLinha)),
        ),
        child: GiroGrade(
          gap: 12,
          colunas: [
            for (final c in colunas)
              (
                c.largura,
                InkWell(
                  onTap: c.chave == null ? null : () => onOrdenar(c.chave!),
                  child: Row(
                    mainAxisAlignment: c.direita
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          c.rotulo.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: context.sivTextos.rotulo.copyWith(
                            fontSize: 11.5,
                            color: c.chave == ordenarPor
                                ? giroAcentoEscuro
                                : giroApoio,
                          ),
                        ),
                      ),
                      if (c.chave != null && c.chave == ordenarPor)
                        Icon(
                          ordem == 'desc'
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 14,
                          color: giroAcento,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}

Widget _produtoCelula(BuildContext context, GiroEstoqueLinha l) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: giroCorpo(context, 13.5, peso: FontWeight.w600),
        ),
        Text(
          subtituloLinha(l),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: giroCorpo(context, 11.5, cor: giroApoio),
        ),
      ],
    );

Widget _num(BuildContext context, String t, {Color? cor, FontWeight? peso}) =>
    Text(
      t,
      textAlign: TextAlign.right,
      style: giroCorpo(context, 13.5, cor: cor, peso: peso),
    );

Widget _pctBarra(BuildContext context, GiroEstoqueLinha l, {int casas = 2}) {
  final e = estilosGiro[l.classificacao]!;
  return Row(children: [
    Expanded(child: GiroBarra(pct: l.pctVendido, cor: e.barra)),
    const SizedBox(width: 8),
    SizedBox(
      width: 52,
      child: _num(context, fmtPct(l.pctVendido, casas)),
    ),
  ]);
}

class _LinhaRanking extends StatelessWidget {
  final GiroEstoqueLinha linha;
  final bool expansivel;
  final bool aberta;
  final bool carregando;
  final GiroEstoqueVariacoes? variacoes;
  final VoidCallback onTap;
  const _LinhaRanking({
    required this.linha,
    required this.expansivel,
    required this.aberta,
    required this.carregando,
    required this.variacoes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = linha;
    final vermelho = l.diasParaEsgotar == 0 && !l.semHistorico;
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: giroLinhaFina)),
      ),
      child: Column(children: [
        InkWell(
          onTap: expansivel ? onTap : null,
          child: Container(
            color: aberta ? giroDestaque : null,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            child: GiroGrade(colunas: [
              (
                28,
                Text(l.rank?.toString() ?? '',
                    style: giroNumero(context, 15, cor: giroApoio)),
              ),
              (null, _produtoCelula(context, l)),
              (
                62,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(fmtDia(l.dataEntrada), style: giroCorpo(context, 13.5)),
                    if (l.loteOrdem > 1)
                      Text(ordinalLote(l.loteOrdem),
                          style: giroCorpo(context, 10.5, cor: const Color(0xFF416180))),
                  ],
                ),
              ),
              (56, _num(context, l.inicial?.toString() ?? '—')),
              (62, _num(context, '${l.vendido}')),
              (136, _pctBarra(context, l)),
              (60, _num(context, '${l.estoque}')),
              (44, _num(context, l.diasGiro?.toString() ?? '—')),
              (60, _num(context, fmtUnDia(l.velocidade))),
              (
                78,
                _num(context, previsaoT(l), cor: vermelho ? giroErro : null),
              ),
              (112, Align(alignment: Alignment.centerLeft, child: GiroTag(l.classificacao))),
              (
                18,
                expansivel
                    ? AnimatedRotation(
                        turns: aberta ? .5 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(Icons.keyboard_arrow_down,
                            size: 16, color: giroTinta.withValues(alpha: .5)),
                      )
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
        ),
        if (aberta) _Variacoes(linha: l, carregando: carregando, dados: variacoes),
      ]),
    );
  }
}

class _Variacoes extends StatelessWidget {
  final GiroEstoqueLinha linha;
  final bool carregando;
  final GiroEstoqueVariacoes? dados;
  const _Variacoes({required this.linha, required this.carregando, required this.dados});

  static const _cols = [
    ('Variação', null, false),
    ('Inicial', 56.0, true),
    ('Vendido', 62.0, true),
    ('% vendido', 170.0, false),
    ('Estoque', 60.0, true),
    ('Dias', 44.0, true),
    ('Un./dia', 60.0, true),
    ('Classificação', 112.0, false),
  ];

  String _destaque(String rotulo, GiroVariacaoDestaque? d) => d == null
      ? ''
      : '$rotulo: ${d.variacaoLabel} · ${fmtPct(d.pctVendido, 1)} em ${diasT(d.diasGiro)}';

  @override
  Widget build(BuildContext context) {
    final d = dados;
    final obs = linha.loteOrdem > 1
        ? (linha.loteAnteriorEsgotadoEm != null
            ? '${ordinalLote(linha.loteOrdem - 1)} esgotou em ${fmtDia(linha.loteAnteriorEsgotadoEm)} · FIFO abatendo do ${ordinalLote(linha.loteOrdem)}'
            : 'Lote vigente: ${ordinalLote(linha.loteOrdem)}')
        : (linha.estoque == 0 ? 'Lote esgotado' : '');
    return Container(
      color: const Color(0xFFF7F8F9),
      padding: const EdgeInsets.fromLTRB(62, 6, 22, 16),
      child: carregando || d == null
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(minHeight: 2),
            )
          : Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      [_destaque('Melhor', d.melhor), _destaque('Pior', d.pior)]
                          .where((e) => e.isNotEmpty)
                          .join('   —   '),
                      style: giroCorpo(context, 12.5, cor: giroTinta.withValues(alpha: .75)),
                    ),
                  ),
                  Text(obs, style: giroCorpo(context, 12.5, cor: giroApoio)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: giroLinha)),
                ),
                child: GiroGrade(colunas: [
                  for (final c in _cols)
                    (
                      c.$2,
                      Text(
                        c.$1.toUpperCase(),
                        textAlign: c.$3 ? TextAlign.right : TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.sivTextos.rotulo.copyWith(
                          fontSize: 11,
                          color: giroTinta.withValues(alpha: .5),
                        ),
                      ),
                    ),
                ]),
              ),
              for (final v in d.items)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: giroLinhaFina)),
                  ),
                  child: GiroGrade(colunas: [
                    (null, Text(v.variacaoLabel ?? v.nome, style: giroCorpo(context, 13))),
                    (56, _num(context, v.inicial?.toString() ?? '—')),
                    (62, _num(context, '${v.vendido}')),
                    (170, _pctBarra(context, v)),
                    (60, _num(context, '${v.estoque}')),
                    (44, _num(context, v.diasGiro?.toString() ?? '—')),
                    (60, _num(context, fmtUnDia(v.velocidade))),
                    (112, Align(alignment: Alignment.centerLeft, child: GiroTag(v.classificacao))),
                  ]),
                ),
            ]),
    );
  }
}

class _FaixaReposicao extends StatelessWidget {
  final ParametrosGiro p;
  const _FaixaReposicao(this.p);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: const BoxDecoration(
          color: giroDestaque,
          border: Border(bottom: BorderSide(color: giroLinhaFina)),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 15, color: giroAcentoEscuro),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Recomendação, não pedido de compra. Giro excepcional ou rápido com esgotamento previsto em até ${fmtN(p.reposicaoEsgotaEmAte)} dias. '
              'Sugestão = ${fmtN(p.reposicaoCoberturaDias)} dias de cobertura, limitada a ${fmtN(p.reposicaoLimiteLotes)}× o lote.',
              style: giroCorpo(context, 12.5, cor: giroAcentoEscuro),
            ),
          ),
        ]),
      );
}

class _LinhaReposicao extends StatelessWidget {
  final GiroEstoqueLinha l;
  const _LinhaReposicao(this.l);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: giroLinhaFina)),
        ),
        child: GiroGrade(gap: 14, colunas: [
          (null, _produtoCelula(context, l)),
          (
            84,
            _num(context, '${l.estoque}',
                cor: l.estoque == 0 ? giroErro : null, peso: FontWeight.w600),
          ),
          (84, _num(context, fmtUnDia(l.velocidade))),
          (
            100,
            _num(context, previsaoT(l),
                cor: l.diasParaEsgotar == 0 ? giroErro : null),
          ),
          (120, _num(context, fmtDia(l.dataEntrada))),
          (84, _num(context, '${l.vendido}')),
          (112, Align(alignment: Alignment.centerLeft, child: GiroTag(l.classificacao))),
          (
            160,
            Text(
              l.sugestaoReposicao == null ? '—' : 'Repor ${l.sugestaoReposicao} un.',
              textAlign: TextAlign.right,
              style: giroNumero(context, 17, cor: giroAcentoEscuro),
            ),
          ),
        ]),
      );
}

class _LinhaParado extends StatelessWidget {
  final GiroEstoqueLinha l;
  const _LinhaParado(this.l);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: giroLinhaFina)),
        ),
        child: GiroGrade(gap: 14, colunas: [
          (null, _produtoCelula(context, l)),
          (84, Text(fmtDia(l.dataEntrada), style: giroCorpo(context, 13.5))),
          (110, _num(context, '${l.diasEmEstoque}')),
          (70, _num(context, l.inicial?.toString() ?? '—')),
          (70, _num(context, '${l.vendido}')),
          (70, _num(context, '${l.estoque}')),
          (130, _pctBarra(context, l, casas: 1)),
          (112, Align(alignment: Alignment.centerLeft, child: GiroTag(l.classificacao))),
          (
            130,
            Text(
              fmtMoeda(l.valorParado),
              textAlign: TextAlign.right,
              style: giroNumero(context, 17, cor: giroErro),
            ),
          ),
        ]),
      );
}

class _Paginador extends StatelessWidget {
  final int atual;
  final int total;
  final ValueChanged<int> onPagina;
  const _Paginador({required this.atual, required this.total, required this.onPagina});

  /// null = reticências.
  static List<int?> paginas(int atual, int total) {
    final s = <int>{1, total, atual - 1, atual, atual + 1}
        .where((p) => p >= 1 && p <= total)
        .toList()
      ..sort();
    final r = <int?>[];
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && s[i] - s[i - 1] > 1) r.add(null);
      r.add(s[i]);
    }
    return r;
  }

  Widget _botao(BuildContext context, Widget child,
          {VoidCallback? onTap, bool ativo = false}) =>
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null && !ativo ? .45 : 1,
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ativo ? giroAcento : null,
                border: ativo ? null : Border.all(color: giroLinha),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: ativo ? Colors.white : giroTinta, fontSize: 12.5),
                child: child,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        _botao(context, const Icon(Icons.chevron_left, size: 15),
            onTap: atual > 1 ? () => onPagina(atual - 1) : null),
        for (final p in paginas(atual, total))
          p == null
              ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: SizedBox(width: 30, child: Center(child: Text('…', style: giroCorpo(context, 12.5)))),
                )
              : _botao(context, Text('$p'),
                  ativo: p == atual, onTap: p == atual ? null : () => onPagina(p)),
        _botao(context, const Icon(Icons.chevron_right, size: 15),
            onTap: atual < total ? () => onPagina(atual + 1) : null),
      ]);
}

/// Paginador compartilhado com a visão mobile.
Widget giroPaginador({
  required int atual,
  required int total,
  required ValueChanged<int> onPagina,
}) =>
    _Paginador(atual: atual, total: total, onPagina: onPagina);
