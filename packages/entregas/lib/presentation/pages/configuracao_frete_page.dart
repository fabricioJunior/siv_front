import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/links.dart';
import 'package:entregas/presentation/blocs/configuracao_frete_bloc/configuracao_frete_bloc.dart';
import 'package:entregas/domain/models/frete.dart';
import 'package:flutter/material.dart';

class ConfiguracaoFretePage extends StatefulWidget {
  const ConfiguracaoFretePage({super.key});

  @override
  State<ConfiguracaoFretePage> createState() => _ConfiguracaoFretePageState();
}

class _ConfiguracaoFretePageState extends State<ConfiguracaoFretePage> {
  late final ConfiguracaoFreteBloc _bloc;
  final _marcadas = <String>{};
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  bool _ativo = false;
  bool _sandbox = true;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ConfiguracaoFreteBloc>()..add(ConfiguracaoFreteIniciou());
  }

  @override
  void dispose() {
    _bloc.close();
    _clientIdController.dispose();
    _clientSecretController.dispose();
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
            final c = state.config;
            setState(() {
              _marcadas
                ..clear()
                ..addAll(c?.transportadoras ?? const []);
              _ativo = c?.ativo ?? false;
              _sandbox = c?.sandbox ?? true;
              _clientIdController.text = c?.clientId ?? '';
              _clientSecretController.clear();
            });
          } else if (state.step == ConfiguracaoFreteStep.urlPronta) {
            sl<LinkService>().abrirLink(state.urlAutorizacao!);
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
          final ocupado = salvando || state.step == ConfiguracaoFreteStep.autorizando;
          final salvaEAtiva =
              config != null && config.provider != null && config.ativo;
          final autorizado = salvaEAtiva && config.autorizado;

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
                    : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              ..._secaoIntegracao(
                                config: config,
                                ocupado: ocupado,
                                salvaEAtiva: salvaEAtiva,
                                autorizado: autorizado,
                              ),
                              const Divider(height: 32),
                              Text(
                                'Transportadoras permitidas',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nenhuma marcada = todas permitidas',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (!autorizado)
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text(
                                    'Ative e autorize a integração acima para escolher as transportadoras.',
                                  ),
                                ),
                              if (autorizado)
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
                                onPressed: ocupado || !autorizado
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

  List<Widget> _secaoIntegracao({
    required ConfiguracaoFrete config,
    required bool ocupado,
    required bool salvaEAtiva,
    required bool autorizado,
  }) {
    final tema = Theme.of(context);
    return [
      Text('Integração Melhor Envio', style: tema.textTheme.titleMedium),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Ativo'),
        value: _ativo,
        onChanged: (v) => setState(() => _ativo = v),
      ),
      SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('Homologação (Testes)')),
          ButtonSegment(value: false, label: Text('Produção')),
        ],
        selected: {_sandbox},
        onSelectionChanged: (s) => setState(() => _sandbox = s.first),
      ),
      const SizedBox(height: 4),
      Text(
        _sandbox
            ? 'Testes e validação, não afeta envios reais.'
            : 'Ambiente real — envios e cobranças são reais.',
        style: tema.textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _clientIdController,
        decoration: const InputDecoration(
          labelText: 'Client ID',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _clientSecretController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Client Secret',
          hintText: config.clientId != null ? '*** (não alterado)' : null,
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: ocupado
            ? null
            : () => _bloc.add(ConfiguracaoFreteSalvarIntegracao(
                  ativo: _ativo,
                  sandbox: _sandbox,
                  clientId: _clientIdController.text,
                  clientSecret: _clientSecretController.text,
                )),
        child: const Text('Salvar integração'),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Icon(
            autorizado ? Icons.check_circle : Icons.warning_amber,
            color: autorizado ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              autorizado
                  ? 'Autorizado'
                  : 'Não autorizado — salve as credenciais e clique em Autorizar',
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: ocupado || !salvaEAtiva
                ? null
                : () => _bloc.add(ConfiguracaoFreteAutorizar()),
            child: const Text('Autorizar no Melhor Envio'),
          ),
          OutlinedButton(
            onPressed:
                ocupado ? null : () => _bloc.add(ConfiguracaoFreteIniciou()),
            child: const Text('Atualizar'),
          ),
        ],
      ),
    ];
  }
}
