import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final bool trocandoDeEmpresa;
  const LoginPage({super.key, this.trocandoDeEmpresa = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final bloc = sl<LoginBloc>();
  String? _empresaSelecionadaParaLogin;
  bool _senhaVisivel = false;

  @override
  void initState() {
    super.initState();
    if (widget.trocandoDeEmpresa) {
      bloc.add(LoginReiniciouSelecaoDeEmpresa());
    } else {
      bloc.add(LoginCarregouLicenciados());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;

    return Scaffold(
      key: const Key('login_page_key'),
      backgroundColor: cores.papel,
      body: BlocListener<LoginBloc, LoginState>(
        bloc: bloc,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);

          if (state is LoginAutenticarFalha) {
            if (mounted) {
              setState(() {
                _empresaSelecionadaParaLogin = null;
              });
            }
            SivAviso.mostrar(
              context,
              mensagem: state.erro,
              tipo: _isErroDeAviso(state.tipo)
                  ? SivAvisoTipo.atencao
                  : SivAvisoTipo.falha,
            );
          }

          if (state is LoginAutenticarSucesso && state.idEmpresa == null) {
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text(
                    'Login realizado. Escolha a empresa para continuar.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            _selecionarEmpresa(context);
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final duasColunas = constraints.maxWidth >= 900;

                  return Row(
                    children: [
                      if (duasColunas)
                        Expanded(child: _PainelDeMarca(cores: cores)),
                      SizedBox(
                        width: duasColunas ? 560 : constraints.maxWidth,
                        child: _formulario(context),
                      ),
                    ],
                  );
                },
              ),
              BlocBuilder<LoginBloc, LoginState>(
                bloc: bloc,
                builder: (context, state) {
                  final mostrandoIndicadorFinalizacao =
                      state is LoginAutenticarEmProgresso &&
                      state.idEmpresa != null;

                  if (!mostrandoIndicadorFinalizacao) {
                    return const SizedBox.shrink();
                  }

                  return Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    _empresaSelecionadaParaLogin == null
                                        ? 'Finalizando login...'
                                        : 'Entrando na empresa ${_empresaSelecionadaParaLogin!}...',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocBuilder<LoginBloc, LoginState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is LoginAutenticarSucesso && state.idEmpresa != null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Carregando dados'),
                SizedBox(height: 12),
                CircularProgressIndicator.adaptive(),
              ],
            ),
          );
        }
        if (widget.trocandoDeEmpresa) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SIV', style: textos.display.copyWith(fontSize: 40)),
                  const SizedBox(height: 4),
                  Text(
                    'Acesse sua conta pra continuar de onde parou.',
                    style: textos.corpo.copyWith(color: cores.textoApoio),
                  ),
                  const SizedBox(height: 28),
                  _licenciadoField(context),
                  const SizedBox(height: 16),
                  _campoTexto(
                    context,
                    key: const Key('login_page_user_input'),
                    label: 'Usuário',
                    onChanged: (value) =>
                        bloc.add(LoginAdicionouUsuario(usuario: value)),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Informe o usuário'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _campoSenha(context),
                  const SizedBox(height: 8),
                  // TODO: informação de "usuário tem acesso a mais de uma
                  // empresa" só fica disponível depois do login (lista de
                  // empresas vem em LoginAutenticarSucesso) -- não há como
                  // mostrar esse aviso ainda na tela de login.
                  const SizedBox(height: 12),
                  BlocBuilder<LoginBloc, LoginState>(
                    bloc: bloc,
                    builder: (context, state) {
                      final emProgresso = state is LoginAutenticarEmProgresso;

                      return SizedBox(
                        height: 48,
                        child: FilledButton(
                          key: const Key('login_page_entrar_button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: cores.acoEscuro,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SivDimensoes.raio,
                              ),
                            ),
                          ),
                          onPressed: emProgresso
                              ? null
                              : () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    bloc.add(LoginAutenticou());
                                  }
                                },
                          child: emProgresso
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Entrar',
                                  style: textos.rotulo.copyWith(
                                    color: cores.textoSobreEscuroTitulo,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Esqueceu a senha? Fale com o administrador',
                      style: textos.apoio.copyWith(color: cores.textoApoio),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      key: const Key(
                        'login_page_configuracao_dispositivo_button',
                      ),
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed('/configuracao_dispositivo'),
                      child: Text(
                        'Trocar terminal',
                        style: textos.apoio.copyWith(color: cores.aco),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _campoTexto(
    BuildContext context, {
    required Key key,
    required String label,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 60,
      child: TextFormField(
        key: key,
        obscureText: obscureText,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _campoSenha(BuildContext context) {
    return _campoTexto(
      context,
      key: const Key('login_page_user_senha'),
      label: 'Senha',
      obscureText: !_senhaVisivel,
      onChanged: (value) => bloc.add(LoginAdicionouSenha(senha: value)),
      validator: (value) => (value == null || value.isEmpty)
          ? 'Informe a senha para continuar'
          : null,
      suffixIcon: IconButton(
        icon: Icon(
          _senhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
        onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
      ),
    );
  }

  Widget _licenciadoField(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocBuilder<LoginBloc, LoginState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is LoginCarregarLicenciadosEmProgresso) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final licenciadoSelecionado = state.licenciadoSelecionado;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 60,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Licenciado'),
                  child: Text(
                    licenciadoSelecionado?.nome ?? 'Selecione o licenciado',
                    style: textos.corpo.copyWith(
                      color: licenciadoSelecionado == null
                          ? cores.textoDesabilitado
                          : cores.textoPrincipal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              key: const Key('login_page_trocar_licenciado_button'),
              onPressed: () => _trocarLicenciado(context, state.licenciados ?? const []),
              child: Text(
                'Trocar',
                style: textos.apoio.copyWith(color: cores.aco),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _trocarLicenciado(
    BuildContext context,
    List<Licenciado> licenciados,
  ) async {
    final selecionado = await Navigator.of(context).pushNamed(
      '/selecionar_licenciado',
      arguments: {'licenciados': licenciados},
    );

    if (!context.mounted || selecionado is! Licenciado) return;

    bloc.add(LoginSelecionouLicenciado(licenciado: selecionado));
  }

  Future<void> _selecionarEmpresa(BuildContext context) async {
    final resultado = await Navigator.of(
      context,
    ).pushNamed('/selecionar_empresa');

    if (!context.mounted) return;
    if (resultado is! Map) return;

    final idEmpresa = resultado['idEmpresa'];
    final nomeEmpresa = resultado['nomeEmpresa'];

    if (idEmpresa is! int) return;
    if (nomeEmpresa is! String || nomeEmpresa.trim().isEmpty) return;

    if (mounted) {
      setState(() {
        _empresaSelecionadaParaLogin = nomeEmpresa;
      });
    }

    // A tela de seleção de empresa já embute o painel de terminal (etapas 2
    // e 3 do fluxo, na mesma tela) -- se ela retornou um terminal, não
    // precisa buscar/perguntar de novo.
    final idTerminalRetornado = resultado['idTerminal'];
    final nomeTerminalRetornado = resultado['nomeTerminal'];
    TerminalDoUsuario? terminalSelecionado;
    if (idTerminalRetornado is int &&
        nomeTerminalRetornado is String &&
        nomeTerminalRetornado.trim().isNotEmpty) {
      terminalSelecionado = _TerminalSelecionado(
        id: idTerminalRetornado,
        idEmpresa: idEmpresa,
        nome: nomeTerminalRetornado,
      );
    } else {
      final terminaisDaEmpresa = await bloc.buscarTerminaisParaEmpresa(idEmpresa);

      if (!context.mounted) return;

      if (terminaisDaEmpresa.length == 1) {
        terminalSelecionado = terminaisDaEmpresa.first;
      } else if (terminaisDaEmpresa.length > 1) {
        terminalSelecionado = await _selecionarTerminal(
          context,
          terminaisDaEmpresa,
        );

        if (!context.mounted || terminalSelecionado == null) {
          return;
        }
      }
    }

    bloc.add(
      LoginAutenticou(
        empresa: _EmpresaSelecionada(id: idEmpresa, nome: nomeEmpresa),
        terminal: terminalSelecionado,
      ),
    );
  }

  Future<TerminalDoUsuario?> _selecionarTerminal(
    BuildContext context,
    List<TerminalDoUsuario> terminais,
  ) async {
    final resultado = await Navigator.of(context).pushNamed(
      '/selecionar_terminal',
      arguments: {'terminais': terminais},
    );

    if (!context.mounted || resultado is! Map) {
      return null;
    }

    final idTerminal = resultado['idTerminal'];
    final idEmpresa = resultado['idEmpresa'];
    final nomeTerminal = resultado['nomeTerminal'];

    if (idTerminal is! int || idEmpresa is! int) {
      return null;
    }

    if (nomeTerminal is! String || nomeTerminal.trim().isEmpty) {
      return null;
    }

    return _TerminalSelecionado(
      id: idTerminal,
      idEmpresa: idEmpresa,
      nome: nomeTerminal,
    );
  }

  bool _isErroDeAviso(LoginErroTipo tipo) {
    return tipo == LoginErroTipo.validacao ||
        tipo == LoginErroTipo.carregamentoEmpresas;
  }
}

class _PainelDeMarca extends StatelessWidget {
  final SivColors cores;

  const _PainelDeMarca({required this.cores});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;

    return Container(
      color: cores.acoEscuro,
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'SIV',
            style: textos.display.copyWith(color: cores.textoSobreEscuroTitulo),
          ),
          const SizedBox(height: 8),
          Text(
            'Vale do Ceará',
            style: textos.secao.copyWith(color: cores.ceu),
          ),
          const SizedBox(height: 20),
          Text(
            'Bora vender. Tudo o que a loja precisa, num lugar só.',
            style: textos.corpo.copyWith(color: cores.textoSobreEscuroApoio),
          ),
          const Spacer(),
          Divider(color: cores.textoSobreEscuroTerciario.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          // TODO: versão do app, terminal e última sincronização não estão
          // disponíveis antes do login (dependem de sessão/config de
          // dispositivo já autenticados) -- exibir aqui quando a fonte
          // existir.
          Text(
            'versão · terminal · última sincronização',
            style: textos.apoio.copyWith(color: cores.textoSobreEscuroApoio),
          ),
        ],
      ),
    );
  }
}

class _EmpresaSelecionada implements Empresa {
  @override
  final int id;

  @override
  final String nome;

  _EmpresaSelecionada({required this.id, required this.nome});
}

class _TerminalSelecionado implements TerminalDoUsuario {
  @override
  final int id;

  @override
  final int idEmpresa;

  @override
  final String nome;

  _TerminalSelecionado({
    required this.id,
    required this.idEmpresa,
    required this.nome,
  });

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
}
