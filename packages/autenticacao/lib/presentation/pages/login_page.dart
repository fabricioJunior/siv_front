import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final bloc = sl<LoginBloc>();

    return Scaffold(
      key: const Key('login_page_key'),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Text('SIV - Login'),
              TextFormField(
                key: const Key('login_page_user_input'),
                decoration: const InputDecoration(labelText: 'Usuário'),
                onChanged: (value) {
                  bloc.add(LoginAdicionouUsuario(usuario: value));
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o usuário';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('login_page_user_senha'),
                decoration: const InputDecoration(labelText: 'Senha'),
                onChanged: (value) {
                  bloc.add(LoginAdicionouSenha(senha: value));
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha para continuar';
                  }
                  return null;
                },
              ),
              BlocBuilder<LoginBloc, LoginState>(
                  bloc: bloc,
                  builder: (context, state) {
                    if (state is! LoginAutenticarFalha) {
                      return const SizedBox();
                    }
                    return Text(state.erro);
                  }),
              ElevatedButton(
                key: const Key('login_page_entrar_button'),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    bloc.add(LoginAutenticou());
                  }
                },
                child: const Text('ENTRAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
