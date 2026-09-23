import 'package:core/bloc.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/nomes_dos_meses.dart';
import 'package:flutter/material.dart';

const _corBorda = Color(0x1F26282A);
const _corLabel = Colors.black54;
const _corNumero = Color(0xFF22323F);
const _corAzulEscuro = Color(0xFF31485A);
const _corAzulMedio = Color(0xFF5980A6);
const _corAzulClaro = Color(0xFFE4ECF3);

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
              padding: const EdgeInsets.all(16),
              children: [
                _GridIndicadores(sucesso: sucesso, largo: largo),
                const SizedBox(height: 16),
                if (largo)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _PainelProximosVencimentos(
                          sucesso: sucesso,
                          onVerCalendario: onVerCalendario,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _PainelParcelamentos(sucesso: sucesso),
                      ),
                    ],
                  )
                else ...[
                  _PainelProximosVencimentos(
                    sucesso: sucesso,
                    onVerCalendario: onVerCalendario,
                  ),
                  const SizedBox(height: 16),
                  _PainelParcelamentos(sucesso: sucesso),
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

    final cardPago = _CardIndicador(
      titulo: 'PAGO NO MÊS',
      valor: dashboard.pagamentosDoMesPago,
      subtitulo: 'contagem: ${sucesso.pagamentosNoMesCount}',
    );
    final cardFuturos = _CardIndicador(
      titulo: 'PAGAMENTOS FUTUROS',
      valor: dashboard.pagamentosFuturos,
      subtitulo: sucesso.pagamentosFuturosAPartirDe != null
          ? 'a partir de ${nomesDosMeses[sucesso.pagamentosFuturosAPartirDe!.month - 1]}'
          : null,
    );
    final cardPendente = _CardIndicador(
      titulo: 'PENDENTE NO MÊS',
      valor: dashboard.pagamentosDoMesPendente,
      subtitulo:
          '${sucesso.pendentesNoMesCount} pendentes · ${sucesso.previstasRecorrentesCount} previstas',
    );
    final cardParcelas = _CardIndicador(
      titulo: 'PARCELAS EM ABERTO',
      valor: dashboard.totalPendenteParcelasEmAberto,
      subtitulo:
          '${sucesso.parcelamentosAbertos.length} parcelamentos · ${_parcelasRestantes(sucesso.parcelamentosAbertos)} parcelas',
    );

    final cardGrande = _CardPercentualDespesa(
      dashboard: dashboard,
      mesAtual: mesAtual,
    );

    if (!largo) {
      return Column(
        children: [
          SizedBox(height: 220, child: cardGrande),
          const SizedBox(height: 12),
          cardPago,
          const SizedBox(height: 12),
          cardFuturos,
          const SizedBox(height: 12),
          cardPendente,
          const SizedBox(height: 12),
          cardParcelas,
        ],
      );
    }

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

class _CardBlueprint extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _CardBlueprint({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _corBorda),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: padding,
          child: child,
        ),
        const _Corner(alignment: Alignment.topLeft),
        const _Corner(alignment: Alignment.topRight),
        const _Corner(alignment: Alignment.bottomLeft),
        const _Corner(alignment: Alignment.bottomRight),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;

  const _Corner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Positioned(
      top: isTop ? -1 : null,
      bottom: isTop ? null : -1,
      left: isLeft ? -1 : null,
      right: isLeft ? null : -1,
      child: SizedBox(
        width: 10,
        height: 10,
        child: CustomPaint(
          painter: _CornerPainter(top: isTop, left: isLeft),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _CornerPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _corAzulMedio
      ..strokeWidth = 1.5;
    final y = top ? 0.0 : size.height;
    final x = left ? 0.0 : size.width;
    canvas.drawLine(Offset(x, y), Offset(left ? size.width : 0, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, top ? size.height : 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardPercentualDespesa extends StatelessWidget {
  final DespesaDashboard dashboard;
  final String mesAtual;

  const _CardPercentualDespesa({required this.dashboard, required this.mesAtual});

  @override
  Widget build(BuildContext context) {
    final faturamento = dashboard.faturamentoDoPeriodo;
    final pctPago = faturamento > 0
        ? (dashboard.pagamentosDoMesPago / faturamento * 100).clamp(0, 100)
        : 0.0;
    final pctAPagar = faturamento > 0
        ? (dashboard.pagamentosDoMesPendente / faturamento * 100).clamp(0, 100)
        : 0.0;
    final somaPct = pctPago + pctAPagar;

    return _CardBlueprint(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Label('DESPESA SOBRE FATURAMENTO'),
          const SizedBox(height: 8),
          Text(
            '${dashboard.percentualDespesaSobreFaturamento.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _corNumero,
            ),
          ),
          Text(
            'do faturamento de $mesAtual',
            style: const TextStyle(fontSize: 12, color: _corLabel),
          ),
          const SizedBox(height: 16),
          if (somaPct > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 14,
                child: Row(
                  children: [
                    Expanded(
                      flex: (pctPago * 100).round().clamp(1, 1000000),
                      child: Container(color: _corAzulEscuro),
                    ),
                    Expanded(
                      flex: (pctAPagar * 100).round().clamp(1, 1000000),
                      child: Container(color: _corAzulClaro),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 14,
              decoration: BoxDecoration(
                border: Border.all(color: _corBorda),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _LegendaCor(cor: _corAzulEscuro, texto: 'Pago ${pctPago.toStringAsFixed(0)}%'),
              _LegendaCor(cor: _corAzulClaro, texto: 'A pagar ${pctAPagar.toStringAsFixed(0)}%'),
              Text(
                'Faturamento R\$${faturamento.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: _corLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
        Text(texto, style: const TextStyle(fontSize: 12, color: _corLabel)),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String texto;

  const _Label(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: _corLabel,
      ),
    );
  }
}

class _CardIndicador extends StatelessWidget {
  final String titulo;
  final double valor;
  final String? subtitulo;

  const _CardIndicador({required this.titulo, required this.valor, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return _CardBlueprint(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Label(titulo),
          const SizedBox(height: 6),
          Text(
            'R\$${valor.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _corNumero,
            ),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            Text(subtitulo!, style: const TextStyle(fontSize: 11, color: _corLabel)),
          ],
        ],
      ),
    );
  }
}

class _PainelProximosVencimentos extends StatelessWidget {
  final DashboardDeDespesasCarregarSucesso sucesso;
  final VoidCallback? onVerCalendario;

  const _PainelProximosVencimentos({required this.sucesso, this.onVerCalendario});

  @override
  Widget build(BuildContext context) {
    return _CardBlueprint(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Próximos vencimentos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              TextButton(
                onPressed: onVerCalendario,
                child: const Text('Ver calendário'),
              ),
            ],
          ),
          if (sucesso.proximosVencimentos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nenhum vencimento próximo.'),
            )
          else
            for (var i = 0; i < sucesso.proximosVencimentos.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _LinhaVencimento(
                ocorrencia: sucesso.proximosVencimentos[i],
                categoriaNome: sucesso.categoriaPorId[sucesso.proximosVencimentos[i].categoriaId],
                origemNome: sucesso.origemPorId[sucesso.proximosVencimentos[i].origemPagamentoId],
              ),
            ],
        ],
      ),
    );
  }
}

class _LinhaVencimento extends StatelessWidget {
  final DespesaOcorrenciaCalendario ocorrencia;
  final String? categoriaNome;
  final String? origemNome;

  const _LinhaVencimento({
    required this.ocorrencia,
    this.categoriaNome,
    this.origemNome,
  });

  @override
  Widget build(BuildContext context) {
    final data = ocorrencia.dataPagamento;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Text(
                  '${data.day}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _corNumero),
                ),
                Text(
                  nomesDosMeses[data.month - 1].substring(0, 3).toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: _corLabel),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ocorrencia.descricao, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${categoriaNome ?? '-'} · ${origemNome ?? '-'}',
                  style: const TextStyle(fontSize: 12, color: _corLabel),
                ),
                if (ocorrencia.totalParcelas != null || ocorrencia.virtual)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      children: [
                        if (ocorrencia.totalParcelas != null)
                          _Tag('Parcela ${ocorrencia.numeroParcela ?? '?'}/${ocorrencia.totalParcelas}'),
                        if (ocorrencia.virtual) const _Tag('Prevista'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'R\$${ocorrencia.valor.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: _corNumero),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String texto;

  const _Tag(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: _corAzulMedio),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(texto, style: const TextStyle(fontSize: 10, color: _corAzulEscuro)),
    );
  }
}

class _PainelParcelamentos extends StatelessWidget {
  final DashboardDeDespesasCarregarSucesso sucesso;

  const _PainelParcelamentos({required this.sucesso});

  @override
  Widget build(BuildContext context) {
    return _CardBlueprint(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Parcelamentos em aberto',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          if (sucesso.parcelamentosAbertos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nenhum parcelamento em aberto.'),
            )
          else
            for (final p in sucesso.parcelamentosAbertos)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _LinhaParcelamento(parcelamento: p),
              ),
        ],
      ),
    );
  }
}

