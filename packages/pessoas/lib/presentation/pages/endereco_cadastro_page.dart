import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/endereco_cadastro_bloc/endereco_cadastro_bloc.dart';
import 'package:pessoas/presentation/bloc/enderecos_bloc/enderecos_bloc.dart';

class EnderecoCadastroPage extends StatelessWidget {
  final int idPessoa;

  const EnderecoCadastroPage({
    super.key,
    required this.idPessoa,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          context.read<EnderecoCadastroBloc>()..add(EnderecoCadastroIniciou()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<EnderecoCadastroBloc, EnderecoCadastroState>(
            listener: (context, state) {
              if (state is EnderecoCadastroConfirmado) {
                context.read<EnderecosBloc>().add(
                      EnderecosCriouNovoEndereco(
                        endereco: state.endereco,
                      ),
                    );
              } else if (state is EnderecoCadastroCancelado) {
                Navigator.of(context).pop();
              }
            },
          ),
          BlocListener<EnderecosBloc, EnderecosState>(
            listener: (context, state) {
              if (state is EnderecosCriarSucesso) {
                Navigator.of(context).pop();
              } else if (state is EnderecosCriarFalha) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nao foi possivel salvar o endereco.'),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<EnderecoCadastroBloc, EnderecoCadastroState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Novo Endereco'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.read<EnderecoCadastroBloc>().add(
                          EnderecoCadastroCancelar(),
                        );
                  },
                ),
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, EnderecoCadastroState state) {
    return Column(
      children: [
        _buildStepper(context, state),
        Expanded(
          child: _buildEtapa(context, state),
        ),
      ],
    );
  }

  Widget _buildStepper(BuildContext context, EnderecoCadastroState state) {
    final etapas = [
      'CEP',
      'Endereço',
      'UF',
      'Município',
      'Tipo',
      'Confirmar',
    ];

    int etapaAtual = state.etapa.index;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: List.generate(
          etapas.length,
          (index) {
            final isAtual = index == etapaAtual;
            final isConcluida = index < etapaAtual;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isConcluida || isAtual
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isConcluida
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isAtual ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    etapas[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isAtual
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEtapa(BuildContext context, EnderecoCadastroState state) {
    switch (state.etapa) {
      case EtapaCadastroEndereco.cep:
        return _EtapaCep(state: state);
      case EtapaCadastroEndereco.dadosBasicos:
        return _EtapaDadosBasicos(state: state);
      case EtapaCadastroEndereco.uf:
        return _EtapaUf(state: state);
      case EtapaCadastroEndereco.municipio:
        return _EtapaMunicipio(state: state);
      case EtapaCadastroEndereco.tipo:
        return _EtapaTipo(state: state);
      case EtapaCadastroEndereco.confirmacao:
        return _EtapaConfirmacao(state: state);
    }
  }
}

// Etapa 1: CEP
class _EtapaCep extends StatefulWidget {
  final EnderecoCadastroState state;

  const _EtapaCep({required this.state});

  @override
  State<_EtapaCep> createState() => _EtapaCepState();
}

class _EtapaCepState extends State<_EtapaCep> {
  final _cepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cepController.text = widget.state.cep ?? '';
    _cepController.addListener(() {
      context.read<EnderecoCadastroBloc>().add(
            EnderecoCadastroCepDigitado(_cepController.text),
          );
    });
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBuscando = widget.state is EnderecoCadastroBuscandoCep;
    final erro = widget.state is EnderecoCadastroErroCep
        ? (widget.state as EnderecoCadastroErroCep).mensagem
        : null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Como deseja cadastrar o endereço?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _cepController,
            decoration: InputDecoration(
              labelText: 'CEP',
              border: const OutlineInputBorder(),
              errorText: erro,
              suffixIcon: isBuscando
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            enabled: !isBuscando,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isBuscando
                ? null
                : () {
                    context.read<EnderecoCadastroBloc>().add(
                          EnderecoCadastroBuscarCep(),
                        );
                  },
            icon: const Icon(Icons.search),
            label: const Text('Buscar pelo CEP'),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: isBuscando
                ? null
                : () {
                    context.read<EnderecoCadastroBloc>().add(
                          EnderecoCadastroPreencherManualmente(),
                        );
                  },
            icon: const Icon(Icons.edit),
            label: const Text('Preencher Manualmente'),
          ),
        ],
      ),
    );
  }
}

// Etapa 2: Dados Básicos (Logradouro, Número, Complemento, Bairro)
class _EtapaDadosBasicos extends StatefulWidget {
  final EnderecoCadastroState state;

  const _EtapaDadosBasicos({required this.state});

  @override
  State<_EtapaDadosBasicos> createState() => _EtapaDadosBasicosState();
}

class _EtapaDadosBasicosState extends State<_EtapaDadosBasicos> {
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _logradouroController.text = widget.state.logradouro ?? '';
    _numeroController.text = widget.state.numero ?? '';
    _complementoController.text = widget.state.complemento ?? '';
    _bairroController.text = widget.state.bairro ?? '';

    _logradouroController.addListener(() {
      context.read<EnderecoCadastroBloc>().add(
            EnderecoCadastroLogradouroAlterado(_logradouroController.text),
          );
    });
    _numeroController.addListener(() {
      context.read<EnderecoCadastroBloc>().add(
            EnderecoCadastroNumeroAlterado(_numeroController.text),
          );
    });
    _complementoController.addListener(() {
      context.read<EnderecoCadastroBloc>().add(
            EnderecoCadastroComplementoAlterado(_complementoController.text),
          );
    });
    _bairroController.addListener(() {
      context.read<EnderecoCadastroBloc>().add(
            EnderecoCadastroBairroAlterado(_bairroController.text),
          );
    });
  }

  @override
  void dispose() {
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dados do Endereço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  TextFormField(
                    controller: _logradouroController,
                    decoration: const InputDecoration(
                      labelText: 'Logradouro *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'Número *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _complementoController,
                    decoration: const InputDecoration(
                      labelText: 'Complemento',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bairroController,
                    decoration: const InputDecoration(
                      labelText: 'Bairro *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<EnderecoCadastroBloc>().add(
                            EnderecoCadastroVoltarEtapa(),
                          );
                    },
                    child: const Text('Voltar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<EnderecoCadastroBloc>().add(
                              EnderecoCadastroAvancarParaUf(),
                            );
                      }
                    },
                    child: const Text('Avançar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Etapa 3: UF
class _EtapaUf extends StatefulWidget {
  final EnderecoCadastroState state;

  const _EtapaUf({required this.state});

  @override
  State<_EtapaUf> createState() => _EtapaUfState();
}

class _EtapaUfState extends State<_EtapaUf> {
  final _ufController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ufController.text = widget.state.uf ?? '';
    _ufController.addListener(() {
      context.read<EnderecoCadastroBloc>().add(
            EnderecoCadastroUfAlterada(_ufController.text),
          );
    });
  }

  @override
  void dispose() {
    _ufController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Estado (UF)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ufController,
              decoration: const InputDecoration(
                labelText: 'UF *',
                border: OutlineInputBorder(),
                hintText: 'Ex: SP, RJ, MG',
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                LengthLimitingTextInputFormatter(2),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (value.length != 2) {
                  return 'UF deve ter 2 letras';
                }
                return null;
              },
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<EnderecoCadastroBloc>().add(
                            EnderecoCadastroVoltarEtapa(),
                          );
                    },
                    child: const Text('Voltar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<EnderecoCadastroBloc>().add(
                              EnderecoCadastroAvancarParaMunicipio(),
                            );
                      }
                    },
                    child: const Text('Avançar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Etapa 4: Município
class _EtapaMunicipio extends StatefulWidget {
  final EnderecoCadastroState state;

  const _EtapaMunicipio({required this.state});

  @override
  State<_EtapaMunicipio> createState() => _EtapaMunicipioState();
}

class _EtapaMunicipioState extends State<_EtapaMunicipio> {
  final _municipioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _municipioController.text = widget.state.municipio ?? '';
    _municipioController.addListener(() {
      context.read<EnderecoCadastroBloc>().add(
            EnderecoCadastroMunicipioAlterado(_municipioController.text),
          );
    });
  }

  @override
  void dispose() {
    _municipioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Município',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _municipioController,
              decoration: const InputDecoration(
                labelText: 'Município *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<EnderecoCadastroBloc>().add(
                            EnderecoCadastroVoltarEtapa(),
                          );
                    },
                    child: const Text('Voltar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<EnderecoCadastroBloc>().add(
                              EnderecoCadastroAvancarParaTipo(),
                            );
                      }
                    },
                    child: const Text('Avançar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Etapa 5: Tipo
class _EtapaTipo extends StatefulWidget {
  final EnderecoCadastroState state;

  const _EtapaTipo({required this.state});

  @override
  State<_EtapaTipo> createState() => _EtapaTipoState();
}

class _EtapaTipoState extends State<_EtapaTipo> {
  TipoEndereco? _tipoSelecionado;
  late bool _principal;

  @override
  void initState() {
    super.initState();
    _tipoSelecionado = widget.state.tipo;
    _principal = widget.state.principal;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tipo de Endereço',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          RadioListTile<TipoEndereco>(
            title: const Text('Comercial'),
            value: TipoEndereco.comercial,
            groupValue: _tipoSelecionado,
            onChanged: (value) {
              setState(() {
                _tipoSelecionado = value;
              });
              if (value != null) {
                context.read<EnderecoCadastroBloc>().add(
                      EnderecoCadastroTipoAlterado(value),
                    );
              }
            },
          ),
          RadioListTile<TipoEndereco>(
            title: const Text('Residencial'),
            value: TipoEndereco.residencial,
            groupValue: _tipoSelecionado,
            onChanged: (value) {
              setState(() {
                _tipoSelecionado = value;
              });
              if (value != null) {
                context.read<EnderecoCadastroBloc>().add(
                      EnderecoCadastroTipoAlterado(value),
                    );
              }
            },
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _principal,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _principal = value;
              });
              context.read<EnderecoCadastroBloc>().add(
                    EnderecoCadastroPrincipalAlterado(value),
                  );
            },
            contentPadding: EdgeInsets.zero,
            title: const Text('Marcar como principal'),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<EnderecoCadastroBloc>().add(
                          EnderecoCadastroVoltarEtapa(),
                        );
                  },
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _tipoSelecionado == null
                      ? null
                      : () {
                          context.read<EnderecoCadastroBloc>().add(
                                EnderecoCadastroAvancarParaConfirmacao(),
                              );
                        },
                  child: const Text('Avançar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Etapa 6: Confirmação
class _EtapaConfirmacao extends StatelessWidget {
  final EnderecoCadastroState state;

  const _EtapaConfirmacao({required this.state});

  String _formatarTipo(TipoEndereco tipo) {
    switch (tipo) {
      case TipoEndereco.comercial:
        return 'Comercial';
      case TipoEndereco.residencial:
        return 'Residencial';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Confirme os dados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    if (state.cep != null) ...[
                      _buildInfoRow('CEP', state.cep!),
                      const Divider(),
                    ],
                    if (state.logradouro != null) ...[
                      _buildInfoRow('Logradouro', state.logradouro!),
                      const Divider(),
                    ],
                    if (state.numero != null) ...[
                      _buildInfoRow('Número', state.numero!),
                      const Divider(),
                    ],
                    if (state.complemento != null &&
                        state.complemento!.isNotEmpty) ...[
                      _buildInfoRow('Complemento', state.complemento!),
                      const Divider(),
                    ],
                    if (state.bairro != null) ...[
                      _buildInfoRow('Bairro', state.bairro!),
                      const Divider(),
                    ],
                    if (state.municipio != null) ...[
                      _buildInfoRow('Município', state.municipio!),
                      const Divider(),
                    ],
                    if (state.uf != null) ...[
                      _buildInfoRow('UF', state.uf!),
                      const Divider(),
                    ],
                    if (state.tipo != null)
                      _buildInfoRow('Tipo', _formatarTipo(state.tipo!)),
                    _buildInfoRow(
                      'Principal',
                      state.principal ? 'Sim' : 'Não',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<EnderecoCadastroBloc>().add(
                          EnderecoCadastroVoltarEtapa(),
                        );
                  },
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BlocBuilder<EnderecosBloc, EnderecosState>(
                  builder: (context, state) {
                    final salvando = state is EnderecosCriarEmProgresso;

                    return ElevatedButton(
                      onPressed: salvando
                          ? null
                          : () {
                              context.read<EnderecoCadastroBloc>().add(
                                    EnderecoCadastroConfirmar(),
                                  );
                            },
                      child: salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirmar'),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
