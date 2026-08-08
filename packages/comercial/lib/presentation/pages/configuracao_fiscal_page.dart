import 'dart:io';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/presentation/blocs/configuracao_fiscal_bloc/configuracao_fiscal_bloc.dart';
import 'package:core/arquivos.dart';
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
  final _arquivoService = sl<ArquivoService>();
  String? _providerSelecionado;
  bool _homologacao = false;
  bool _homologacaoPreenchida = false;
  final Map<String, TextEditingController> _credenciaisControllers = {};
  final _classeImpostoPadraoController = TextEditingController();

  bool _sefazPreenchido = false;
  String? _sefazUf;
  bool _sefazHomologacao = false;
  int _sefazCrt = 3;
  final Map<String, TextEditingController> _sefazControllers = {};
  String? _certificadoArquivoPath;
  final _certificadoSenhaController = TextEditingController();
  bool _editandoCertificado = false;

  static const _credenciaisWebmania = [
    ('consumerKey', 'Consumer Key'),
    ('consumerSecret', 'Consumer Secret'),
    ('accessToken', 'Access Token'),
    ('accessTokenSecret', 'Access Token Secret'),
  ];

  static const _camposSefaz = [
    ('serieNfce', 'Série NFC-e'),
    ('serieNfe', 'Série NF-e'),
    ('cscId', 'CSC ID'),
    ('cscToken', 'CSC Token'),
    ('csosn', 'CSOSN (opcional, padrão 102)'),
    ('cstPisCofins', 'CST PIS/COFINS (opcional, padrão 07)'),
    ('naturezaOperacaoVenda', 'Natureza da Operação (opcional)'),
    (
      'qrCodeUrl',
      'URL de consulta do QR Code (opcional — só se a UF não tiver URL padrão cadastrada no backend)',
    ),
    (
      'urlChaveUrl',
      'URL de consulta por chave de acesso (opcional, mesmo caso acima)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = sl<ConfiguracaoFiscalBloc>()..add(ConfiguracaoFiscalIniciou());
    for (final campo in _credenciaisWebmania) {
      _credenciaisControllers[campo.$1] = TextEditingController();
    }
    for (final campo in _camposSefaz) {
      _sefazControllers[campo.$1] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _credenciaisControllers.values) c.dispose();
    for (final c in _sefazControllers.values) c.dispose();
    _classeImpostoPadraoController.dispose();
    _certificadoSenhaController.dispose();
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
    if (_classeImpostoPadraoController.text.isEmpty) {
      _classeImpostoPadraoController.text =
          (webmania['classeImpostoPadrao'] as String?) ?? '';
    }

    final sefaz = (cfg['sefaz'] as Map?)?.cast<String, dynamic>() ?? {};
    if (!_sefazPreenchido) {
      _sefazPreenchido = true;
      final emitente =
          (sefaz['emitente'] as Map?)?.cast<String, dynamic>() ?? {};
      _sefazUf = sefaz['uf'] as String?;
      _sefazHomologacao = (sefaz['ambiente'] as num?)?.toInt() == 2;
      _sefazCrt = (emitente['crt'] as num?)?.toInt() ?? 3;
      final valores = {
        'serieNfce': sefaz['serieNfce']?.toString() ?? '',
        'serieNfe': sefaz['serieNfe']?.toString() ?? '',
        'cscId': sefaz['cscId']?.toString() ?? '',
        'cscToken': sefaz['cscToken']?.toString() ?? '',
        'csosn': sefaz['csosn']?.toString() ?? '',
        'cstPisCofins': sefaz['cstPisCofins']?.toString() ?? '',
        'naturezaOperacaoVenda':
            sefaz['naturezaOperacaoVenda']?.toString() ?? '',
        'qrCodeUrl': sefaz['qrCodeUrl']?.toString() ?? '',
        'urlChaveUrl': sefaz['urlChaveUrl']?.toString() ?? '',
      };
      for (final entry in valores.entries) {
        _sefazControllers[entry.key]?.text = entry.value;
      }
    }
  }

  String? _certificadoValidadeSefaz(EmpresaIntegracaoFiscal? config) {
    final sefaz =
        (config?.configuracao?['sefaz'] as Map?)?.cast<String, dynamic>();
    return sefaz?['certificadoValidade'] as String?;
  }

  String _formatarData(String isoDate) {
    final d = DateTime.parse(isoDate);
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
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
          'classeImpostoPadrao': _classeImpostoPadraoController.text.trim(),
        },
      };
    } else if (provider == 'sefaz') {
      String? campo(String chave) {
        final texto = _sefazControllers[chave]!.text.trim();
        return texto.isEmpty ? null : texto;
      }

      configuracao = {
        'sefaz': {
          'uf': _sefazUf,
          'ambiente': _sefazHomologacao ? 2 : 1,
          'serieNfce': int.tryParse(campo('serieNfce') ?? '') ?? 0,
          'serieNfe': int.tryParse(campo('serieNfe') ?? '') ?? 0,
          'cscId': campo('cscId') ?? '',
          'cscToken': campo('cscToken') ?? '',
          'emitente': {
            'crt': _sefazCrt,
          },
          if (campo('csosn') != null) 'csosn': campo('csosn'),
          if (campo('cstPisCofins') != null)
            'cstPisCofins': campo('cstPisCofins'),
          if (campo('naturezaOperacaoVenda') != null)
            'naturezaOperacaoVenda': campo('naturezaOperacaoVenda'),
          if (campo('qrCodeUrl') != null) 'qrCodeUrl': campo('qrCodeUrl'),
          if (campo('urlChaveUrl') != null)
            'urlChaveUrl': campo('urlChaveUrl'),
        },
      };
    }

    _bloc.add(ConfiguracaoFiscalSalvar(
      provider: provider,
      ativo: true,
      configuracao: configuracao,
    ));
  }

  Widget _buildCertificadoSefaz(
    BuildContext context,
    ConfiguracaoFiscalState state,
  ) {
    final validade = _certificadoValidadeSefaz(state.config);
    if (validade != null && !_editandoCertificado) {
      return Row(
        children: [
          const Icon(Icons.verified_outlined, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Certificado cadastrado — válido até ${_formatarData(validade)}'),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _editandoCertificado = true),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar'),
          ),
          TextButton.icon(
            onPressed: state.excluindoCertificado
                ? null
                : () => _bloc.add(ConfiguracaoFiscalExcluirCertificado()),
            icon: state.excluindoCertificado
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (validade != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Substituindo certificado atual (válido até ${_formatarData(validade)}).',
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _editandoCertificado = false;
                    _certificadoArquivoPath = null;
                    _certificadoSenhaController.clear();
                  }),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () async {
            final path = await _arquivoService
                .selecionarArquivo(extensoes: ['pfx', 'p12']);
            if (path != null) setState(() => _certificadoArquivoPath = path);
          },
          icon: const Icon(Icons.upload_file),
          label: Text(_certificadoArquivoPath == null
              ? 'Selecionar certificado (.pfx)'
              : _certificadoArquivoPath!.split(Platform.pathSeparator).last),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _certificadoSenhaController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Senha do certificado',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _certificadoArquivoPath == null ||
                    state.enviandoCertificado
                ? null
                : () => _bloc.add(ConfiguracaoFiscalEnviarCertificado(
                      filePath: _certificadoArquivoPath!,
                      senha: _certificadoSenhaController.text,
                    )),
            child: state.enviandoCertificado
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Enviar certificado'),
          ),
        ),
      ],
    );
  }

  Color _corProvider(String provider, bool ativo) {
    if (!ativo) return Colors.grey;
    return switch (provider) {
      'webmania' => Colors.indigo,
      'noop' => Colors.orange,
      'sefaz' => Colors.green,
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
          if (state.certificadoSucesso != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.certificadoSucesso!)),
            );
            setState(() {
              _certificadoArquivoPath = null;
              _certificadoSenhaController.clear();
              _editandoCertificado = false;
            });
          } else if (state.certificadoErro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.certificadoErro!),
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
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _classeImpostoPadraoController,
                            decoration: const InputDecoration(
                              labelText: 'Classe de imposto padrão (Webmania)',
                              hintText: 'Ex: REF1000',
                              helperText:
                                  'Código da classe de imposto cadastrada no painel Webmania, '
                                  'usado em todos os produtos na emissão da nota.',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                        if (_providerSelecionado == 'sefaz') ...[
                          const SizedBox(height: 16),
                          Text(
                            'Configuração SEFAZ',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'O endereço usado na emissão é o cadastrado na empresa. '
                                    'Para alterar, edite o cadastro da empresa.',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final empresaId = state.config?.empresaId;
                                    Navigator.of(context).pushNamed(
                                      '/empresa',
                                      arguments: {'idEmpresa': empresaId},
                                    );
                                  },
                                  child: const Text('Editar empresa'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _sefazUf,
                            decoration: const InputDecoration(
                              labelText: 'UF',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'PI', child: Text('PI')),
                              DropdownMenuItem(value: 'CE', child: Text('CE')),
                            ],
                            onChanged: (value) =>
                                setState(() => _sefazUf = value),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _sefazCrt,
                            decoration: const InputDecoration(
                              labelText: 'CRT (Regime Tributário)',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('1 - Simples Nacional'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text(
                                    '2 - Simples Nacional excesso sublimite'),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: Text('3 - Regime Normal'),
                              ),
                              DropdownMenuItem(value: 4, child: Text('4 - MEI')),
                            ],
                            onChanged: (value) => setState(
                                () => _sefazCrt = value ?? _sefazCrt),
                          ),
                          const SizedBox(height: 12),
                          ..._camposSefaz.map(
                            (campo) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: _sefazControllers[campo.$1],
                                decoration: InputDecoration(
                                  labelText: campo.$2,
                                  border: const OutlineInputBorder(),
                                ),
                                obscureText: campo.$1 == 'cscToken',
                                keyboardType: campo.$1 == 'serieNfce' ||
                                        campo.$1 == 'serieNfe'
                                    ? TextInputType.number
                                    : TextInputType.text,
                              ),
                            ),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _sefazHomologacao,
                            title: const Text('Ambiente de homologação'),
                            subtitle: const Text(
                              'Quando ativado, as notas são emitidas em ambiente de testes da SEFAZ.',
                            ),
                            onChanged: (value) =>
                                setState(() => _sefazHomologacao = value),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Certificado Digital A1',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          _buildCertificadoSefaz(context, state),
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
        'sefaz' => 'SEFAZ Direto',
        _ => provider,
      };

  String get _descricao => switch (provider) {
        'webmania' => 'Gateway fiscal Webmania — emissão NF-e/NFC-e',
        'noop' => 'Simula emissão sem enviar à SEFAZ',
        'sefaz' => 'Emissão direta na SEFAZ (NFC-e/NF-e), sem intermediário',
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
