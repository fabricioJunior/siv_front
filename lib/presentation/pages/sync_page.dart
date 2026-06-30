import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  void _confirmarReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zerar sincronização incremental?'),
        content: const Text(
          'Isso apagará o histórico de sincronização e o app buscará todos os dados novamente como se fosse a primeira vez. O processo pode ser mais demorado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              sl<SyncDataBloc>().add(const SyncDataSolicitouResetIncremental());
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Zerar e sincronizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SyncDataBloc>.value(
      value: sl<SyncDataBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sincronização de dados')),
        body: BlocBuilder<SyncDataBloc, SyncDataState>(
          builder: (context, state) {
            final modulos = state.modulos.values.toList()
              ..sort((a, b) => a.modulo.index.compareTo(b.modulo.index));

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              children: [
                _ResumoCard(state: state),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _confirmarReset(context),
                  icon: const Icon(Icons.restore, color: Colors.orange),
                  label: const Text(
                    'Zerar sincronização incremental',
                    style: TextStyle(color: Colors.orange),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Módulos',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                for (final modulo in modulos) ...[
                  _CardModulo(modulo: modulo),
                  const SizedBox(height: 10),
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

String _fmtDt(DateTime? dt) {
  if (dt == null) return '-';
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  final s = dt.second.toString().padLeft(2, '0');
  return '$d/$m/${dt.year} $h:$min:$s';
}

class _ResumoCard extends StatelessWidget {
  final SyncDataState state;
  const _ResumoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final sincronizando = state.sincronizando;
    final cor = sincronizando ? Colors.blue : Colors.green;

    final statusLabel = sincronizando
        ? 'Sincronização em andamento...'
        : state.finalizadoEm != null
        ? 'Última sincronização concluída'
        : 'Aguardando sincronização';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (sincronizando) ...[
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cor,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          Icon(
                            state.finalizadoEm != null
                                ? Icons.check_circle_outline
                                : Icons.schedule,
                            size: 18,
                            color: cor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            statusLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.iniciadoEm != null)
                      _InfoRow(
                        label: 'Início',
                        value: _fmtDt(state.iniciadoEm),
                      ),
                    if (state.finalizadoEm != null)
                      _InfoRow(label: 'Fim', value: _fmtDt(state.finalizadoEm)),
                    if (state.origemUltimaSincronizacao != null)
                      _InfoRow(
                        label: 'Origem',
                        value: _origemLabel(state.origemUltimaSincronizacao),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _origemLabel(SyncDataOrigem? origem) => switch (origem) {
    SyncDataOrigem.home => 'Automática (home)',
    SyncDataOrigem.entradaDeProdutos => 'Entrada de produtos',
    SyncDataOrigem.manual => 'Manual',
    _ => '-',
  };
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardModulo extends StatelessWidget {
  final SyncModuloState modulo;
  const _CardModulo({required this.modulo});

  Color get _cor => switch (modulo.status) {
    SyncModuloStatus.aguardando => Colors.grey,
    SyncModuloStatus.sincronizando => Colors.blue,
    SyncModuloStatus.concluido => Colors.green,
    SyncModuloStatus.falha => Colors.red,
  };

  String get _statusLabel => switch (modulo.status) {
    SyncModuloStatus.aguardando => 'Aguardando',
    SyncModuloStatus.sincronizando => 'Sincronizando',
    SyncModuloStatus.concluido => 'Concluído',
    SyncModuloStatus.falha => 'Falha',
  };

  @override
  Widget build(BuildContext context) {
    final cor = _cor;
    final progresso = modulo.progresso;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            modulo.nomeModulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 6,
                        backgroundColor: cor.withValues(alpha: 0.12),
                        color: cor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoRow(
                            label: 'Páginas',
                            value:
                                '${modulo.paginasSincronizadas}/${modulo.totalPaginas == 0 ? '-' : modulo.totalPaginas}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _InfoRow(
                            label: 'Itens',
                            value:
                                '${modulo.itensSincronizados}/${modulo.totalItens}',
                          ),
                        ),
                      ],
                    ),
                    if (modulo.atualizadoEm != null)
                      _InfoRow(
                        label: 'Atualizado',
                        value: _fmtDt(modulo.atualizadoEm),
                      ),
                    if (modulo.erro != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              modulo.erro!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
