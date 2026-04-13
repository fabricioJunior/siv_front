import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

import '../../domain/models/usuario.dart';
import '../bloc/usuarios_bloc/usuarios_bloc.dart';

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsuariosBloc>(
      create: (context) => sl<UsuariosBloc>()..add(UsuariosIniciou()),
      child: Scaffold(
        floatingActionButton: _newUserButton(context),
        appBar: AppBar(
          title: const Text('Usuários'),
          actions: [
            IconButton(
              tooltip: 'Atualizar',
              onPressed: () {
                context.read<UsuariosBloc>().add(UsuariosIniciou());
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<UsuariosBloc, UsuariosState>(
          builder: (context, state) {
            if (state is UsuariosCarregarEmProgresso) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is UsuariosCarregarFalha) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 42),
                      const SizedBox(height: 12),
                      const Text('Falha ao carregar usuários'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<UsuariosBloc>().add(UsuariosIniciou());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.usuarios.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Nenhum usuário cadastrado. Toque em + para criar o primeiro usuário.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: state.usuarios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final usuario = state.usuarios[index];
                return _usuarioCard(context, usuario);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _newUserButton(BuildContext _) =>
      BlocBuilder<UsuariosBloc, UsuariosState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed(
                '/usuario',
              );
              // ignore: use_build_context_synchronously
              context.read<UsuariosBloc>().add(UsuariosIniciou());
            },
            child: const Icon(Icons.add),
          );
        },
      );

  Widget _usuarioCard(BuildContext context, Usuario usuario) => Ink(
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).pushNamed('/usuario', arguments: {
              'idUsuario': usuario.id,
            });
            // ignore: use_build_context_synchronously
            context.read<UsuariosBloc>().add(UsuariosIniciou());
          },
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                child: Text(
                  usuario.nome.isEmpty
                      ? '?'
                      : usuario.nome.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Text(
                usuario.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('${usuario.login} • ${usuario.tipo.nome}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      );
}
