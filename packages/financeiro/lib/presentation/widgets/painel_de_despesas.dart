import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/formatadores.dart';
import 'package:financeiro/presentation/utils/nomes_dos_meses.dart';
import 'package:financeiro/presentation/widgets/card_blueprint.dart';
import 'package:financeiro/presentation/widgets/despesa_status_mark.dart';
import 'package:flutter/material.dart';

const _breakpointLargo = 900.0;

class PainelDeDespesas extends StatelessWidget {
  final VoidCallback? onVerCalendario;

  const PainelDeDespesas({super.key, this.onVerCalendario});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardDeDespesasBloc, DashboardDeDespesasState>(
      builder: (context, state) {
        if (state is DashboardDeDespesasCarregarEmProgresso ||
            state is DashboardDeDespesasInitial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state is DashboardDeDespesasCarregarFalha) {
          return const Center(child: Text('Falha ao carregar o painel.'));
        }

        final sucesso = state as DashboardDeDespesasCarregarSucesso;

        return LayoutBuilder(
          builder: (context, constraints) {
            final largo = constraints.maxWidth >= _breakpointLargo;
            return ListView(
              // Horizontal 16 (não paginaHorizontal) pra alinhar com o rótulo
              // "PAINEL" da TabBar em ControleDeDespesasPage.
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: SivDimensoes.paginaHorizontal,
              ),
              children: [
                _GridIndicadores(sucesso: sucesso, largo: largo),
                const SizedBox(height: SivDimensoes.gapCards),
                if (largo)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _PainelProximosVencimentos(
                            sucesso: sucesso,
                            onVerCalendario: onVerCalendario,
                          ),
                        ),
                        const SizedBox(width: SivDimensoes.gapCards),
                        Expanded(
                          flex: 4,
                          child: _PainelParcelamentos(sucesso: sucesso),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _PainelProximosVencimentos(
                    sucesso: sucesso,
                    onVerCalendario: onVerCalendario,
                    compacto: true,
                    limite: 4,
                  ),
                  const SizedBox(height: SivDimensoes.gapCards),
                  _PainelParcelamentos(sucesso: sucesso, compacto: true),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _GridIndicadores extends StatelessWidget {
  final DashboardDeDespesasCarregarSucesso sucesso;
  final bool largo;

  const _GridIndicadores({required this.sucesso, required this.largo});

  @override
  Widget build(BuildContext context) {
    final dashboard = sucesso.dashboard!;
    final mesAtual = nomesDosMeses[sucesso.mes - 1];

    final compacto = !largo;
    final cardPago = _CardIndicador(
      titulo: 'PAGO NO MÊS',
      valor: dashboard.pagamentosDoMesPago,
      subtitulo: '${sucesso.pagamentosNoMesCount} pagamentos',
      compacto: compacto,
    );
    final cardFuturos = _CardIndicador(
      titulo: 'PAGAMENTOS FUTUROS',
      valor: dashboard.pagamentosFuturos,
      subtitulo: sucesso.pagamentosFuturosAPartirDe != null
          ? 'a partir de ${nomesDosMeses[sucesso.pagamentosFuturosAPartirDe!.month - 1].toLowerCase()}'
          : null,
      compacto: compacto,
    );
    final cardPendente = _CardIndicador(
      titulo: 'PENDENTE NO MÊS',
      valor: dashboard.pagamentosDoMesPendente,
      subtitulo: compacto
          ? '${sucesso.pendentesNoMesCount} a pagar · ${sucesso.previstasRecorrentesCount} previstas'
          : '${sucesso.pendentesNoMesCount} a pagar · ${sucesso.previstasRecorrentesCount} previstas (recorrentes)',
      compacto: compacto,
    );
    final cardParcelas = _CardIndicador(
      titulo: 'PARCELAS EM ABERTO',
      valor: dashboard.totalPendenteParcelasEmAberto,
      subtitulo: compacto
          ? '${sucesso.parcelamentosAbertos.length} parcelamentos'
          : '${sucesso.parcelamentosAbertos.length} parcelamentos · ${_parcelasRestantes(sucesso.parcelamentosAbertos)} parcelas',
      compacto: compacto,
    );

    if (!largo) {
      return Column(
        children: [
          _CardPercentualDespesa(
              dashboard: dashboard, mesAtual: mesAtual, compacto: true),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [cardPago, cardPendente, cardFuturos, cardParcelas],
          ),
        ],
      );
    }

    final cardGrande =
        _CardPercentualDespesa(dashboard: dashboard, mesAtual: mesAtual);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: cardGrande),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(child: cardPago),
                const SizedBox(height: 12),
                Expanded(child: cardFuturos),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(child: cardPendente),
                const SizedBox(height: 12),
                Expanded(child: cardParcelas),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _parcelasRestantes(List<ParcelamentoAgrupado> parcelamentos) {
    return parcelamentos.fold<int>(
      0,
      (soma, p) => soma + (p.totalParcelas - p.parcelasPagas),
    );
  }
}

class _CardPercentualDespesa extends StatelessWidget {
  final DespesaDashboard dashboard;
  final String mesAtual;
  final bool compacto;

  const _CardPercentualDespesa({
    required this.dashboard,
    required this.mesAtual,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final faturamento = dashboard.faturamentoDoPeriodo;
    final pctPago = faturamento > 0
        ? (dashboard.pagamentosDoMesPago / faturamento * 100).clamp(0, 100)
        : 0.0;
    final pctAPagar = faturamento > 0
        ? (dashboard.pagamentosDoMesPendente / faturamento * 100).clamp(0, 100)
        : 0.0;
    final somaPct = pctPago + pctAPagar;

    return CardBlueprint(
      padding: EdgeInsets.all(compacto ? 16 : SivDimensoes.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            children: [
              Text('DESPESA SOBRE FATURAMENTO',
                  style: textos.rotulo.copyWith(color: cores.textoApoio)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatarPercentual(
                        dashboard.percentualDespesaSobreFaturamento),
                    style: textos.display.copyWith(
                        fontSize: compacto ? 52 : 68,
                        color: cores.acoEscuro),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    compacto
                        ? 'de ${formatarReais(faturamento)}'
                        : 'do faturamento de ${mesAtual.toLowerCase()}',
                    style: textos.apoio.copyWith(color: cores.textoApoio),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              if (somaPct > 0)
                Container(
                  height: compacto ? 12 : 14,
                  decoration:
                      BoxDecoration(border: Border.all(color: cores.hairline)),
                  child: Row(
                    children: [
                      Expanded(
                          flex: (pctPago * 100).round().clamp(1, 1000000),
                          child: Container(color: cores.acoAtivo)),
                      Expanded(
                        flex: (pctAPagar * 100).round().clamp(1, 1000000),
                        child: CustomPaint(
                            painter: _HachuraPainter(
                                cor: cores.aco, corClara: cores.selecaoFundo)),
                      ),
                    ],
                  ),
                )
              else
                Container(
                    height: compacto ? 12 : 14,
                    decoration: BoxDecoration(
                        border: Border.all(color: cores.hairline))),
              const SizedBox(height: 8),
              Row(
                children: [
                  _LegendaCor(
                      cor: cores.acoAtivo,
                      texto: 'Pago ${formatarPercentual(pctPago.toDouble())}'),
                  const SizedBox(width: 16),
                  _LegendaHachurada(
                      texto:
                          'A pagar ${formatarPercentual(pctAPagar.toDouble())}'),
                  if (!compacto) ...[
                    const Spacer(),
                    Text('Faturamento ${formatarReais(faturamento)}',
                        style: textos.apoio.copyWith(color: cores.textoApoio)),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HachuraPainter extends CustomPainter {
  final Color cor;
  final Color corClara;

  _HachuraPainter({required this.cor, required this.corClara});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = corClara);
    final paint = Paint()
      ..color = cor
      ..strokeWidth = 3;
    const passo = 6.0;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var x = -size.height; x < size.width; x += passo) {
      canvas.drawLine(
          Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendaCor extends StatelessWidget {
  final Color cor;
  final String texto;

  const _LegendaCor({required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: cor),
        const SizedBox(width: 6),
        Text(texto,
            style: context.sivTextos.apoio
                .copyWith(color: context.sivColors.textoApoio)),
      ],
    );
  }
}

class _LegendaHachurada extends StatelessWidget {
  final String texto;

  const _LegendaHachurada({required this.texto});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 10,
            height: 10,
            child: CustomPaint(
                painter: _HachuraPainter(
                    cor: cores.aco, corClara: cores.selecaoFundo))),
        const SizedBox(width: 6),
        Text(texto,
            style: context.sivTextos.apoio.copyWith(color: cores.textoApoio)),
      ],
    );
  }
}

class _CardIndicador extends StatelessWidget {
  final String titulo;
  final double valor;
  final String? subtitulo;
  final bool compacto;

  const _CardIndicador({
    required this.titulo,
    required this.valor,
    this.subtitulo,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return CardBlueprint(
      padding: compacto
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            style: textos.rotulo.copyWith(
                color: cores.textoApoio, fontSize: compacto ? 11 : null),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compacto ? 3 : 6),
          Text(formatarReais(valor),
              style: textos.secao.copyWith(
                  fontSize: compacto ? 21 : 32,
                  fontWeight: FontWeight.w500,
                  color: cores.acoEscuro)),
          if (subtitulo != null) ...[
            SizedBox(height: compacto ? 2 : 4),
            Text(
              subtitulo!,
              style: textos.apoio.copyWith(
                  color: cores.textoApoio, fontSize: compacto ? 11.5 : null),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _PainelProximosVencimentos extends StatelessWidget {
  final DashboardDeDespesasCarregarSucesso sucesso;
  final VoidCallback? onVerCalendario;
  final bool compacto;
  final int? limite;

  const _PainelProximosVencimentos({
    required this.sucesso,
    this.onVerCalendario,
    this.compacto = false,
    this.limite,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final itens = limite == null
        ? sucesso.proximosVencimentos
        : sucesso.proximosVencimentos.take(limite!).toList();
    return CardBlueprint(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: compacto ? 44 : null,
            padding: compacto
                ? const EdgeInsets.symmetric(horizontal: 14)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            alignment: compacto ? Alignment.centerLeft : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRÓXIMOS VENCIMENTOS',
                  style: textos.secao.copyWith(
                      fontSize: compacto ? 14 : 16, color: cores.acoAtivo),
                ),
                InkWell(
                  onTap: onVerCalendario,
                  child: Text(compacto ? 'Calendário' : 'Ver calendário',
                      style: textos.apoio.copyWith(color: cores.acoProfundo)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cores.hairline),
          if (itens.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Nenhum vencimento próximo.',
                  style: textos.apoio.copyWith(color: cores.textoApoio)),
            )
          else
            for (final ocorrencia in itens)
              _LinhaVencimento(
                ocorrencia: ocorrencia,
                categoriaNome: sucesso.categoriaPorId[ocorrencia.categoriaId],
                origemNome: sucesso.origemPorId[ocorrencia.origemPagamentoId],
                compacto: compacto,
              ),
        ],
      ),
    );
  }
}

class _LinhaVencimento extends StatelessWidget {
  final DespesaOcorrenciaCalendario ocorrencia;
  final String? categoriaNome;
  final String? origemNome;
  final bool compacto;

  const _LinhaVencimento({
    required this.ocorrencia,
    this.categoriaNome,
    this.origemNome,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final data = ocorrencia.dataPagamento;
    final hoje = DateTime.now();
    final ehHoje = data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;
    final quando = ehHoje
        ? 'HOJE'
        : data.month == hoje.month
            ? nomesDosDiasDaSemana[data.weekday % 7].substring(0, 3)
            : nomesDosMeses[data.month - 1].substring(0, 3).toUpperCase();

    if (compacto) {
      final tag = ocorrencia.totalParcelas != null
          ? 'parcela ${ocorrencia.numeroParcela ?? '?'}/${ocorrencia.totalParcelas}'
          : (ocorrencia.virtual ? 'prevista' : null);
      final sub = [
        '${categoriaNome ?? '-'} · ${origemNome ?? '-'}',
        if (tag != null) tag,
      ].join(' · ');

      return Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cores.hairline))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${data.day}',
                      style: textos.secao
                          .copyWith(fontSize: 19, color: cores.acoEscuro)),
                  Text(quando,
                      style: textos.rotulo
                          .copyWith(fontSize: 9.5, color: cores.textoApoio)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ocorrencia.descricao,
                      style: textos.corpo.copyWith(fontSize: 13.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(sub,
                      style: textos.apoio
                          .copyWith(fontSize: 11.5, color: cores.textoApoio),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(formatarReais(ocorrencia.valor),
                style: textos.secao.copyWith(fontSize: 15)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cores.hairline))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data.day}',
                    style: textos.secao
                        .copyWith(fontSize: 22, color: cores.acoEscuro)),
                Text(quando,
                    style: textos.rotulo
                        .copyWith(fontSize: 10, color: cores.textoApoio)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ocorrencia.descricao,
                    style: textos.corpo.copyWith(fontSize: 14)),
                Text(
                  '${categoriaNome ?? '-'} · ${origemNome ?? '-'}',
                  style: textos.apoio
                      .copyWith(fontSize: 12, color: cores.textoApoio),
                ),
                if (ocorrencia.totalParcelas != null || ocorrencia.virtual)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 6,
                      children: [
                        if (ocorrencia.totalParcelas != null)
                          DespesaTag(
                              'Parcela ${ocorrencia.numeroParcela ?? '?'}/${ocorrencia.totalParcelas}'),
                        if (ocorrencia.virtual)
                          const DespesaTag('Prevista', tracejada: true),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(formatarReais(ocorrencia.valor),
              style: textos.secao.copyWith(fontSize: 17)),
        ],
      ),
    );
  }
}

class _PainelParcelamentos extends StatelessWidget {
  final DashboardDeDespesasCarregarSucesso sucesso;
  final bool compacto;

  const _PainelParcelamentos({required this.sucesso, this.compacto = false});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return CardBlueprint(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: compacto ? 44 : null,
            padding: compacto
                ? const EdgeInsets.symmetric(horizontal: 14)
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            alignment: compacto ? Alignment.centerLeft : null,
            child: Text('PARCELAMENTOS EM ABERTO',
                style: textos.secao.copyWith(
                    fontSize: compacto ? 14 : 16, color: cores.acoAtivo)),
          ),
          Divider(height: 1, color: cores.hairline),
          if (sucesso.parcelamentosAbertos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Nenhum parcelamento em aberto.',
                  style: textos.apoio.copyWith(color: cores.textoApoio)),
            )
          else
            for (final p in sucesso.parcelamentosAbertos)
              Padding(
                padding: compacto
                    ? const EdgeInsets.fromLTRB(14, 12, 14, 12)
                    : const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: _LinhaParcelamento(parcelamento: p, compacto: compacto),
              ),
        ],
      ),
    );
  }
}

class _LinhaParcelamento extends StatelessWidget {
  final ParcelamentoAgrupado parcelamento;
  final bool compacto;

  const _LinhaParcelamento({required this.parcelamento, this.compacto = false});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final termina = parcelamento.terminaEm;
    final terminaTexto = termina != null
        ? 'termina em ${nomesDosMeses[termina.month - 1].substring(0, 3).toLowerCase()}/${termina.year.toString().substring(2)}'
        : null;
    final valorTotal = parcelamento.valorParcela * parcelamento.totalParcelas;
    final subtitulo = compacto
        ? [
            '${parcelamento.parcelasPagas} de ${parcelamento.totalParcelas} pagas',
            '${formatarReais(parcelamento.valorParcela)}/mês',
            if (terminaTexto != null) terminaTexto,
          ].join(' · ')
        : '${parcelamento.parcelasPagas} de ${parcelamento.totalParcelas} pagas · '
            '${formatarReais(parcelamento.valorParcela)}/mês · '
            '${parcelamento.origemNome}'
            '${terminaTexto != null ? ' · $terminaTexto' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(parcelamento.descricao,
                    style: textos.corpo.copyWith(
                        fontSize: compacto ? 13.5 : 14))),
            Text(formatarReais(valorTotal),
                style: textos.secao.copyWith(fontSize: compacto ? 15 : 16)),
          ],
        ),
        SizedBox(height: compacto ? 7 : 8),
        Row(
          children: [
            for (var i = 0; i < parcelamento.totalParcelas; i++)
              Expanded(
                child: Container(
                  height: compacto ? 7 : 8,
                  margin: EdgeInsets.only(
                      right: i < parcelamento.totalParcelas - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < parcelamento.parcelasPagas
                        ? cores.acoAtivo
                        : (i == parcelamento.parcelasPagas
                            ? cores.selecaoFundo
                            : cores.superficie),
                    border: Border.all(
                      color: i == parcelamento.parcelasPagas
                          ? cores.aco
                          : cores.hairline,
                      width: i == parcelamento.parcelasPagas ? 1.5 : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitulo, style: textos.apoio.copyWith(color: cores.textoApoio)),
      ],
    );
  }
}
