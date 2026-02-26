import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema/presentation/bloc/configuracao_stmp_bloc/configuracao_stmp_bloc.dart';

class ConfiguracaoSTMPPage extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  ConfiguracaoSTMPPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfiguracaoSTMPBloc>(
      create: (_) => sl<ConfiguracaoSTMPBloc>()..add(ConfiguracaoSTMPIniciou()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configuração SMTP'),
          actions: [
            BlocBuilder<ConfiguracaoSTMPBloc, ConfiguracaoSTMPState>(
              builder: (context, state) {
                final podeVerificarConexao =
                    state.step != ConfiguracaoSTMPStep.verificandoConexao &&
                        state.configuracao != null;

                return IconButton(
                  tooltip: state.configuracao == null
                      ? 'Salve a configuração antes de verificar'
                      : 'Verificar conexão',
                  onPressed: !podeVerificarConexao
                      ? null
                      : () => context
                          .read<ConfiguracaoSTMPBloc>()
                          .add(ConfiguracaoSTMPConexaoVerificada()),
                  icon: const Icon(Icons.wifi_tethering),
                );
              },
            ),
          ],
        ),
        floatingActionButton:
            BlocBuilder<ConfiguracaoSTMPBloc, ConfiguracaoSTMPState>(
          builder: (context, state) {
            if (state.step == ConfiguracaoSTMPStep.carregando ||
                state.step == ConfiguracaoSTMPStep.salvando) {
              return const FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator.adaptive(),
              );
            }
            return FloatingActionButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  context
                      .read<ConfiguracaoSTMPBloc>()
                      .add(ConfiguracaoSTMPSalvou());
                }
              },
              child: const Icon(Icons.check),
            );
          },
        ),
        body: BlocBuilder<ConfiguracaoSTMPBloc, ConfiguracaoSTMPState>(
          builder: (context, state) {
            if (state.step == ConfiguracaoSTMPStep.carregando ||
                state.step == ConfiguracaoSTMPStep.inicial) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            final debouncer = Debouncer(milliseconds: 500);

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Servidor SMTP do sistema',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 16),
                            const Text('Servidor'),
                            TextFormField(
                              initialValue: state.servidor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o servidor SMTP';
                                }
                                return null;
                              },
                              onChanged: (value) => debouncer.run(
                                () => context.read<ConfiguracaoSTMPBloc>().add(
                                    ConfiguracaoSTMPEditou(servidor: value)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Porta'),
                            TextFormField(
                              initialValue: state.porta?.toString(),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe a porta SMTP';
                                }
                                return null;
                              },
                              onChanged: (value) => debouncer.run(
                                () => context.read<ConfiguracaoSTMPBloc>().add(
                                      ConfiguracaoSTMPEditou(
                                        porta: int.tryParse(value),
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Usuário'),
                            TextFormField(
                              initialValue: state.usuario,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o usuário SMTP';
                                }
                                return null;
                              },
                              onChanged: (value) => debouncer.run(
                                () => context.read<ConfiguracaoSTMPBloc>().add(
                                    ConfiguracaoSTMPEditou(usuario: value)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Senha'),
                            TextFormField(
                              initialValue: state.senha,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe a senha SMTP';
                                }
                                return null;
                              },
                              onChanged: (value) => debouncer.run(
                                () => context
                                    .read<ConfiguracaoSTMPBloc>()
                                    .add(ConfiguracaoSTMPEditou(senha: value)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Assunto do e-mail de redefinição'),
                            TextFormField(
                              initialValue: state.assuntoRedefinicaoSenha,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o assunto do template';
                                }
                                return null;
                              },
                              onChanged: (value) => debouncer.run(
                                () => context.read<ConfiguracaoSTMPBloc>().add(
                                      ConfiguracaoSTMPEditou(
                                        assuntoRedefinicaoSenha: value,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Corpo do e-mail de redefinição'),
                            TextFormField(
                              initialValue: state.corpoRedefinicaoSenha,
                              minLines: 4,
                              maxLines: 8,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o corpo do template';
                                }
                                return null;
                              },
                              onChanged: (value) => debouncer.run(
                                () => context.read<ConfiguracaoSTMPBloc>().add(
                                      ConfiguracaoSTMPEditou(
                                        corpoRedefinicaoSenha: value,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<ConfiguracaoSTMPBloc,
                                ConfiguracaoSTMPState>(
                              builder: (context, state) {
                                final podeVerificarConexao = state.step !=
                                        ConfiguracaoSTMPStep
                                            .verificandoConexao &&
                                    state.configuracao != null;

                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: !podeVerificarConexao
                                        ? null
                                        : () => context
                                            .read<ConfiguracaoSTMPBloc>()
                                            .add(
                                              ConfiguracaoSTMPConexaoVerificada(),
                                            ),
                                    icon: const Icon(Icons.wifi_tethering),
                                    label: const Text('Verificar conexão'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            _StatusConexaoLabel(step: state.step),
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
    );
  }
}

class _StatusConexaoLabel extends StatelessWidget {
  final ConfiguracaoSTMPStep step;

  const _StatusConexaoLabel({required this.step});

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case ConfiguracaoSTMPStep.conexaoValida:
        return const Text('Conexão SMTP validada com sucesso.');
      case ConfiguracaoSTMPStep.conexaoInvalida:
        return const Text('Falha ao validar a conexão SMTP.');
      case ConfiguracaoSTMPStep.verificandoConexao:
        return const Text('Verificando conexão SMTP...');
      case ConfiguracaoSTMPStep.salva:
        return const Text('Configuração SMTP salva com sucesso.');
      case ConfiguracaoSTMPStep.configuracaoNaoSalva:
        return const Text(
          'Salve a configuração SMTP antes de verificar a conexão.',
        );
      case ConfiguracaoSTMPStep.falha:
        return const Text('Falha ao carregar ou salvar a configuração SMTP.');
      default:
        return const SizedBox.shrink();
    }
  }
}
