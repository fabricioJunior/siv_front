import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SyncDataBloc>.value(
      value: sl<SyncDataBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sincronizacao de dados'),
        ),
        body: BlocBuilder<SyncDataBloc, SyncDataState>(
          builder: (context, state) {
            final modulos = state.modulos.values.toList()
              ..sort((a, b) => a.modulo.index.compareTo(b.modulo.index));

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ResumoSincronizacao(state: state),
                const SizedBox(height: 16),
                for (final modulo in modulos) ...[
                  _CardModulo(modulo: modulo),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            sl<SyncDataBloc>().add(
              const SyncDataSolicitouSincronizacao(
                origem: SyncDataOrigem.manual,
              ),
            );
          },
          icon: const Icon(Icons.sync),
          label: const Text('Sincronizar agora'),
        ),
      ),
    );
  }
}

class _ResumoSincronizacao extends StatelessWidget {
  final SyncDataState state;

  const _ResumoSincronizacao({required this.state});

  @override
  Widget build(BuildContext context) {
    final status = state.sincronizando
        ? 'Sincronizacao em andamento'
        : state.finalizadoEm != null
            ? 'Sincronizacao finalizada'
            : 'Aguardando sincronizacao';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Origem: ${_origemLabel(state.origemUltimaSincronizacao)}'),
            if (state.iniciadoEm != null) Text('Inicio: ${state.iniciadoEm}'),
            if (state.finalizadoEm != null) Text('Fim: ${state.finalizadoEm}'),
          ],
        ),
      ),
    );
  }

  String _origemLabel(SyncDataOrigem? origem) {
    switch (origem) {
      case SyncDataOrigem.home:
        return 'Home';
      case SyncDataOrigem.entradaDeProdutos:
        return 'Entrada de produtos';
      case SyncDataOrigem.manual:
        return 'Manual';
      default:
        return '-';
    }
  }
}

class _CardModulo extends StatelessWidget {
  final SyncModuloState modulo;

  const _CardModulo({required this.modulo});

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(modulo.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  modulo.nomeModulo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: _statusColor(modulo.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: modulo.progresso),
            const SizedBox(height: 8),
            Text(
              'Paginas sincronizadas: ${modulo.paginasSincronizadas} / ${modulo.totalPaginas == 0 ? '-' : modulo.totalPaginas}',
            ),
            Text(
              'Itens sincronizados: ${modulo.itensSincronizados} / ${modulo.totalItens}',
            ),
            if (modulo.atualizadoEm != null)
              Text('Atualizado em: ${modulo.atualizadoEm}'),
            if (modulo.erro != null) ...[
              const SizedBox(height: 8),
              Text(
                modulo.erro!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(SyncModuloStatus status) {
    switch (status) {
      case SyncModuloStatus.aguardando:
        return 'Aguardando';
      case SyncModuloStatus.sincronizando:
        return 'Sincronizando';
      case SyncModuloStatus.concluido:
        return 'Concluido';
      case SyncModuloStatus.falha:
        return 'Falha';
    }
  }

  Color _statusColor(SyncModuloStatus status) {
    switch (status) {
      case SyncModuloStatus.aguardando:
        return Colors.grey.shade200;
      case SyncModuloStatus.sincronizando:
        return Colors.blue.shade100;
      case SyncModuloStatus.concluido:
        return Colors.green.shade100;
      case SyncModuloStatus.falha:
        return Colors.red.shade100;
    }
  }
}