class _LinhaParcelamento extends StatelessWidget {
  final ParcelamentoAgrupado parcelamento;

  const _LinhaParcelamento({required this.parcelamento});

  @override
  Widget build(BuildContext context) {
    final termina = parcelamento.terminaEm;
    final valorTotal = parcelamento.valorParcela * parcelamento.totalParcelas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(parcelamento.descricao, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text(
              'R\$${valorTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: _corNumero),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < parcelamento.totalParcelas; i++)
              Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: i < parcelamento.totalParcelas - 1 ? 3 : 0),
                  decoration: BoxDecoration(
                    color: i < parcelamento.parcelasPagas ? _corAzulEscuro : Colors.white,
                    border: Border.all(
                      color: i == parcelamento.parcelasPagas ? _corAzulMedio : _corBorda,
                      width: i == parcelamento.parcelasPagas ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${parcelamento.parcelasPagas} de ${parcelamento.totalParcelas} pagas · '
          'R\$${parcelamento.valorParcela.toStringAsFixed(2)}/mês · '
          '${parcelamento.origemNome}'
          '${termina != null ? ' · termina em ${nomesDosMeses[termina.month - 1].substring(0, 3)}/${termina.year.toString().substring(2)}' : ''}',
          style: const TextStyle(fontSize: 12, color: _corLabel),
        ),
      ],
    );
  }
}
