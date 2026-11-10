import 'package:comercial/domain/models/relatorio_pedidos_contagem.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:comercial/presentation/widgets/pedidos_contagem/pedidos_contagem_formato.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Tons de aço, na ordem das etapas (claro -> escuro).
List<Color> _tons(SivColors c) => [
      c.aco.withValues(alpha: 0.35),
      c.aco.withValues(alpha: 0.6),
      c.aco,
      c.acoAtivo,
      c.acoEscuro,
    ];

/// Barra empilhada do custo em aberto por etapa + botões que filtram a lista.
class CustoPorEtapa extends StatelessWidget {
  final List<EtapaResumo> etapas;
  final String? selecionada;
  final ValueChanged<String?> onEtapa;

  const CustoPorEtapa({
    super.key,
    required this.etapas,
    required this.selecionada,
    required this.onEtapa,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final mobile = relatorioMobile(context);
    final tons = _tons(c);
    final total = etapas.fold<double>(0, (s, e) => s + e.custo);
    final pedidos = etapas.fold<int>(0, (s, e) => s + e.pedidos);

    Widget botao(
        String? etapa, String rotulo, int n, double custo, Color? cor) {
      final ativo = selecionada == etapa;
      return Material(
        color: ativo ? c.selecaoFundo : c.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          side: BorderSide(color: ativo ? c.aco : c.hairline),
        ),
        child: InkWell(
          key: Key('contagem_filtro_etapa_${etapa ?? 'todas'}'),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          onTap: () => onEtapa(etapa),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 11,
              vertical: mobile ? 10 : 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cor != null) ...[
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: cor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 7),
                ],
                Text(rotulo, style: context.sivTextos.apoio),
                const SizedBox(width: 7),
                Text(
                  '$n',
                  style: context.sivTextos.apoio.copyWith(color: c.textoApoio),
                ),
                if (!mobile) ...[
                  const SizedBox(width: 7),
                  Text(frequenciaMoeda(custo), style: context.sivTextos.apoio),
                ],
              ],
            ),
          ),
        ),
      );
    }

    final botoes = [
      botao(null, 'Todas', pedidos, total, null),
      for (var i = 0; i < etapas.length; i++)
        botao(
          etapas[i].etapa,
          rotulosEtapaContagem[etapas[i].etapa] ?? etapas[i].etapa,
          etapas[i].pedidos,
          etapas[i].custo,
          tons[i % tons.length],
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!mobile)
          Container(
            height: 8,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: c.hairline,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                if (total > 0)
                  for (var i = 0; i < etapas.length; i++)
                    if (etapas[i].custo > 0)
                      Expanded(
                        flex: (etapas[i].custo * 100).round().clamp(1, 1 << 30),
                        child: ColoredBox(
                          color: tons[i % tons.length],
                          child: const SizedBox.expand(),
                        ),
                      ),
              ],
            ),
          ),
        SizedBox(height: mobile ? 0 : 8),
        if (mobile)
          SizedBox(
            height: SivDimensoes.alvoToqueMinimo,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: botoes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => botoes[i],
            ),
          )
        else
          Wrap(spacing: 6, runSpacing: 6, children: botoes),
      ],
    );
  }
}
