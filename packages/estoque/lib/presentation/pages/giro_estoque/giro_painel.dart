import 'package:core/tema.dart';
import 'package:estoque/domain/models/parametros_giro.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_formatacao.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_widgets.dart';
import 'package:flutter/material.dart';

Widget _rotulo(BuildContext context, String t, {Color? cor}) => Text(
      t,
      style: context.sivTextos.rotulo.copyWith(
        fontSize: 10.5,
        letterSpacing: 1.4,
        color: cor ?? giroTinta.withValues(alpha: .6),
      ),
    );

double _share(GiroEstoqueResumo r, ClassificacaoGiro c) =>
    r.analisados == 0 ? 0 : (r.contagens[c] ?? 0) / r.analisados * 100;

/// Painel de classificação (desktop): clicar numa faixa filtra a aba ranking.
class GiroPainelClassificacao extends StatelessWidget {
  final GiroEstoqueResumo resumo;
  final Set<ClassificacaoGiro> selecionadas;
  final ValueChanged<ClassificacaoGiro> onFaixa;
  final VoidCallback onCriterios;
  const GiroPainelClassificacao({
    super.key,
    required this.resumo,
    required this.selecionadas,
    required this.onFaixa,
    required this.onCriterios,
  });

  @override
  Widget build(BuildContext context) {
    const divisor = BoxDecoration(border: Border(left: BorderSide(color: giroLinhaFina)));
    Widget media(String rotulo, String valor, String unidade) => Container(
          decoration: divisor,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _rotulo(context, rotulo),
            const SizedBox(height: 4),
            Text.rich(TextSpan(children: [
              TextSpan(text: valor),
              TextSpan(
                text: unidade,
                style: giroNumero(context, 16, cor: giroTinta.withValues(alpha: .5)),
              ),
            ]), style: giroNumero(context, 30)),
          ]),
        );
    return GiroPainel(
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            flex: 125,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _rotulo(context, 'ANALISADOS', cor: const Color(0xFF31485A)),
                  InkWell(
                    onTap: onCriterios,
                    child: Text('Critérios',
                        style: giroCorpo(context, 11.5, cor: const Color(0xFF416180))
                            .copyWith(decoration: TextDecoration.underline)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(fmtN(resumo.analisados), style: giroNumero(context, 30)),
                if (resumo.semHistorico > 0)
                  Text('+ ${fmtN(resumo.semHistorico)} sem histórico de entrada suficiente',
                      style: giroCorpo(context, 11.5, cor: giroApoio)),
              ]),
            ),
          ),
          for (final c in faixasGiro)
            Expanded(
              flex: 100,
              child: InkWell(
                key: ValueKey('faixa_${c.api}'),
                onTap: () => onFaixa(c),
                child: Container(
                  decoration: divisor.copyWith(
                    color: selecionadas.contains(c) ? giroDestaque : null,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(height: 3, color: estilosGiro[c]!.barra),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _rotulo(context, c.label.toUpperCase()),
                      const SizedBox(height: 4),
                      Text(fmtN(resumo.contagens[c] ?? 0), style: giroNumero(context, 30)),
                      Text('${fmtPct(_share(resumo, c), 1)} dos produtos',
                          style: giroCorpo(context, 11.5, cor: giroApoio)),
                    ]),
                  ),
                  ]),
                ),
              ),
            ),
          Expanded(
            flex: 100,
            child: media('MÉDIA P/ GIRO',
                resumo.mediaDiasGiro == null ? '—' : fmtN(resumo.mediaDiasGiro!, 1),
                resumo.mediaDiasGiro == null ? '' : ' dias'),
          ),
          Expanded(
            flex: 100,
            child: media('% MÉDIO VENDIDO',
                resumo.mediaPctVendido == null ? '—' : fmtN(resumo.mediaPctVendido!, 1),
                resumo.mediaPctVendido == null ? '' : '%'),
          ),
        ]),
      ),
    );
  }
}

/// "Critérios": frases geradas a partir dos parâmetros devolvidos pelo backend.
class GiroCriterios extends StatelessWidget {
  final ParametrosGiro p;
  const GiroCriterios(this.p, {super.key});

