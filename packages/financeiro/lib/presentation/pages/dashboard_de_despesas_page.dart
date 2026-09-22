import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class DashboardDeDespesasPage extends StatelessWidget {
  const DashboardDeDespesasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;
    final agora = DateTime.now();

    return BlocProvider<DashboardDeDespesasBloc>(
      create: (_) => sl<DashboardDeDespesasBloc>()
        ..add(
          DashboardDeDespesasIniciou(
            empresaId: empresaId,
            ano: agora.year,
            mes: agora.month,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Dashboard de despesas')),
        body: BlocBuilder<DashboardDeDespesasBloc, DashboardDeDespesasState>(
          builder: (context, state) {
            if (state is DashboardDeDespesasCarregarEmProgresso ||
                state is DashboardDeDespesasInitial) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is DashboardDeDespesasCarregarFalha) {
              return const Center(
                child: Text('Falha ao carregar o dashboard de despesas.'),
              );
            }

            final dashboard = state.dashboard!;
            return GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _CardIndicador(
                  titulo: 'Pago no mês',
                  valor: dashboard.pagamentosDoMesPago,
                  cor: Colors.green,
                ),
                _CardIndicador(
                  titulo: 'Pendente no mês',
                  valor: dashboard.pagamentosDoMesPendente,
                  cor: Colors.orange,
                ),
                _CardIndicador(
                  titulo: 'Pagamentos futuros',
                  valor: dashboard.pagamentosFuturos,
                  cor: Colors.blueGrey,
                ),
                _CardIndicador(
                  titulo: 'Parcelas em aberto',
                  valor: dashboard.totalPendenteParcelasEmAberto,
                  cor: Colors.deepOrange,
                ),
                _CardIndicador(
                  titulo: 'Faturamento do período',
                  valor: dashboard.faturamentoDoPeriodo,
                  cor: Colors.teal,
                ),
                _CardIndicador(
                  titulo: '% despesa / faturamento',
                  valor: dashboard.percentualDespesaSobreFaturamento,
                  cor: Colors.indigo,
                  ehPercentual: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CardIndicador extends StatelessWidget {
  final String titulo;
  final double valor;
  final Color cor;
  final bool ehPercentual;

  const _CardIndicador({
    required this.titulo,
    required this.valor,
    required this.cor,
    this.ehPercentual = false,
  });

  @override
  Widget build(BuildContext context) {
    final texto = ehPercentual
        ? '${valor.toStringAsFixed(1)}%'
        : 'R\$${valor.toStringAsFixed(2)}';

    return Card(
      color: cor.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: cor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
