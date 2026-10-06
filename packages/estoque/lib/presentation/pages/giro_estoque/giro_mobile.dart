import 'package:core/tema.dart';
import 'package:estoque/domain/models/relatorio_giro_estoque.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_formatacao.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_tabela.dart';
import 'package:estoque/presentation/pages/giro_estoque/giro_widgets.dart';
import 'package:flutter/material.dart';

/// Painel mobile: barra empilhada + legenda (ambas filtram) e as médias.
class GiroPainelMobile extends StatelessWidget {
  final GiroEstoqueResumo resumo;
  final Set<ClassificacaoGiro> selecionadas;
  final ValueChanged<ClassificacaoGiro> onFaixa;
  const GiroPainelMobile({
    super.key,
    required this.resumo,
    required this.selecionadas,
    required this.onFaixa,
  });

  @override
  Widget build(BuildContext context) {
    final com = faixasGiro.where((c) => (resumo.contagens[c] ?? 0) > 0).toList();
    return GiroPainel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${fmtN(resumo.analisados)} PRODUTOS ANALISADOS',
              style: context.sivTextos.rotulo.copyWith(
                  fontSize: 10.5, letterSpacing: 1.4, color: const Color(0xFF31485A))),
          if (resumo.semHistorico > 0)
            Text('+${fmtN(resumo.semHistorico)} sem histórico',
                style: giroCorpo(context, 11, cor: giroTinta.withValues(alpha: .5))),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 10,
          child: Row(children: [
            for (var i = 0; i < com.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Expanded(
                flex: resumo.contagens[com[i]]!,
                child: GestureDetector(
                  onTap: () => onFaixa(com[i]),
                  child: Container(color: estilosGiro[com[i]]!.barra),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        Wrap(runSpacing: 6, children: [
          for (final c in faixasGiro)
            FractionallySizedBox(
              widthFactor: .5,
              child: InkWell(
                onTap: () => onFaixa(c),
                child: Container(
                  color: selecionadas.contains(c) ? giroDestaque : null,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(children: [
                    Container(width: 9, height: 9, color: estilosGiro[c]!.barra),
                    const SizedBox(width: 8),
                    Expanded(child: Text(c.label, style: giroCorpo(context, 12.5))),
                    Text(fmtN(resumo.contagens[c] ?? 0),
                        style: giroCorpo(context, 12.5, peso: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1, color: giroLinhaFina),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _Media(
              'MÉDIA P/ GIRO',
              resumo.mediaDiasGiro == null ? '—' : '${fmtN(resumo.mediaDiasGiro!, 1)} dias',
            ),
          ),
          Expanded(
            child: _Media('% MÉDIO VENDIDO', fmtPct(resumo.mediaPctVendido, 1)),
          ),
        ]),
      ]),
    );
  }
}

class _Media extends StatelessWidget {
  final String rotulo;
  final String valor;
  const _Media(this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              style: context.sivTextos.rotulo.copyWith(
                  fontSize: 10, letterSpacing: 1.4, color: giroApoio)),
          Text(valor, style: giroNumero(context, 22)),
        ],
      );
}

/// Cards da lista no mobile (um por produto).
class GiroCardsMobile extends StatelessWidget {
  final AbaGiro aba;
  final bool visaoVariacao;
  final PaginaGiroEstoque pagina;
  final Map<int, GiroEstoqueVariacoes> variacoes;
  final Set<int> abertos;
  final Set<int> carregandoVariacoes;
  final ValueChanged<int> onExpandir;
  final ValueChanged<int> onPagina;

  const GiroCardsMobile({
    super.key,
    required this.aba,
    required this.visaoVariacao,
    required this.pagina,
    required this.variacoes,
    required this.abertos,
    required this.carregandoVariacoes,
    required this.onExpandir,
    required this.onPagina,
  });

  @override
  Widget build(BuildContext context) {
    final meta = pagina.meta;
    return Column(children: [
      for (final l in pagina.items)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _Card(
            linha: l,
            aba: aba,
            expansivel: aba == AbaGiro.ranking &&
                !visaoVariacao &&
                l.temVariacoes &&
                !l.semHistorico,
            aberta: abertos.contains(l.referenciaId),
            carregando: carregandoVariacoes.contains(l.referenciaId),
            variacoes: variacoes[l.referenciaId],
            onTap: () => onExpandir(l.referenciaId),
          ),
        ),
      Row(children: [
        Expanded(
          child: Text(
            '${fmtN(meta.totalItems)} ${visaoVariacao ? 'variações' : 'produtos'} · página ${meta.currentPage} de ${meta.totalPages}',
            style: giroCorpo(context, 12, cor: giroApoio),
          ),
        ),
        giroPaginador(
          atual: meta.currentPage,
          total: meta.totalPages,
          onPagina: onPagina,
        ),
      ]),
    ]);
  }
}

class _Card extends StatelessWidget {
  final GiroEstoqueLinha linha;
  final AbaGiro aba;
  final bool expansivel;
  final bool aberta;
  final bool carregando;
  final GiroEstoqueVariacoes? variacoes;
  final VoidCallback onTap;
  const _Card({
    required this.linha,
    required this.aba,
    required this.expansivel,
    required this.aberta,
    required this.carregando,
    required this.variacoes,
    required this.onTap,
  });

  (String, String, String?, Color) _textos() {
    final l = linha;
    const azul = giroAcentoEscuro;
    switch (aba) {
      case AbaGiro.ranking:
        String? extra;
        var cor = azul;
        if (!l.semHistorico && l.estoque == 0) {
          extra = 'Lote esgotado';
          cor = giroErro;
        } else if (!l.semHistorico &&
            l.diasParaEsgotar != null &&
            (l.classificacao == ClassificacaoGiro.excepcional ||
                l.classificacao == ClassificacaoGiro.rapido)) {
          extra = 'Restam ${l.estoque} · esgota em ${previsaoT(l)}';
        }
        return (
          l.semHistorico
              ? 'Vendidas no período: ${l.vendido}'
              : '${l.vendido}/${l.inicial ?? '—'} vendidas · ${diasT(l.diasGiro)}',
          l.semHistorico ? '' : '${fmtUnDia(l.velocidade, 1)} un/dia',
          extra,
          cor,
        );
      case AbaGiro.reposicao:
        return (
          'Estoque ${l.estoque} · ${fmtUnDia(l.velocidade, 1)} un/dia',
          l.diasParaEsgotar == 0 ? 'Esgotado' : 'Esgota ${previsaoT(l)}',
          l.sugestaoReposicao == null ? null : 'Sugestão: repor ${l.sugestaoReposicao} un.',
          azul,
        );
      case AbaGiro.parado:
        return (
          'Entrada ${fmtDia(l.dataEntrada)} · ${diasT(l.diasEmEstoque)}',
          '${l.vendido}/${l.inicial ?? '—'} vendidas',
          l.valorParado == null ? null : '${fmtMoeda(l.valorParado)} parados em estoque',
          giroErro,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = linha;
    final (l1, l2, extra, extraCor) = _textos();
    final e = estilosGiro[l.classificacao]!;
    return InkWell(
      onTap: expansivel ? onTap : null,
      child: GiroPainel(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (aba == AbaGiro.ranking && l.rank != null)
              SizedBox(
                width: 30,
                child: Text('${l.rank}', style: giroNumero(context, 16, cor: giroApoio)),
              ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.variacaoLabel == null ? l.nome : nomeCompleto(l),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: giroCorpo(context, 14, peso: FontWeight.w600)),
                Text(
                  l.semHistorico
                      ? subtituloLinha(l)
                      : [if (l.ref.isNotEmpty) 'REF ${l.ref}', l.categoria]
                          .where((e) => e.isNotEmpty)
                          .join(' · '),
                  style: giroCorpo(context, 11.5, cor: giroApoio),
                ),
              ]),
            ),
            GiroTag(l.classificacao),
          ]),
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: GiroBarra(pct: l.pctVendido, cor: e.barra)),
            const SizedBox(width: 10),
            Text(fmtPct(l.pctVendido, 1),
                style: giroCorpo(context, 12.5, peso: FontWeight.w600)),
          ]),
          const SizedBox(height: 9),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(l1, style: giroCorpo(context, 12, cor: giroTinta.withValues(alpha: .65)))),
            Text(l2, style: giroCorpo(context, 12, cor: giroTinta.withValues(alpha: .65))),
          ]),
          if (extra != null) ...[
            const SizedBox(height: 9),
            Text(extra, style: giroCorpo(context, 12.5, cor: extraCor, peso: FontWeight.w600)),
          ],
          if (aberta) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: giroLinhaFina),
            const SizedBox(height: 10),
            if (carregando || variacoes == null)
              const LinearProgressIndicator(minHeight: 2)
            else
              for (final v in variacoes!.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: GiroGrade(gap: 10, colunas: [
                    (88, Text(v.variacaoLabel ?? v.nome, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: giroCorpo(context, 12))),
                    (null, GiroBarra(pct: v.pctVendido, cor: estilosGiro[v.classificacao]!.barra)),
                    (92, Text('${v.vendido}/${v.inicial ?? '—'} · ${diasT(v.diasGiro)}',
                        textAlign: TextAlign.right,
                        style: giroCorpo(context, 12, cor: giroTinta.withValues(alpha: .7)))),
                  ]),
                ),
          ],
        ]),
      ),
    );
  }
}
