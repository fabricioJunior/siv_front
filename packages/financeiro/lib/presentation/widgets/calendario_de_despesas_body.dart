import 'package:core/bloc.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class CalendarioDeDespesasBody extends StatelessWidget {
  const CalendarioDeDespesasBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarioDeDespesasBloc, CalendarioDeDespesasState>(
      builder: (context, state) {
        if (state.step == CalendarioDeDespesasStep.inicial ||
            state.step == CalendarioDeDespesasStep.carregando) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state.step == CalendarioDeDespesasStep.falha) {
          return const Center(child: Text('Falha ao carregar o calendário.'));
        }

        if (state.ocorrencias.isEmpty) {
          return const Center(child: Text('Nenhum pagamento no mês.'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: state.porDia.entries
              .map(
                (entrada) => _DiaDoCalendario(
                  dia: entrada.key,
                  ocorrencias: entrada.value,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DiaDoCalendario extends StatelessWidget {
  final int dia;
  final List<DespesaOcorrenciaCalendario> ocorrencias;

  const _DiaDoCalendario({required this.dia, required this.ocorrencias});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dia $dia',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          ...ocorrencias.map((ocorrencia) => _CardOcorrencia(ocorrencia: ocorrencia)),
        ],
      ),
    );
  }
}

class _CardOcorrencia extends StatelessWidget {
  final DespesaOcorrenciaCalendario ocorrencia;

  const _CardOcorrencia({required this.ocorrencia});

  Color _corDoStatus(BuildContext context) {
    switch (ocorrencia.status) {
      case StatusDespesa.pago:
        return Colors.green;
      case StatusDespesa.cancelado:
        return Colors.grey;
      case StatusDespesa.pendente:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _corDoStatus(context).withValues(alpha: 0.15),
          child: Icon(Icons.receipt_long, color: _corDoStatus(context)),
        ),
        title: Text(ocorrencia.descricao),
        subtitle: Text(
          'R\$${ocorrencia.valor.toStringAsFixed(2)} • ${ocorrencia.status.label}'
          '${ocorrencia.virtual ? ' (recorrente, não lançada)' : ''}',
        ),
        onTap: () => _abrirAcoes(context),
      ),
    );
  }

  void _abrirAcoes(BuildContext context) {
    final bloc = context.read<CalendarioDeDespesasBloc>();
    final id = ocorrencia.idParaOcorrencia;
    if (id == null) return;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ocorrencia.status != StatusDespesa.pago)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Marcar como pago'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  bloc.add(
                    CalendarioDeDespesasOcorrenciaRegistrada(
                      id: id,
                      status: StatusDespesa.pago,
                      dataPagamento: ocorrencia.dataPagamento,
                    ),
                  );
                },
              ),
            if (ocorrencia.status != StatusDespesa.cancelado)
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Cancelar'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  bloc.add(
                    CalendarioDeDespesasOcorrenciaRegistrada(
                      id: id,
                      status: StatusDespesa.cancelado,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
