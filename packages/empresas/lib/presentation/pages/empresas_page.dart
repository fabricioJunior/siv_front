import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/empresa.dart';
import '../blocs/empresas_bloc/empresas_bloc.dart';

class EmpresasPage extends StatelessWidget {
  const EmpresasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmpresasBloc>(
      create: (context) => sl<EmpresasBloc>()..add(EmpresasIniciou()),
      child: Scaffold(
        floatingActionButton: _novaEmpresaButton(context),
        appBar: AppBar(
          title: const Text('Empresas'),
          actions: [
            IconButton(
              tooltip: 'Atualizar',
              onPressed: () {
                context.read<EmpresasBloc>().add(EmpresasIniciou());
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<EmpresasBloc, EmpresasState>(
          builder: (context, state) {
            if (state is EmpresasCarregarEmProgresso) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is EmpresasCarregarFalha) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business_center_outlined, size: 46),
                      const SizedBox(height: 12),
                      const Text('Falha ao carregar empresas.'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<EmpresasBloc>().add(EmpresasIniciou());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is EmpresasCarregarSucesso && state.empresas.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Nenhuma empresa cadastrada. Toque em + para criar uma empresa.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is EmpresasCarregarSucesso) {
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: state.empresas.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _empresaCard(context, state.empresas[index]);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _novaEmpresaButton(BuildContext _) =>
      BlocBuilder<EmpresasBloc, EmpresasState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed('/empresa');
              // ignore: use_build_context_synchronously
              context.read<EmpresasBloc>().add(EmpresasIniciou());
            },
            child: const Icon(Icons.add),
          );
        },
      );

  Widget _empresaCard(BuildContext context, Empresa empresa) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed('/empresa', arguments: {'idEmpresa': empresa.id});
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Text(
                    empresa.nome.isEmpty
                        ? '?'
                        : empresa.nome.substring(0, 1).toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empresa.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        empresa.nomeFantasia,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  icon: Icons.badge_outlined,
                  label: 'ID ${empresa.id ?? '-'}',
                ),
                _infoChip(icon: Icons.business_outlined, label: empresa.cnpj),
                if ((empresa.uf ?? '').isNotEmpty)
                  _infoChip(icon: Icons.map_outlined, label: empresa.uf!),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _infoChip({required IconData icon, required String label}) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
