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
    return _UsuarioFormulario(
      usuario: usuario,
      readOnly: readOnly,
      formKey: formKey,
    );
  }
}

// Controllers de texto precisam ser criados 1 vez só e reaproveitados --
// antes eram recriados via TextEditingController.fromValue(...) direto no
// build(), sempre a partir de `usuario` (o Usuario carregado, nunca o
// buffer de edição do bloc). Pra usuário novo, `usuario` é sempre null, e
// qualquer rebuild criava um controller vazio, apagando o que já tinha
// sido digitado -- exatamente o bug relatado ao trocar o tipo do usuário.
class _UsuarioFormulario extends StatefulWidget {
  final Usuario? usuario;
  final bool readOnly;
  final GlobalKey<FormState> formKey;

  const _UsuarioFormulario({
    required this.usuario,
    required this.readOnly,
    required this.formKey,
  });

  @override
  State<_UsuarioFormulario> createState() => _UsuarioFormularioState();
}

class _UsuarioFormularioState extends State<_UsuarioFormulario> {
  late final TextEditingController _nomeController;
  late final TextEditingController _loginController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario?.nome ?? '');
    _loginController = TextEditingController(text: widget.usuario?.login ?? '');
  }

  @override
  void didUpdateWidget(covariant _UsuarioFormulario oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Só sincroniza a partir do Usuario carregado/salvo quando ele
    // realmente mudou (ex: terminou de carregar, ou salvou com sucesso) --
    // nunca durante a digitação, já que trocar outro campo (tipo, ativo)
    // não muda `usuario`.
    if (oldWidget.usuario?.nome != widget.usuario?.nome) {
      _nomeController.text = widget.usuario?.nome ?? _nomeController.text;
    }
    if (oldWidget.usuario?.login != widget.usuario?.login) {
      _loginController.text = widget.usuario?.login ?? _loginController.text;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.usuario;
    final readOnly = widget.readOnly;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: widget.formKey,
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
                controller: _nomeController,
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
                controller: _loginController,
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
                  final state = context.read<UsuarioBloc>().state;
                  final inativandoUsuarioExistente =
                      usuario != null && state is UsuarioEditarEmProgresso;

                  if (inativandoUsuarioExistente) {
                    return null;
                  }

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
                                    UsuarioEditou(
                                      tipo: value,
                                      ativo: value == TipoUsuario.sysadmin
                                          ? true
                                          : null,
                                    ),
                                  );
                            }
                          },
                  );
                },
              ),
              const SizedBox(
                height: 16,
              ),
              BlocBuilder<UsuarioBloc, UsuarioState>(
                builder: (context, state) {
                  final tipoSelecionado = state is UsuarioEditarEmProgresso
                      ? (state.tipo ?? TipoUsuario.padrao)
                      : (usuario?.tipo ?? TipoUsuario.padrao);
                  final isSysadmin = tipoSelecionado == TipoUsuario.sysadmin;
                  bool ativo = state is UsuarioEditarEmProgresso
                      ? state.ativo
                      : (usuario?.ativo ?? true);

                  return SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: isSysadmin ? true : ativo,
                    onChanged: readOnly || isSysadmin
                        ? null
                        : (value) {
                            context.read<UsuarioBloc>().add(
                                  UsuarioEditou(ativo: value),
                                );
                          },
                    title: const Text('Usuário ativo'),
                    subtitle: Text(
                      isSysadmin
                          ? 'Usuário sysadmin não pode ser inativado.'
                          : (ativo ? 'Status: Ativo' : 'Status: Inativo'),
                    ),
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
