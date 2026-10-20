import 'package:flutter/material.dart';

import '../../tema.dart';
import '../siv_cantos_blueprint.dart';

/// Tom do cartão: aço (padrão) ou âmbar (Produtos Defasados / Estoque).
enum RelatorioKpiTom { aco, atencao }

bool relatorioMobile(BuildContext context) =>
    MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

/// KPI em moldura blueprint. O primeiro cartão da linha usa [destaque]
/// (borda e rótulo em aço); os demais, rótulo em `textoApoio`.
/// [variacao] em % (>= 0 ▲ verde, < 0 ▼ vinho); no mobile só a %.
class RelatorioKpiCard extends StatelessWidget {
  final String rotulo;
  final String valor;
  final double? variacao;
  final bool destaque;
  final RelatorioKpiTom tom;
  final bool valorVinho;

  const RelatorioKpiCard({
    super.key,
    required this.rotulo,
    required this.valor,
    this.variacao,
    this.destaque = false,
    this.tom = RelatorioKpiTom.aco,
    this.valorVinho = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final mobile = relatorioMobile(context);
    final ambar = tom == RelatorioKpiTom.atencao;
    final corRotulo = ambar
        ? cores.atencao
        : destaque
        ? cores.acoAtivo
        : cores.textoApoio;
    final corBorda = ambar
        ? cores.atencaoBorda
        : destaque
        ? cores.aco
        : cores.hairline;
    final sobe = (variacao ?? 0) >= 0;
    final corVar = sobe ? cores.verde : cores.vinho;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 14 : 18,
            vertical: mobile ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border.all(color: corBorda),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rotulo.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textos.apoio.copyWith(
                  fontSize: mobile ? 9.5 : 10.5,
                  letterSpacing: mobile ? 1.1 : 1.47,
                  height: 1.2,
                  color: corRotulo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textos.titulo.copyWith(
                  fontSize: mobile ? 19 : 26,
                  color: valorVinho ? cores.vinho : cores.tinta,
                ),
              ),
              if (variacao != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    '${sobe ? '▲' : '▼'} '
                    '${variacao!.abs().toStringAsFixed(1).replaceAll('.', ',')}%'
                    '${mobile ? '' : ' vs. período anterior'}',
                    style: textos.apoio.copyWith(
                      fontSize: mobile ? 11 : 12,
                      color: corVar,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ...sivCantosBlueprint(cores.aco.withValues(alpha: 0.4)),
      ],
    );
  }
}
