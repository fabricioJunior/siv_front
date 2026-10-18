import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/presentation/blocs/relatorio_frequencia_clientes_bloc/relatorio_frequencia_clientes_bloc.dart';
import 'package:comercial/presentation/widgets/frequencia/frequencia_formato.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

FrequenciaClasseResumo _classe(FrequenciaClientesResumo r, String c) =>
    r.classes.firstWhere(
      (e) => e.classe == c,
      orElse: () => FrequenciaClasseResumo(classe: c),
    );

/// Painel de KPIs (1a desktop / 1b mobile). Só exibe; a página liga os
/// callbacks ao bloc ([onClasse] = toggle, [onAtrasados] = toggle).
class FrequenciaPainel extends StatelessWidget {
  final RelatorioFrequenciaClientesState state;
  final bool criteriosAbertos;
  final VoidCallback onCriterios;
  final ValueChanged<String> onClasse;
  final VoidCallback onAtrasados;

  const FrequenciaPainel({
    super.key,
    required this.state,
    required this.criteriosAbertos,
    required this.onCriterios,
    required this.onClasse,
    required this.onAtrasados,
  });

  @override
  Widget build(BuildContext context) => relatorioMobile(context)
      ? _Mobile(this)
      : _Desktop(this);
}

class _Desktop extends StatelessWidget {
  final FrequenciaPainel p;
  const _Desktop(this.p);

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final r = p.state.resumo;

    final apoio = t.apoio.copyWith(fontSize: 11.5, height: 1.35, color: c.textoApoio);
    final rotulo = t.apoio.copyWith(fontSize: 10.5, letterSpacing: 1.47, color: c.textoApoio);
    final numero = t.titulo.copyWith(fontSize: 30, height: 1.1, color: c.tinta);

    Widget celula({
      required int flex,
      required List<Widget> filhos,
      Color? fundo,
      VoidCallback? onTap,
      Color? faixa,
      bool primeira = false,
    }) {
      final Widget corpo = faixa == null
          ? Padding(
              padding: const EdgeInsets.all(16).copyWith(left: 18, right: 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 3, color: faixa),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos),
                ),
              ],
            );
      return Expanded(
        flex: flex,
        child: Container(
          decoration: BoxDecoration(
            color: fundo,
            border: primeira ? null : Border(left: BorderSide(color: c.hairline)),
          ),
          child: onTap == null
              ? corpo
              : InkWell(onTap: onTap, child: corpo),
        ),
      );
    }

    final celulas = <Widget>[
      celula(
        flex: 120,
        primeira: true,
        filhos: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CLIENTES', style: rotulo.copyWith(color: c.acoAtivo)),
              InkWell(
                onTap: p.onCriterios,
                child: Text(
                  'Critérios',
                  style: apoio.copyWith(
                    color: c.acoProfundo,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(frequenciaInt(r.clientes), style: numero),
          const SizedBox(height: 4),
          Text('compraram no período · ${frequenciaMoeda(r.valorTotal)}', style: apoio),
        ],
      ),
      for (final k in const ['A', 'B', 'C'])
        () {
          final cl = _classe(r, k);
          return celula(
            flex: 115,
            faixa: frequenciaCorBarra(c, k),
            fundo: p.state.classe == k ? c.selecaoFundo : null,
            onTap: () => p.onClasse(k),
            filhos: [
              Text('CLASSE $k', style: rotulo),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(frequenciaInt(cl.clientes), style: numero),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${frequenciaPct(cl.percentualClientes)} dos clientes',
                      style: apoio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: apoio,
                  children: [
                    TextSpan(
                      text: frequenciaPct(cl.percentualFaturamento),
                      style: apoio.copyWith(fontWeight: FontWeight.w600, color: c.tinta),
                    ),
                    TextSpan(text: ' do faturamento · ${frequenciaMoeda(cl.valor)}'),
                  ],
                ),
              ),
            ],
          );
        }(),
      celula(
        flex: 100,
        filhos: [
          Text('VISITAS/CLIENTE', style: rotulo),
          const SizedBox(height: 4),
          Text(frequenciaDec(r.visitasPorCliente), style: numero),
          const SizedBox(height: 4),
          Text(
            'volta a cada ${frequenciaDec(r.intervaloMedioDias, 0)} dias, em média',
            style: apoio,
          ),
        ],
      ),
      celula(
        flex: 100,
        filhos: [
          Text('TICKET MÉDIO', style: rotulo),
          const SizedBox(height: 4),
          Text(frequenciaMoeda(r.ticketMedio), style: numero),
          const SizedBox(height: 4),
          Text('por visita', style: apoio),
        ],
      ),
      celula(
        flex: 100,
        fundo: p.state.atrasados ? c.selecaoFundo : null,
        onTap: p.onAtrasados,
        filhos: [
          Text('ATRASADOS', style: rotulo.copyWith(color: c.atencao)),
          const SizedBox(height: 4),
          Text(frequenciaInt(r.atrasados), style: numero.copyWith(color: c.atencao)),
          const SizedBox(height: 4),
          Text('passaram do intervalo habitual', style: apoio),
        ],
      ),
    ];

    return SivMolduraBlueprint(
      padding: 0,
      fundo: c.superficie,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: celulas),
      ),
    );
  }
}

