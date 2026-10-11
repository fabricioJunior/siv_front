import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:entregas/presentation/blocs/configuracao_frete_bloc/configuracao_frete_bloc.dart';
import 'package:flutter/material.dart';

class ConfiguracaoFretePage extends StatefulWidget {
  const ConfiguracaoFretePage({super.key});

  @override
  State<ConfiguracaoFretePage> createState() => _ConfiguracaoFretePageState();
}

class _ConfiguracaoFretePageState extends State<ConfiguracaoFretePage> {
  late final ConfiguracaoFreteBloc _bloc;
  final _marcadas = <String>{};

  @override
  void initState() {
    super.initState();
    _bloc = sl<ConfiguracaoFreteBloc>()..add(ConfiguracaoFreteIniciou());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfiguracaoFreteBloc>.value(
      value: _bloc,
      child: BlocConsumer<ConfiguracaoFreteBloc, ConfiguracaoFreteState>(
        listenWhen: (a, b) => a.step != b.step,
        listener: (context, state) {
          if (state.step == ConfiguracaoFreteStep.sucesso) {
            setState(() => _marcadas
              ..clear()
              ..addAll(state.config?.transportadoras ?? const []));
          } else if (state.step == ConfiguracaoFreteStep.salvo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuração salva com sucesso!')),
            );
          } else if (state.step == ConfiguracaoFreteStep.falha &&
              state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final carregando = state.step == ConfiguracaoFreteStep.carregando ||
              state.step == ConfiguracaoFreteStep.inicial;
          final salvando = state.step == ConfiguracaoFreteStep.salvando;
          final config = state.config;
          final integrado = config != null && config.provider != null && config.ativo;

          return Scaffold(
            appBar: AppBar(title: const Text('Configuração de Frete')),
            body: carregando
                ? const Center(child: CircularProgressIndicator())
                : config == null
                    ? Center(
                        child: TextButton(
                          onPressed: () => _bloc.add(ConfiguracaoFreteIniciou()),
                          child: const Text('Tentar novamente'),
                        ),
                      )
                    : !integrado
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Integração de frete não configurada ou inativa. '
                                'As credenciais são configuradas por outro meio.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Text(
                                'Transportadoras permitidas',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nenhuma marcada = todas permitidas',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              for (final nome in state.transportadoras)
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(nome),
                                  value: _marcadas.contains(nome),
                                  onChanged: (v) => setState(() => v == true
                                      ? _marcadas.add(nome)
                                      : _marcadas.remove(nome)),
                                ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: salvando
                                    ? null
                                    : () => _bloc.add(ConfiguracaoFreteSalvar(
                                        _marcadas.toList())),
                                child: salvando
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('Salvar'),
                              ),
                            ],
                          ),
          );
        },
      ),
    );
  }
}
