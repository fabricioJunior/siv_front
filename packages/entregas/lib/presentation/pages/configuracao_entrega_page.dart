import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:entregas/presentation/blocs/configuracao_entrega_bloc/configuracao_entrega_bloc.dart';
import 'package:flutter/material.dart';

class ConfiguracaoEntregaPage extends StatefulWidget {
  const ConfiguracaoEntregaPage({super.key});

  @override
  State<ConfiguracaoEntregaPage> createState() =>
      _ConfiguracaoEntregaPageState();
}

class _ConfiguracaoEntregaPageState extends State<ConfiguracaoEntregaPage> {
  late final ConfiguracaoEntregaBloc _bloc;
  String _providerSelecionado = providersEntregaDisponiveis.first;
  bool _ativo = false;
  bool _preenchido = false;

  final _apiKeyController = TextEditingController();
  final _basicAuthUsernameController = TextEditingController();
  final _basicAuthPasswordController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _empresaIdExternoController = TextEditingController();
  final _tipoIdentificacaoEmpresaController = TextEditingController();
  final _identificacaoEmpresaController = TextEditingController();
  final _condutorIdPadraoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = sl<ConfiguracaoEntregaBloc>()..add(ConfiguracaoEntregaIniciou());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _basicAuthUsernameController.dispose();
    _basicAuthPasswordController.dispose();
    _baseUrlController.dispose();
    _empresaIdExternoController.dispose();
    _tipoIdentificacaoEmpresaController.dispose();
    _identificacaoEmpresaController.dispose();
    _condutorIdPadraoController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _preencherCampos(ConfiguracaoEntregaState state) {
    if (_preenchido || state.config == null) return;
    _preenchido = true;

    final config = state.config!;
    _ativo = config.ativo;
    if (config.provider != null) _providerSelecionado = config.provider!;

    final cfg = config.configuracao;
    if (cfg == null) return;
    _basicAuthUsernameController.text = cfg.basicAuthUsername ?? '';
    _baseUrlController.text = cfg.baseUrl ?? '';
    _empresaIdExternoController.text = cfg.empresaIdExterno ?? '';
    _tipoIdentificacaoEmpresaController.text =
        cfg.tipoIdentificacaoEmpresa ?? '';
    _identificacaoEmpresaController.text = cfg.identificacaoEmpresa ?? '';
    _condutorIdPadraoController.text =
        cfg.condutorIdPadrao?.toString() ?? '';
    // apiKey e basicAuthPassword ficam vazios de propósito — vêm mascarados
    // ('***') do backend e só são sobrescritos se o usuário digitar algo novo.
  }

  void _salvar() {
    final configuracao = <String, dynamic>{
      if (_apiKeyController.text.trim().isNotEmpty)
        'apiKey': _apiKeyController.text.trim(),
      'basicAuthUsername': _basicAuthUsernameController.text.trim(),
      if (_basicAuthPasswordController.text.trim().isNotEmpty)
        'basicAuthPassword': _basicAuthPasswordController.text.trim(),
      'baseUrl': _baseUrlController.text.trim(),
      'empresaIdExterno': _empresaIdExternoController.text.trim(),
      'tipoIdentificacaoEmpresa': _tipoIdentificacaoEmpresaController.text.trim(),
      'identificacaoEmpresa': _identificacaoEmpresaController.text.trim(),
      if (_condutorIdPadraoController.text.trim().isNotEmpty)
        'condutorIdPadrao':
            int.tryParse(_condutorIdPadraoController.text.trim()),
    };

    _bloc.add(ConfiguracaoEntregaSalvar(
      provider: _providerSelecionado,
      ativo: _ativo,
      configuracao: configuracao,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfiguracaoEntregaBloc>.value(
      value: _bloc,
      child: BlocConsumer<ConfiguracaoEntregaBloc, ConfiguracaoEntregaState>(
        listener: (context, state) {
          if (state.step == ConfiguracaoEntregaStep.salvo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuração salva com sucesso!')),
            );
          } else if (state.step == ConfiguracaoEntregaStep.falha &&
              state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!), backgroundColor: Colors.red),
            );
          }
          _preencherCampos(state);
        },
        builder: (context, state) {
          final isLoading = state.step == ConfiguracaoEntregaStep.carregando;
          final isSaving = state.step == ConfiguracaoEntregaStep.salvando;

          return Scaffold(
            appBar: AppBar(title: const Text('Configuração de Entrega')),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entregador Avulso',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure o provider usado para chamar entregadores avulsos.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _ativo,
                          title: const Text('Ativo'),
                          subtitle: const Text(
                            'Quando desativado, não é possível chamar entregadores.',
                          ),
                          onChanged: (value) => setState(() => _ativo = value),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _providerSelecionado,
                          decoration: const InputDecoration(
                            labelText: 'Provider',
                            border: OutlineInputBorder(),
                          ),
                          items: providersEntregaDisponiveis
                              .map((provider) => DropdownMenuItem(
                                    value: provider,
                                    child: Text(_labelProvider(provider)),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(
                              () => _providerSelecionado = value ?? _providerSelecionado),
                        ),
                        if (_providerSelecionado == 'machine') ...[
                          const SizedBox(height: 16),
                          Text(
                            'Credenciais Machine',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _apiKeyController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'API Key',
                              hintText: '•••• (não alterado)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _basicAuthUsernameController,
                            decoration: const InputDecoration(
                              labelText: 'Usuário (Basic Auth)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _basicAuthPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Senha (Basic Auth)',
                              hintText: '•••• (não alterado)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _baseUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL Base',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _empresaIdExternoController,
                            decoration: const InputDecoration(
                              labelText: 'ID da Empresa (Machine)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _tipoIdentificacaoEmpresaController,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Identificação da Empresa',
                              hintText: 'Ex: CNPJ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _identificacaoEmpresaController,
                            decoration: const InputDecoration(
                              labelText: 'Identificação da Empresa',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _condutorIdPadraoController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Condutor padrão (opcional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isSaving ? null : _salvar,
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Salvar Configuração'),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  String _labelProvider(String provider) {
    switch (provider) {
      case 'machine':
        return 'Machine';
      default:
        return provider;
    }
  }
}
