import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

const _nomesDosMeses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho',
  'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

class CalendarioDeDespesasPage extends StatelessWidget {
  const CalendarioDeDespesasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

    return BlocProvider<CalendarioDeDespesasBloc>(
      create: (_) => sl<CalendarioDeDespesasBloc>()
        ..add(CalendarioDeDespesasIniciou(empresaId: empresaId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Calendário de pagamentos')),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result =
                await Navigator.of(context).pushNamed('/lancar_despesa');
            if (result == true && context.mounted) {
              final state = context.read<CalendarioDeDespesasBloc>().state;
              context.read<CalendarioDeDespesasBloc>().add(
                    CalendarioDeDespesasMesAlterado(
                      ano: state.ano,
                      mes: state.mes,
                    ),
                  );
            }
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<CalendarioDeDespesasBloc, CalendarioDeDespesasState>(
          builder: (context, state) {
            if (state.step == CalendarioDeDespesasStep.inicial) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                _CabecalhoMes(ano: state.ano, mes: state.mes),
                if (state.step == CalendarioDeDespesasStep.carregando)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (state.step == CalendarioDeDespesasStep.falha)
                  const Expanded(
                    child: Center(child: Text('Falha ao carregar o calendário.')),
                  )
                else if (state.ocorrencias.isEmpty)
                  const Expanded(
                    child: Center(child: Text('Nenhum pagamento no mês.')),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: state.porDia.entries
                          .map(
                            (entrada) => _DiaDoCalendario(
                              dia: entrada.key,
                              ocorrencias: entrada.value,
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CabecalhoMes extends StatelessWidget {
  final int ano;
  final int mes;

  const _CabecalhoMes({required this.ano, required this.mes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _navegar(context, -1),
          ),
          Text(
            '${_nomesDosMeses[mes - 1]} / $ano',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _navegar(context, 1),
          ),
        ],
      ),
    );
  }

  void _navegar(BuildContext context, int delta) {
    var novoMes = mes + delta;
    var novoAno = ano;
    if (novoMes > 12) {
      novoMes = 1;
      novoAno++;
    } else if (novoMes < 1) {
      novoMes = 12;
      novoAno--;
    }
    context.read<CalendarioDeDespesasBloc>().add(
          CalendarioDeDespesasMesAlterado(ano: novoAno, mes: novoMes),
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
