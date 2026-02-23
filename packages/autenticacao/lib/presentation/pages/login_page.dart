import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:autenticacao/models.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final bloc = sl<LoginBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(LoginCarregouLicenciados());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 460,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 44,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'SIV',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Acesse sua conta',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  key: const Key('login_page_user_input'),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                      labelText: 'Usuário'),
                                  onChanged: (value) {
                                    bloc.add(
                                        LoginAdicionouUsuario(usuario: value));
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Informe o usuário';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  obscureText: true,
                                  key: const Key('login_page_user_senha'),
                                  textInputAction: TextInputAction.next,
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
                                const SizedBox(height: 16),
                                _licenciadoAutoComplete(),
                                const SizedBox(height: 12),
                                BlocBuilder<LoginBloc, LoginState>(
                                  bloc: bloc,
                                  builder: (context, state) {
                                    if (state is! LoginAutenticarFalha) {
                                      return const SizedBox.shrink();
                                    }

                                    return Text(
                                      state.erro,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.error,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                BlocBuilder<LoginBloc, LoginState>(
                                  bloc: bloc,
                                  builder: (context, state) {
                                    final emProgresso =
                                        state is LoginAutenticarEmProgresso;

                                    return SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        key: const Key(
                                            'login_page_entrar_button'),
                                        onPressed: emProgresso
                                            ? null
                                            : () {
                                                if (formKey.currentState
                                                        ?.validate() ??
                                                    false) {
                                                  bloc.add(LoginAutenticou());
                                                }
                                              },
                                        child: emProgresso
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text('ENTRAR'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  BlocBuilder<LoginBloc, LoginState> _licenciadoAutoComplete() {
    return BlocBuilder<LoginBloc, LoginState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is LoginCarregarLicenciadosEmProgresso) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        return FormField<Licenciado>(
          key: const Key('login_page_licenciado_input'),
          initialValue: state.licenciadoSelecionado,
          validator: (value) {
            if (value == null) {
              return 'Selecione o licenciado';
            }
            return null;
          },
          builder: (fieldState) {
            final licenciadoSelecionado = fieldState.value;
            final licenciados = state.licenciados ?? [];

            return Autocomplete<Licenciado>(
              displayStringForOption: (licenciado) => licenciado.nome,
              initialValue: TextEditingValue(
                text: licenciadoSelecionado?.nome ?? '',
              ),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return licenciados;
                }

                return licenciados.where((licenciado) {
                  return licenciado.nome.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                });
              },
              onSelected: (licenciado) {
                fieldState.didChange(licenciado);
                bloc.add(
                  LoginSelecionouLicenciado(
                    licenciado: licenciado,
                  ),
                );
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                if (licenciadoSelecionado != null &&
                    textEditingController.text != licenciadoSelecionado.nome) {
                  textEditingController.value = TextEditingValue(
                    text: licenciadoSelecionado.nome,
                    selection: TextSelection.collapsed(
                      offset: licenciadoSelecionado.nome.length,
                    ),
                  );
                }

                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Licenciado',
                    hintText: 'Digite para buscar',
                    errorText: fieldState.errorText,
                  ),
                  onFieldSubmitted: (_) {
                    onFieldSubmitted();
                  },
                  onChanged: (value) {
                    if (licenciadoSelecionado != null &&
                        value != licenciadoSelecionado.nome) {
                      fieldState.didChange(null);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
