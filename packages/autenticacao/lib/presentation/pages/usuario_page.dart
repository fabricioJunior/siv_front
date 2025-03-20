import 'package:autenticacao/models.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

import '../bloc/usuario_bloc/usuario_bloc.dart';

class UsuarioPage extends StatelessWidget {
  final int? idUsuario;
  const UsuarioPage({required this.idUsuario, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuário'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlocProvider(
                create: (context) => sl<UsuarioBloc>()
                  ..add(UsuarioIniciou(
                    idUsuario: idUsuario,
                  )),
                child: BlocBuilder<UsuarioBloc, UsuarioState>(
                  builder: (context, state) {
                    if (state is UsuarioCarregarFalha) {
                      return const Text('Falha ao carregar usuário');
                    }
                    if (state is UsuarioCarregarSucesso) {
                      return _usuarioInfos(state.usuario);
                    }
                    return const SizedBox();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _usuarioInfos(Usuario? usuario) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nome'),
              TextFormField(
                key: const Key('nome_page_nome_text_field'),
                decoration: InputDecoration(
                  prefixText: '${usuario?.id.toString()}  ',
                ),
                controller: TextEditingController.fromValue(
                  usuario == null ? null : TextEditingValue(text: usuario.nome),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              const Text('Usuário'),
              TextField(
                readOnly: true,
                key: const Key('usuario_page_nome_text_field'),
                controller: TextEditingController.fromValue(
                  usuario == null
                      ? null
                      : TextEditingValue(text: usuario.login),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              const Text('Senha'),
              TextField(
                readOnly: true,
                key: const Key('usuario_page_senha_text_field'),
                controller: TextEditingController.fromValue(
                  usuario == null
                      ? null
                      : const TextEditingValue(text: '*****'),
                ),
              ),
            ],
          ),
        ),
      );
}
