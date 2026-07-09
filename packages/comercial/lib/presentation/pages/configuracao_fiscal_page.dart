import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/presentation/blocs/configuracao_fiscal_bloc/configuracao_fiscal_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class ConfiguracaoFiscalPage extends StatefulWidget {
  const ConfiguracaoFiscalPage({super.key});

  @override
  State<ConfiguracaoFiscalPage> createState() =>
      _ConfiguracaoFiscalPageState();
}

class _ConfiguracaoFiscalPageState extends State<ConfiguracaoFiscalPage> {
  late final ConfiguracaoFiscalBloc _bloc;
  String? _providerSelecionado;
  bool _homologacao = false;
  bool _homologacaoPreenchida = false;
  final Map<String, TextEditingController> _credenciaisControllers = {};

  static const _credenciaisWebmania = [
    ('consumerKey', 'Consumer Key'),
    ('consumerSecret', 'Consumer Secret'),
    ('accessToken', 'Access Token'),
    ('accessTokenSecret', 'Access Token Secret'),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = sl<ConfiguracaoFiscalBloc>()..add(ConfiguracaoFiscalIniciou());
    for (final campo in _credenciaisWebmania) {
      _credenciaisControllers[campo.$1] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _credenciaisControllers.values) c.dispose();
    _bloc.close();
    super.dispose();
  }

  void _preencherCampos(EmpresaIntegracaoFiscal? config) {
    if (config == null) return;
    _providerSelecionado ??= config.ativo ? config.provider : null;
    final cfg = config.configuracao ?? {};
    final webmania =
        (cfg['webmania'] as Map?)?.cast<String, dynamic>() ?? {};
    final credentials =
        (webmania['credentials'] as Map?)?.cast<String, dynamic>() ?? {};
    for (final campo in _credenciaisWebmania) {
      final controller = _credenciaisControllers[campo.$1];
      if (controller != null && controller.text.isEmpty) {
        controller.text = (credentials[campo.$1] as String?) ?? '';
      }
    }
    if (!_homologacaoPreenchida) {
      _homologacaoPreenchida = true;
      _homologacao = webmania['homologacao'] as bool? ?? false;
    }
  }

  void _salvar() {
    final provider = _providerSelecionado;
    if (provider == null) return;

    Map<String, dynamic>? configuracao;
    if (provider == 'webmania') {
      configuracao = {
        'webmania': {
          'credentials': {
            for (final campo in _credenciaisWebmania)
              campo.$1: _credenciaisControllers[campo.$1]!.text.trim(),
          },
          'homologacao': _homologacao,
        },
      };
    }

    _bloc.add(ConfiguracaoFiscalSalvar(
      provider: provider,
      ativo: true,
      configuracao: configuracao,
    ));
  }

  Color _corProvider(String provider, bool ativo) {
    if (!ativo) return Colors.grey;
    return switch (provider) {
      'webmania' => Colors.indigo,
      'noop' => Colors.orange,
      _ => Colors.blueGrey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfiguracaoFiscalBloc>.value(
      value: _bloc,
      child: BlocConsumer<ConfiguracaoFiscalBloc, ConfiguracaoFiscalState>(
        listener: (context, state) {
          if (state.step == ConfiguracaoFiscalStep.salvo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuração salva com sucesso!')),
            );
          } else if (state.step == ConfiguracaoFiscalStep.falha &&
              state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.erro!),
                backgroundColor: Colors.red,
              ),
            );
          }
          _preencherCampos(state.config);
        },
        builder: (context, state) {
          final isLoading = state.step == ConfiguracaoFiscalStep.carregando;
          final isSaving = state.step == ConfiguracaoFiscalStep.salvando;

          return Scaffold(
            appBar: AppBar(title: const Text('Configuração Fiscal')),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gateway de Emissão',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selecione o provider ativo para emissão de NF-e. Apenas um pode estar ativo por vez.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        ...state.providers.map((provider) {
                          final selecionado = _providerSelecionado == provider;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProviderCard(
                              provider: provider,
                              selecionado: selecionado,
                              cor: _corProvider(provider, selecionado),
                              onTap: () =>
                                  setState(() => _providerSelecionado = provider),
                            ),
                          );
                        }),
                        if (_providerSelecionado == 'webmania') ...[
                          const SizedBox(height: 16),
                          Text(
                            'Credenciais Webmania',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          ..._credenciaisWebmania.map(
                            (campo) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: _credenciaisControllers[campo.$1],
                                decoration: InputDecoration(
                                  labelText: campo.$2,
                                  border: const OutlineInputBorder(),
                                ),
                                obscureText: campo.$1 == 'consumerSecret' ||
                                    campo.$1 == 'accessTokenSecret',
                              ),
                            ),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _homologacao,
                            title: const Text('Ambiente de homologação (testes)'),
                            subtitle: const Text(
                              'Quando ativado, as notas são emitidas em ambiente de testes da Webmania.',
                            ),
                            onChanged: (value) =>
                                setState(() => _homologacao = value),
                          ),
                        ],
                        if (_providerSelecionado == 'noop') ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Modo teste — notas não serão enviadas à SEFAZ.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: (_providerSelecionado == null || isSaving)
                                ? null
                                : _salvar,
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
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.selecionado,
    required this.cor,
    required this.onTap,
  });

  final String provider;
  final bool selecionado;
  final Color cor;
  final VoidCallback onTap;

  String get _label => switch (provider) {
        'webmania' => 'Webmania',
        'noop' => 'Modo Teste (noop)',
        _ => provider,
      };

  String get _descricao => switch (provider) {
        'webmania' => 'Gateway fiscal Webmania — emissão NF-e/NFC-e',
        'noop' => 'Simula emissão sem enviar à SEFAZ',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selecionado ? cor : Colors.grey.shade300,
            width: selecionado ? 2 : 1,
          ),
          color: selecionado ? cor.withOpacity(0.05) : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: selecionado ? cor : Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: selecionado ? cor : null,
                                    fontWeight: selecionado
                                        ? FontWeight.bold
                                        : null,
                                  ),
                            ),
                            if (_descricao.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _descricao,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: provider,
                        groupValue: selecionado ? provider : null,
                        onChanged: (_) => onTap(),
                        activeColor: cor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
