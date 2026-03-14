import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:pagamentos/presentation/bloc/pagamentos_avulsos_bloc/pagamentos_avulsos_bloc.dart';
import 'package:pagamentos/presentation/pages/pagamento_avulso_page.dart';
import 'package:pagamentos/presentation/pages/pagamento_avulso_detalhes_page.dart';

class PagamentosAvulsosPage extends StatelessWidget {
  const PagamentosAvulsosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PagamentosAvulsosBloc>(
      create: (_) =>
          sl<PagamentosAvulsosBloc>()..add(PagamentosAvulsosIniciou()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pagamentos avulsos'),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  tooltip: 'Atualizar pagamentos',
                  onPressed: () {
                    context
                        .read<PagamentosAvulsosBloc>()
                        .add(PagamentosAvulsosIniciou());
                  },
                  icon: const Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Novo pagamento avulso',
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PagamentoAvulsoPage(),
              ),
            );

            if (context.mounted) {
              context
                  .read<PagamentosAvulsosBloc>()
                  .add(PagamentosAvulsosIniciou());
            }
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<PagamentosAvulsosBloc, PagamentosAvulsosState>(
          builder: (context, state) {
            if (state.step == PagamentosAvulsosStep.inicial ||
                state.step == PagamentosAvulsosStep.carregando) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state.step == PagamentosAvulsosStep.falha) {
              return Center(
                child: Text(state.erro ?? 'Erro ao carregar pagamentos.'),
              );
            }

            if (state.pagamentos.isEmpty) {
              return const Center(
                child: Text('Nenhum pagamento avulso encontrado.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.pagamentos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = state.pagamentos[index];
                final status = (item.status ?? '').toLowerCase();
                final statusColor = _statusColor(context, status);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: statusColor, width: 1.2),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PagamentoAvulsoDetalhesPage(
                            pagamento: item,
                          ),
                        ),
                      );
                    },
                    title: Text(item.description),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Forma: ${_providerLabel(item.provider)}'),
                        const SizedBox(height: 4),
                        if (item.pagoEm != null)
                          Text(
                            'Pago às: ${_formatarDataHora(item.pagoEm)}',
                          ),
                        if (item.criadoEm != null)
                          Text(
                            'Criado às: ${_formatarDataHora(item.criadoEm ?? item.atualizadoEm)}',
                          ),
                        const SizedBox(height: 6),
                        _statusChip(status),
                      ],
                    ),
                    trailing: Text(
                      'R\$ ${(item.amount / 100).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    if (status == 'paid') {
      return Colors.green.shade600;
    }
    if (status == 'pending') {
      return Colors.orange.shade700;
    }
    return Theme.of(context).colorScheme.outline;
  }

  Widget _statusChip(String status) {
    final isPago = status == 'paid';
    final isPendente = status == 'pending';

    final color = isPago
        ? Colors.green.shade600
        : isPendente
            ? Colors.orange.shade700
            : Colors.blueGrey;
    final label = isPago
        ? 'Pago'
        : isPendente
            ? 'Pendente'
            : (status.isEmpty ? 'Sem status' : status);
    final icon = isPago
        ? Icons.check_circle
        : isPendente
            ? Icons.schedule
            : Icons.info_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _providerLabel(String provider) {
    if (provider == 'infinitypay') {
      return 'InfinityPay';
    }
    if (provider == 'openpix') {
      return 'OpenPix';
    }
    return provider;
  }

  String _formatarDataHora(DateTime? data) {
    if (data == null) {
      return '-';
    }

    final local = data.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final ano = local.year.toString();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto';
  }
}
