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
      body: BlocListener<LoginBloc, LoginState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is LoginAutenticarSucesso && state.idEmpresa == null) {
            Navigator.of(context).pushNamed('/selecionar_empresa');
          }
        },
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('SIV - Login'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 32,
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            key: const Key('login_page_user_input'),
                            decoration:
                                const InputDecoration(labelText: 'Usuário'),
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
                          SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            obscureText: true,
                            key: const Key('login_page_user_senha'),
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                            ),
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
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<LoginBloc, LoginState>(
                      bloc: bloc,
                      builder: (context, state) {
                        if (state is! LoginAutenticarFalha) {
                          return const SizedBox();
                        }
                        return Text(state.erro);
                      }),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
