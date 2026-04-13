import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/grupos_de_acesso_bloc/grupos_de_acesso_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

import '../bloc/usuario_bloc/usuario_bloc.dart';

// ignore: must_be_immutable
class UsuarioPage extends StatelessWidget {
  final int? idUsuario;
  var formKey = GlobalKey<FormState>();
  UsuarioPage({required this.idUsuario, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UsuarioBloc>(
          create: (context) => sl<UsuarioBloc>()
            ..add(UsuarioIniciou(
              idUsuario: idUsuario,
            )),
        ),
        BlocProvider(
          create: (context) => sl<GruposDeAcessoBloc>()
            ..add(
              const GruposDeAcessoIniciouEvent(),
            ),
        ),
      ],
      child: BlocListener<UsuarioBloc, UsuarioState>(
        listener: (context, state) {
          if (state is UsuarioSalvarSucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Usuário salvo com sucesso.')),
            );
          }
          if (state is UsuarioSalvarFalha) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Falha ao salvar o usuário.')),
            );
          }
        },
        child: Scaffold(
          floatingActionButton: _floatActionButton(),
          appBar: AppBar(
            title: Text(idUsuario == null ? 'Novo usuário' : 'Editar usuário'),
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BlocBuilder<UsuarioBloc, UsuarioState>(
                      builder: (context, state) {
                        final usuarioId = idUsuario ??
                            context.read<UsuarioBloc>().state.usuario?.id;
                        final podeAbrirVinculos = usuarioId != null;

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: !podeAbrirVinculos
                                  ? null
                                  : () {
                                      Navigator.of(context).pushNamed(
                                        '/vinculos_grupo_de_acesso_com_usuario',
                                        arguments: {'idUsuario': usuarioId},
                                      );
                                    },
                              icon: const Icon(Icons.groups_2_outlined),
                              label: const Text('Grupos de Acesso'),
                            ),
                            TextButton.icon(
                              onPressed: !podeAbrirVinculos
                                  ? null
                                  : () {
                                      Navigator.of(context).pushNamed(
                                        '/vinculos_terminais_com_usuario',
                                        arguments: {'idUsuario': usuarioId},
                                      );
                                    },
                              icon: const Icon(Icons.point_of_sale_outlined),
                              label: const Text('Terminais'),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<UsuarioBloc, UsuarioState>(
                      buildWhen: (previous, current) =>
                          previous is! UsuarioEditarEmProgresso,
                      builder: (context, state) {
                        if (state is UsuarioCarregarFalha) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  const Text('Falha ao carregar usuário'),
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    onPressed: () {
                                      context.read<UsuarioBloc>().add(
                                            UsuarioIniciou(
                                                idUsuario: idUsuario),
                                          );
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Tentar novamente'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (state is UsuarioCarregarSucesso ||
                            state is UsuarioEditarEmProgresso ||
                            state is UsuarioSalvarSucesso) {
                          return _usuarioInfos(
                            context,
                            state.usuario,
                            state is! UsuarioEditarEmProgresso,
                          );
                        }
                        if (state is UsuarioCarregarEmProgresso) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        }
                        return _usuarioInfos(context, null, false);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _floatActionButton() => BlocBuilder<UsuarioBloc, UsuarioState>(
        builder: (context, state) {
          if (state is UsuarioCarregarEmProgresso) {
            return const SizedBox();
          }
          if (state is UsuarioSalvarEmProgresso) {
            return const FloatingActionButton(
              tooltip: 'salvando',
              onPressed: null,
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return FloatingActionButton(
            tooltip: 'Edição',
            onPressed: () {
              if (state is! UsuarioEditarEmProgresso) {
                context.read<UsuarioBloc>().add(UsuarioEditou());
              } else if (formKey.currentState!.validate()) {
                context.read<UsuarioBloc>().add(UsuarioSalvou());
              }
            },
            child: Icon(
              state is! UsuarioEditarEmProgresso ? Icons.edit : Icons.check,
            ),
          );
        },
      );

  Widget _usuarioInfos(BuildContext context, Usuario? usuario, bool readOnly) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nome'),
              TextFormField(
                readOnly: readOnly,
                key: const Key('nome_page_nome_text_field'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  prefixText: '${usuario?.id.toString()}  ',
                ),
                controller: TextEditingController.fromValue(
                  usuario == null ? null : TextEditingValue(text: usuario.nome),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe um nome de usuário';
                  }
                  return null;
                },
                onChanged: (value) {
                  context.read<UsuarioBloc>().add(UsuarioEditou(nome: value));
                },
              ),
              const SizedBox(
                height: 32,
              ),
              const Text('Usuário'),
              TextFormField(
                readOnly: readOnly || usuario != null,
                key: const Key('usuario_page_nome_text_field'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: TextEditingController.fromValue(
                  usuario == null
                      ? null
                      : TextEditingValue(text: usuario.login),
                ),
                onChanged: (value) {
                  context.read<UsuarioBloc>().add(UsuarioEditou(login: value));
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o login do usuário';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 32,
              ),
              const Text('Senha'),
              TextFormField(
                readOnly: readOnly,
                key: const Key('usuario_page_senha_text_field'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  context.read<UsuarioBloc>().add(UsuarioEditou(senha: value));
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha do usuário';
                  }
                  return null;
                },
              ),
              if (usuario == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Confirmar senha'),
                    TextFormField(
                      readOnly: readOnly,
                      key: const Key('usuario_page_confirmar_senha_text_field'),
                      obscureText: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {
                        context
                            .read<UsuarioBloc>()
                            .add(UsuarioEditou(senha: value));
                      },
                      validator: (value) {
                        var state = context.read<UsuarioBloc>().state;
                        String? senha = state is UsuarioEditarEmProgresso
                            ? state.senha
                            : null;
                        if (value != senha) {
                          return 'As senhas não são iguais';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              const SizedBox(
                height: 16,
              ),
              const Text('Tipo do usuário'),
              BlocBuilder<UsuarioBloc, UsuarioState>(
                builder: (context, state) {
                  return DropdownButton<TipoUsuario>(
                    items: TipoUsuario.values
                        .map(
                          (tipo) => DropdownMenuItem<TipoUsuario>(
                            value: tipo,
                            child: Text(
                              tipo.nome,
                            ),
                          ),
                        )
                        .toList(),
                    value: state is UsuarioEditarEmProgresso
                        ? state.tipo ?? TipoUsuario.padrao
                        : (usuario?.tipo),
                    onChanged: readOnly
                        ? null
                        : (value) {
                            if (value != null) {
                              context.read<UsuarioBloc>().add(
                                    UsuarioEditou(tipo: value),
                                  );
                            }
                          },
                  );
                },
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
