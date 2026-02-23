import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:autenticacao/presentation/bloc/grupos_de_acesso_bloc/grupos_de_acesso_bloc.dart';

class GruposDeAcessoPage extends StatelessWidget {
  const GruposDeAcessoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<GruposDeAcessoBloc>()..add(const GruposDeAcessoIniciouEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grupos de Acesso'),
        ),
        body: BlocBuilder<GruposDeAcessoBloc, GruposDeAcessoState>(
          builder: (context, state) {
            final theme = Theme.of(context);

            if (state is GruposDeAcessoCarregarEmProgresso) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is GruposDeAcessoCarregarSucesso) {
              final grupos = state.grupos;
              if (grupos.isEmpty) {
                return _emptyState(context);
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                itemCount: grupos.length + 1,
                separatorBuilder: (_, index) {
                  if (index == 0) {
                    return const SizedBox(height: 12);
                  }
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Text(
                      'Selecione um grupo para editar',
                      style: theme.textTheme.titleMedium,
                    );
                  }

                  final grupo = grupos[index - 1];
                  return _grupoDeAcessoCard(context, grupo);
                },
              );
            }

            if (state is GruposDeAcessoCarregarError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.mensagem,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              );
            }

            return _emptyState(context);
          },
        ),
        floatingActionButton:
            BlocBuilder<GruposDeAcessoBloc, GruposDeAcessoState>(
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/grupo_de_acesso');
                // ignore: use_build_context_synchronously
                context
                    .read<GruposDeAcessoBloc>()
                    .add(const GruposDeAcessoIniciouEvent());
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Widget _grupoDeAcessoCard(BuildContext context, GrupoDeAcesso grupo) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.security,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(grupo.nome),
        subtitle: Text('ID: ${grupo.id}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.pushNamed(context, '/grupo_de_acesso', arguments: {
            'idGrupoDeAcesso': grupo.id,
          });
          // ignore: use_build_context_synchronously
          context
              .read<GruposDeAcessoBloc>()
              .add(const GruposDeAcessoIniciouEvent());
        },
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
              Icons.groups_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum grupo de acesso cadastrado.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre o primeiro grupo para começar.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              key: const Key('grupos_de_acesso_cadastrar_button'),
              onPressed: () async {
                await Navigator.pushNamed(context, '/grupo_de_acesso');
                // ignore: use_build_context_synchronously
                context
                    .read<GruposDeAcessoBloc>()
                    .add(const GruposDeAcessoIniciouEvent());
              },
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar grupo'),
            ),
          ],
        ),
      ),
    );
  }
}
