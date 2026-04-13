import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/terminais_do_usuario_bloc/terminais_do_usuario_bloc.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class TerminaisDoUsuarioPage extends StatelessWidget {
  final int idUsuario;

  const TerminaisDoUsuarioPage({super.key, required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TerminaisDoUsuarioBloc>()
        ..add(TerminaisDoUsuarioIniciou(idUsuario: idUsuario)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Terminais do Usuário')),
        floatingActionButton:
            BlocBuilder<TerminaisDoUsuarioBloc, TerminaisDoUsuarioState>(
          builder: (context, state) {
            if (state is TerminaisDoUsuarioCarregarSucesso ||
                state is TerminaisDoUsuarioVincularSucesso ||
                state is TerminaisDoUsuarioDesvincularSucesso) {
              return FloatingActionButton(
                onPressed: () => _onAdicionarTerminal(context, state.empresas),
                child: const Icon(Icons.add),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        body: SafeArea(
          child: BlocBuilder<TerminaisDoUsuarioBloc, TerminaisDoUsuarioState>(
            builder: (context, state) {
              final theme = Theme.of(context);

              if (state is TerminaisDoUsuarioCarregarEmProgresso ||
                  state is TerminaisDoUsuarioVincularEmProgresso ||
                  state is TerminaisDoUsuarioDesvincularEmProgresso) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TerminaisDoUsuarioCarregarFalha) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Falha ao carregar os terminais do usuário.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                );
              }

              if (state.terminais.isEmpty) {
                return _emptyState(context);
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                itemCount: state.terminais.length + 1,
                separatorBuilder: (_, index) {
                  if (index == 0) {
                    return const SizedBox(height: 12);
                  }
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Text(
                      'Terminais vinculados',
                      style: theme.textTheme.titleMedium,
                    );
                  }

                  final terminal = state.terminais[index - 1];
                  return _terminalCard(context, terminal, state.empresas);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.point_of_sale_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum terminal vinculado.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para associar um terminal a este usuário.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _terminalCard(
    BuildContext context,
    TerminalDoUsuario terminal,
    List<Empresa> empresas,
  ) {
    final theme = Theme.of(context);
    final empresa =
        empresas.where((item) => item.id == terminal.idEmpresa).firstOrNull;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.devices_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(terminal.nome),
        subtitle: Text(empresa?.nome ?? 'Empresa ${terminal.idEmpresa}'),
        trailing: IconButton(
          tooltip: 'Remover vínculo',
          onPressed: () {
            context.read<TerminaisDoUsuarioBloc>().add(
                  TerminaisDoUsuarioDesvinculou(idTerminal: terminal.id),
                );
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }

  Future<void> _onAdicionarTerminal(
    BuildContext context,
    List<Empresa> empresas,
  ) async {
    final bloc = context.read<TerminaisDoUsuarioBloc>();
    final empresa = await _EmpresasModal.show(context, empresas);

    if (empresa == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final terminal = await _TerminaisModal.show(context, empresa: empresa);

    if (terminal == null) {
      return;
    }

    bloc.add(
      TerminaisDoUsuarioVinculou(
        idTerminal: terminal.id,
        idEmpresa: empresa.id,
      ),
    );
  }
}

class _EmpresasModal extends StatelessWidget {
  final List<Empresa> empresas;

  const _EmpresasModal({required this.empresas});

  static Future<Empresa?> show(
    BuildContext context,
    List<Empresa> empresas,
  ) async {
    if (empresas.length == 1) {
      return empresas.first;
    }

    return showModalBottomSheet<Empresa>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _EmpresasModal(empresas: empresas),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Selecione a empresa do terminal:'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: empresas.length,
              itemBuilder: (context, index) {
                final empresa = empresas[index];
                return ListTile(
                  title: Text(empresa.nome),
                  onTap: () => Navigator.of(context).pop(empresa),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminaisModal extends StatelessWidget {
  final Empresa empresa;

  const _TerminaisModal({required this.empresa});

  static Future<TerminalDoUsuario?> show(
    BuildContext context, {
    required Empresa empresa,
  }) {
    return showModalBottomSheet<TerminalDoUsuario>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _TerminaisModal(empresa: empresa),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 480,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: FutureBuilder<List<TerminalDoUsuario>>(
          future: sl<RecuperarTerminaisDaEmpresa>().call(idEmpresa: empresa.id),
          builder: (context, snapshot) {
            final terminais = snapshot.data ?? const <TerminalDoUsuario>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Selecione o terminal',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  empresa.nome,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Falha ao carregar os terminais da empresa.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  )
                else if (terminais.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Nenhum terminal disponível para esta empresa.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: terminais.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final terminal = terminais[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: const Icon(Icons.devices_outlined),
                            title: Text(terminal.nome),
                            subtitle: Text('ID ${terminal.id}'),
                            onTap: () => Navigator.of(context).pop(terminal),
                          ),
                        );
                      },
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