class _Mobile extends StatelessWidget {
  final FrequenciaPainel p;
  const _Mobile(this.p);

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final r = p.state.resumo;
    final apoio = t.apoio.copyWith(fontSize: 11.5, color: c.textoApoio);
    final rotulo = t.apoio.copyWith(fontSize: 9.5, letterSpacing: 1.1, color: c.textoApoio);

    Widget barra(String titulo, double Function(FrequenciaClasseResumo) v) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: rotulo),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                for (final k in const ['A', 'B', 'C'])
                  if (v(_classe(r, k)) > 0)
                    Expanded(
                      flex: (v(_classe(r, k)) * 100).round().clamp(1, 1000000),
                      child: Container(color: frequenciaCorBarra(c, k)),
                    ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget linhaClasse(String k) {
      final cl = _classe(r, k);
      return InkWell(
        onTap: () => p.onClasse(k),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          color: p.state.classe == k ? c.selecaoFundo : null,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              Container(width: 3, height: 24, color: frequenciaCorBarra(c, k)),
              const SizedBox(width: 10),
              Text('Classe $k', style: t.corpo.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${frequenciaInt(cl.clientes)} · ${frequenciaPct(cl.percentualClientes)}',
                  style: apoio,
                ),
              ),
              Text(
                '${frequenciaPct(cl.percentualFaturamento)} do fat.',
                style: t.corpo.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return SivMolduraBlueprint(
      padding: 14,
      fundo: c.superficie,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(frequenciaInt(r.clientes), style: t.titulo.copyWith(fontSize: 26)),
              const SizedBox(width: 6),
              Text('CLIENTES', style: rotulo),
              const Spacer(),
              Text(frequenciaMoeda(r.valorTotal), style: t.corpo.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          barra('% DOS CLIENTES', (e) => e.percentualClientes),
          const SizedBox(height: 10),
          barra('% DO FATURAMENTO', (e) => e.percentualFaturamento),
          const SizedBox(height: 8),
          for (final k in const ['A', 'B', 'C']) linhaClasse(k),
          Divider(height: 16, color: c.hairline),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VISITAS/CLIENTE', style: rotulo),
                      Text(
                        '${frequenciaDec(r.visitasPorCliente)} · ${frequenciaDec(r.intervaloMedioDias, 0)} dias',
                        style: t.titulo.copyWith(fontSize: 19),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: c.hairline),
                Expanded(
                  child: InkWell(
                    onTap: p.onAtrasados,
                    child: Container(
                      color: p.state.atrasados ? c.selecaoFundo : null,
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ATRASADOS', style: rotulo.copyWith(color: c.atencao)),
                          Text(
                            frequenciaInt(r.atrasados),
                            style: t.titulo.copyWith(fontSize: 19, color: c.atencao),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Esqueleto do painel (carregando).
class FrequenciaPainelEsqueleto extends StatelessWidget {
  const FrequenciaPainelEsqueleto({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = relatorioMobile(context);
    Widget bloco(double h) => Container(
      height: h,
      decoration: BoxDecoration(
        color: context.sivColors.hairline,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bloco(mobile ? 230 : 110),
        if (!mobile) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: 16, child: bloco(260)),
              const SizedBox(width: 20),
              Expanded(flex: 10, child: bloco(260)),
            ],
          ),
        ],
      ],
    );
  }
}
