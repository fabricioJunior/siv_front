import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class RomaneiosPage extends StatelessWidget {
  const RomaneiosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RomaneiosBloc>(
      create: (_) => sl<RomaneiosBloc>()..add(RomaneiosIniciou()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Romaneios')),
            floatingActionButton: BlocBuilder<RomaneiosBloc, RomaneiosState>(
              builder: (context, state) {
                final carregando = state.step == RomaneiosStep.carregando;
                return FloatingActionButton.extended(
                  onPressed: carregando
                      ? null
                      : () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/romaneio',
                          );
                          if (result == true && context.mounted) {
                            context
                                .read<RomaneiosBloc>()
                                .add(RomaneiosIniciou());
                          }
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('Novo'),
                );
              },
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<RomaneiosBloc>().add(RomaneiosIniciou());
              },
              child: BlocBuilder<RomaneiosBloc, RomaneiosState>(
                builder: (context, state) {
                  final totalRomaneios = state.romaneios.length;
                  final totalPendentes = state.itensPendentesPorRomaneio.length;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _RomaneiosHeader(
                        totalRomaneios: totalRomaneios,
                        totalPendentes: totalPendentes,
                      ),
                      const SizedBox(height: 16),
                      if (state.step == RomaneiosStep.carregando)
                        const _EstadoListaCard(
                          icon: Icons.hourglass_top_rounded,
                          titulo: 'Carregando romaneios',
                          descricao:
                              'Aguarde enquanto os dados são atualizados.',
                          child: CircularProgressIndicator.adaptive(),
                        )
                      else if (state.step == RomaneiosStep.falha)
                        _EstadoListaCard(
                          icon: Icons.error_outline,
                          titulo: 'Falha ao carregar',
                          descricao: state.erro ??
                              'Não foi possível carregar os romaneios.',
                        )
                      else if (state.romaneios.isEmpty)
                        const _EstadoListaCard(
                          icon: Icons.inventory_2_outlined,
                          titulo: 'Nenhum romaneio encontrado',
                          descricao:
                              'Crie um novo romaneio para começar a movimentação.',
                        )
                      else ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Lista de romaneios',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        ...state.romaneios.map((romaneio) {
                          final romaneioId = romaneio.id;
                          final itensPendentes = romaneioId == null
                              ? 0
                              : (state.itensPendentesPorRomaneio[romaneioId] ??
                                  0);
                          final possuiPendencia = itensPendentes > 0;

                          return _RomaneioCard(
                            romaneio: romaneio,
                            possuiPendencia: possuiPendencia,
                            itensPendentes: itensPendentes,
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/romaneio',
                                arguments: {
                                  'idRomaneio': romaneio.id,
                                  'permitirEdicao': false,
                                },
                              );
                              if (result == true && context.mounted) {
                                context.read<RomaneiosBloc>().add(
                                      RomaneiosIniciou(),
                                    );
                              }
                            },
                          );
                        }),
                      ],
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RomaneiosHeader extends StatelessWidget {
  final int totalRomaneios;
  final int totalPendentes;

  const _RomaneiosHeader({
    required this.totalRomaneios,
    required this.totalPendentes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    colorScheme.onPrimaryContainer.withValues(alpha: 0.10),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acompanhamento de romaneios',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Visualize rapidamente o status de envio e os romaneios com pendência.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.90),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ResumoChip(
                icon: Icons.receipt_long_outlined,
                label: '$totalRomaneios romaneio(s)',
              ),
              _ResumoChip(
                icon: totalPendentes > 0
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                label: totalPendentes > 0
                    ? '$totalPendentes com pendência'
                    : 'Todos enviados',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ResumoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _EstadoListaCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;
  final Widget? child;

  const _EstadoListaCard({
    required this.icon,
    required this.titulo,
    required this.descricao,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (child != null) ...[
              child!,
              const SizedBox(height: 16),
            ] else ...[
              Icon(icon, size: 42),
              const SizedBox(height: 12),
            ],
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RomaneioCard extends StatelessWidget {
  final Romaneio romaneio;
  final bool possuiPendencia;
  final int itensPendentes;
  final VoidCallback onTap;

  const _RomaneioCard({
    required this.romaneio,
    required this.possuiPendencia,
    required this.itensPendentes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = possuiPendencia ? colorScheme.error : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    child: Icon(
                      possuiPendencia
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Romaneio #${romaneio.id ?? '-'}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pessoa: ${romaneio.pessoaNome ?? romaneio.pessoaId ?? '-'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.outline),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ResumoChip(
                    icon: Icons.swap_horiz_rounded,
                    label: romaneio.operacao?.descricao ?? 'Sem operação',
                  ),
                  _ResumoChip(
                    icon: Icons.inventory_2_outlined,
                    label: romaneio.situacao ?? 'Sem situação',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  possuiPendencia
                      ? 'Envio pendente: $itensPendentes item(ns) ainda não foram enviados ao servidor.'
                      : 'Envio concluído com sucesso.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