  @override
  Widget build(BuildContext context) {
    final frases = {
      ClassificacaoGiro.excepcional:
          '≥ ${fmtN(p.excepcionalPctMin)}% do lote vendido em até ${fmtN(p.excepcionalDiasMax)} dias',
      ClassificacaoGiro.rapido:
          '≥ ${fmtN(p.rapidoPctMin)}% do lote vendido em até ${fmtN(p.rapidoDiasMax)} dias',
      ClassificacaoGiro.normal: 'Venda consistente que não se encaixa nas outras faixas',
      ClassificacaoGiro.lento:
          '${fmtN(p.lentoDiasMin)}+ dias em estoque com menos de ${fmtN(p.lentoPctMax)}% vendido',
      ClassificacaoGiro.parado:
          '${fmtN(p.paradoDiasMin)}+ dias em estoque com até ${fmtN(p.paradoPctMax)}% vendido',
      ClassificacaoGiro.semHistorico:
          'Entrada não identificada: fica fora das métricas de velocidade',
    };
    final estilo = giroCorpo(context, 13, cor: giroTinta.withValues(alpha: .8));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: giroLinha)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 32, runSpacing: 14, children: [
          for (final e in frases.entries)
            SizedBox(
              width: 340,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GiroTag(e.key),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value, style: estilo)),
              ]),
            ),
        ]),
        const Divider(height: 28, color: giroLinhaFina),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Ordem do ranking: ', style: TextStyle(fontWeight: FontWeight.w700)),
            const TextSpan(
              text: '% do lote vendido × 1/√dias × ln(1 + unidades vendidas), o que favorece lote quase esgotado em poucos dias com volume relevante. Não ordena só por quantidade. ',
            ),
            const TextSpan(text: 'Lotes: ', style: TextStyle(fontWeight: FontWeight.w700)),
            const TextSpan(
              text: 'vendas abatidas por FIFO, e cada linha é o lote mais antigo ainda com saldo. Cancelamentos, devoluções, trocas, transferências e ajustes não contam como venda.',
            ),
          ]),
          style: estilo.copyWith(color: giroTinta.withValues(alpha: .7)),
        ),
      ]),
    );
  }
}

/// Top 10: único gráfico da tela (barras horizontais).
class GiroTop10 extends StatelessWidget {
  final List<GiroEstoqueTop> top;
  const GiroTop10(this.top, {super.key});

  @override
  Widget build(BuildContext context) => GiroPainel(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Produtos com maior giro', style: context.sivTextos.secao.copyWith(fontSize: 18)),
            Text('Top 10 · % do lote vendido e dias',
                style: giroCorpo(context, 11.5, cor: giroApoio)),
          ]),
          const SizedBox(height: 14),
          for (final t in top)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: GiroGrade(colunas: [
                (22, Text('${t.rank}', textAlign: TextAlign.right,
                    style: giroNumero(context, 14, cor: giroApoio))),
                (210, Text(t.nome, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: giroCorpo(context, 13))),
                (null, GiroBarra(pct: t.pctVendido, cor: estilosGiro[t.classificacao]!.barra, altura: 10)),
                (128, Text('${fmtPct(t.pctVendido, 1)} em ${diasT(t.diasGiro)}',
                    style: giroCorpo(context, 13))),
                (74, Text('${fmtUnDia(t.velocidade, 1)} un/dia', textAlign: TextAlign.right,
                    style: giroCorpo(context, 12, cor: giroTinta.withValues(alpha: .6)))),
              ]),
            ),
        ]),
      );
}

/// Painel financeiro (desktop).
class GiroFinanceiro extends StatelessWidget {
  final GiroEstoqueResumo r;
  const GiroFinanceiro(this.r, {super.key});

  Widget _item(BuildContext context, String titulo, String formula, double v,
      {Color? cor, bool ultimo = false}) =>
      Container(
        padding: EdgeInsets.fromLTRB(0, 11, 0, ultimo ? 0 : 11),
        decoration: BoxDecoration(
          border: ultimo ? null : const Border(bottom: BorderSide(color: giroLinhaFina)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: giroCorpo(context, 13, cor: cor)),
              Text(formula, style: giroCorpo(context, 11, cor: giroTinta.withValues(alpha: .5))),
            ]),
            Text(fmtMoeda(v), style: giroNumero(context, 22, cor: cor)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final imob = r.pctImobilizado.clamp(0, 100).toDouble();
    return GiroPainel(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Valor financeiro', style: context.sivTextos.secao.copyWith(fontSize: 18)),
          Text('Lotes analisados', style: giroCorpo(context, 11.5, cor: giroApoio)),
        ]),
        const SizedBox(height: 14),
        _item(context, 'Valor vendido', 'vendidas × preço de venda', r.valorVendido),
        _item(context, 'Valor em estoque', 'estoque × custo', r.valorEstoque),
        _item(context, 'Potencial de faturamento', 'estoque × preço de venda', r.potencial),
        _item(context, 'Imobilizado em lento + parado',
            '${fmtPct(r.pctImobilizado, 0)} do valor em estoque', r.valorImobilizadoLentoParado,
            cor: giroErro, ultimo: true),
        const SizedBox(height: 14),
        SizedBox(
          height: 6,
          child: Row(children: [
            if (imob < 100)
              Expanded(flex: (100 - imob).round(), child: Container(color: const Color(0xFF9DB4CA))),
            if (imob.round() > 0)
              Expanded(flex: imob.round(), child: Container(color: giroErro)),
          ]),
        ),
      ]),
    );
  }
}
