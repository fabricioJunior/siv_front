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
          title: const Text('Usuarios'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BlocBuilder<UsuariosBloc, UsuariosState>(
                builder: (context, state) {
                  if (state is UsuariosCarregarEmProgresso) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator.adaptive(),
                      ],
                    );
                  }
                  if (state is UsuariosCarregarFalha) {
                    return const Text('Falha ao carregar usuários');
                  }
                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.usuarios.length,
                      itemBuilder: (context, index) {
                        var usuario = state.usuarios[index];
                        return _usuarioCard(context, usuario);
                      },
                    ),
                  );
                },
              )
            ],
          ),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          usuario.nome,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Text(usuario.tipo.nome)
                    ],
                  ),
                  Row(
                    children: [Text(usuario.login)],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
