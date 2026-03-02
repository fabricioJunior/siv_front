import 'dart:io';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';

class PessoaPage extends StatefulWidget {
  final int? idPessoa;

  const PessoaPage({this.idPessoa, super.key});

  @override
  State<PessoaPage> createState() => _PessoaPageState();
}

class _PessoaPageState extends State<PessoaPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _contatoController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  DateTime? _dataNascimentoSelecionada;

  late final PessoaBloc _bloc;
  int _currentStep = 0;
  bool _camposHidratados = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<PessoaBloc>()
      ..add(
        PessoaIniciou(
          idPessoa: widget.idPessoa,
          tipoPessoa: TipoPessoa.fisica,
        ),
      );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _contatoController.dispose();
    _dataNascimentoController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCadastro = widget.idPessoa == null;

    return BlocProvider<PessoaBloc>.value(
      value: _bloc,
      child: BlocListener<PessoaBloc, PessoaState>(
        listenWhen: (previous, current) =>
            previous.pessoaStep != current.pessoaStep,
        listener: (context, state) {
          if (!_camposHidratados &&
              (state.pessoaStep == PessoaStep.carregado ||
                  state.pessoaStep == PessoaStep.salva ||
                  state.pessoaStep == PessoaStep.criada)) {
            _hidratatCamposComState(state);
            _camposHidratados = true;
          }

          if (state.pessoaStep == PessoaStep.criada ||
              state.pessoaStep == PessoaStep.salva) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              isCadastro ? 'Cadastro de pessoa' : 'Pessoa #${widget.idPessoa}',
            ),
          ),
          floatingActionButton: BlocBuilder<PessoaBloc, PessoaState>(
            builder: (context, state) {
              return _buildFooterAcoes(context, state);
            },
          ),
          body: BlocBuilder<PessoaBloc, PessoaState>(
            builder: (context, state) {
              if (state.pessoaStep == PessoaStep.carregando &&
                  state.nome == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Material(
                elevation: 2.0,
                child: Stepper(
                  type: !Platform.isAndroid
                      ? StepperType.horizontal
                      : StepperType.vertical,
                  currentStep: _stepAtual(state),
                  controlsBuilder: (_, __) => const SizedBox.shrink(),
                  steps: [
                    Step(
                      title: _stepTitle('Pessoa'),
                      isActive: _stepAtual(state) >= 0,
                      state: _stepAtual(state) > 0
                          ? StepState.complete
                          : StepState.indexed,
                      content: _buildStepPessoa(context, state),
                    ),
                    Step(
                      title: _stepTitle('Funcionario'),
                      isActive: _stepAtual(state) >= 1,
                      state: _stepAtual(state) > 1
                          ? StepState.complete
                          : StepState.indexed,
                      content: _buildStepFuncionario(context, state),
                    ),
                    Step(
                      title: _stepTitle('Confirmar'),
                      isActive: _stepAtual(state) >= 2,
                      state: StepState.indexed,
                      content: _buildStepConfirmacao(context, state),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  int _stepAtual(PessoaState state) {
    if (!(state.eFuncionario ?? false) && _currentStep == 1) {
      return 2;
    }
    return _currentStep;
  }

  Widget _buildStepPessoa(BuildContext context, PessoaState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: const Key('nome_pessoa_text_field'),
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          CPFInput(
            controller: _cpfController,
            valorInicial: state.documento,
          ),
          const SizedBox(height: 12),
          DateInput(
            externalController: _dataNascimentoController,
            dataInicial: state.dataDeNascimento,
            labelText: 'Data de nascimento',
            onComplete: (value) {
              _dataNascimentoSelecionada = value;
            },
          ),
          const SizedBox(height: 12),
          CelularInput(
            controller: _contatoController,
            valorInicial: state.contato,
            labelText: 'Contato',
          ),
          const SizedBox(height: 16),
          const Text('Tipo de vínculo'),
          RadioGroup<TipoPessoaSeletor>(
            groupValue: _valorInicial(state),
            onChanged: (value) {
              context.read<PessoaBloc>().add(
                    PessoaEditou(
                      eCliente: value == TipoPessoaSeletor.cliente,
                      eFornecedor: value == TipoPessoaSeletor.fornecedor,
                      eFuncionario: value == TipoPessoaSeletor.funcionario,
                    ),
                  );
            },
            child: const Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Cliente'),
                  leading: Radio<TipoPessoaSeletor>(
                      value: TipoPessoaSeletor.cliente),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Funcionário'),
                  leading: Radio<TipoPessoaSeletor>(
                      value: TipoPessoaSeletor.funcionario),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Fornecedor'),
                  leading: Radio<TipoPessoaSeletor>(
                      value: TipoPessoaSeletor.fornecedor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepFuncionario(BuildContext context, PessoaState state) {
    if (!(state.eFuncionario ?? false)) {
      return const Text(
        'Pessoa não marcada como funcionário. Esta etapa será pulada.',
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<TipoFuncionario>(
            value: state.tipoFuncionario,
            decoration: const InputDecoration(
              labelText: 'Tipo de funcionário',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: TipoFuncionario.comprador,
                child: Text('Comprador'),
              ),
              DropdownMenuItem(
                value: TipoFuncionario.vendedor,
                child: Text('Vendedor'),
              ),
              DropdownMenuItem(
                value: TipoFuncionario.caixa,
                child: Text('Caixa'),
              ),
              DropdownMenuItem(
                value: TipoFuncionario.gerente,
                child: Text('Gerente'),
              ),
            ],
            onChanged: (value) {
              context
                  .read<PessoaBloc>()
                  .add(PessoaEditou(tipoFuncionario: value));
            },
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              await _selecionarEmpresa(context);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Empresa',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              child: Text(
                _textoEmpresaSelecionada(state).isEmpty
                    ? 'Selecione uma empresa'
                    : _textoEmpresaSelecionada(state),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Funcionário inativo'),
            value: state.funcionarioInativo,
            onChanged: (value) {
              context
                  .read<PessoaBloc>()
                  .add(PessoaEditou(funcionarioInativo: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepConfirmacao(BuildContext context, PessoaState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Nome'),
            subtitle: Text(_nomeController.text.trim().isEmpty
                ? '-'
                : _nomeController.text.trim()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Documento'),
            subtitle: Text(_cpfController.text.trim().isEmpty
                ? '-'
                : _cpfController.text.trim()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Contato'),
            subtitle: Text(_contatoController.text.trim().isEmpty
                ? '-'
                : _contatoController.text.trim()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vínculo'),
            subtitle: Text(_descricaoVinculo(state)),
          ),
          if (state.eFuncionario ?? false) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tipo de funcionário'),
              subtitle: Text(_descricaoTipoFuncionario(state.tipoFuncionario)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Empresa'),
              subtitle: Text(
                _textoEmpresaSelecionada(state).isEmpty
                    ? '-'
                    : _textoEmpresaSelecionada(state),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Empresa ID'),
              subtitle: Text(
                state.funcionarioEmpresaId?.toString() ?? '-',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Situação'),
              subtitle: Text(state.funcionarioInativo ? 'Inativo' : 'Ativo'),
            ),
          ]
        ],
      ),
    );
  }

  Widget _stepTitle(String texto) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildFooterAcoes(BuildContext context, PessoaState state) {
    final carregando = state.pessoaStep == PessoaStep.carregando;

    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_stepAtual(state) > 0)
            OutlinedButton(
              onPressed: carregando
                  ? null
                  : () {
                      setState(() {
                        if (_currentStep == 2 &&
                            !(state.eFuncionario ?? false)) {
                          _currentStep = 0;
                        } else {
                          _currentStep -= 1;
                        }
                      });
                    },
              child: const Text('Voltar'),
            ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: carregando
                ? null
                : () {
                    final atual = _stepAtual(state);
                    if (atual < 2) {
                      if (!_podeAvancar(context, state, atual)) {
                        return;
                      }
                      if (atual == 0) {
                        _sincronizarDadosPessoaNoBloc(context, state);
                      }
                      setState(() {
                        if (atual == 0 && !(state.eFuncionario ?? false)) {
                          _currentStep = 2;
                        } else {
                          _currentStep = atual + 1;
                        }
                      });
                      return;
                    }

                    if (!_validarAntesDeSalvar(context, state)) {
                      return;
                    }

                    _sincronizarDadosPessoaNoBloc(context, state);

                    context.read<PessoaBloc>().add(PessoaSalvou());
                  },
            child: Text(_stepAtual(state) < 2 ? 'Próximo' : 'Confirmar'),
          ),
        ],
      ),
    );
  }

  bool _podeAvancar(BuildContext context, PessoaState state, int step) {
    if (step == 0) {
      if (_nomeController.text.trim().isEmpty) {
        _erro(context, 'Informe o nome da pessoa.');
        return false;
      }
      if (_cpfController.text.trim().isEmpty) {
        _erro(context, 'Informe o documento da pessoa.');
        return false;
      }
      if (_obterDataNascimentoAtual(state) == null) {
        _erro(context, 'Informe a data de nascimento.');
        return false;
      }
      if (_contatoController.text.trim().isEmpty) {
        _erro(context, 'Informe o contato da pessoa.');
        return false;
      }
      return true;
    }

    if (step == 1 && (state.eFuncionario ?? false)) {
      if (state.tipoFuncionario == null) {
        _erro(context, 'Selecione o tipo de funcionário.');
        return false;
      }
      if (state.funcionarioEmpresaId == null) {
        _erro(context, 'Selecione a empresa do funcionário.');
        return false;
      }
      return true;
    }

    return true;
  }

  bool _validarAntesDeSalvar(BuildContext context, PessoaState state) {
    if (!_podeAvancar(context, state, 0)) return false;
    if ((state.eFuncionario ?? false) && !_podeAvancar(context, state, 1)) {
      return false;
    }
    return true;
  }

  void _erro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  String _descricaoVinculo(PessoaState state) {
    if (state.eFuncionario ?? false) return 'Funcionário';
    if (state.eFornecedor ?? false) return 'Fornecedor';
    return 'Cliente';
  }

  String _descricaoTipoFuncionario(TipoFuncionario? tipo) {
    switch (tipo) {
      case TipoFuncionario.comprador:
        return 'Comprador';
      case TipoFuncionario.vendedor:
        return 'Vendedor';
      case TipoFuncionario.caixa:
        return 'Caixa';
      case TipoFuncionario.gerente:
        return 'Gerente';
      case null:
        return '-';
    }
  }

  TipoPessoaSeletor _valorInicial(PessoaState state) {
    if (state.eFornecedor ?? false) {
      return TipoPessoaSeletor.fornecedor;
    }
    if (state.eFuncionario ?? false) {
      return TipoPessoaSeletor.funcionario;
    }
    return TipoPessoaSeletor.cliente;
  }

  String _formatarData(DateTime? date) {
    if (date == null) return '';
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final ano = date.year.toString();
    return '$dia/$mes/$ano';
  }

  void _hidratatCamposComState(PessoaState state) {
    _nomeController.text = state.nome ?? '';
    _cpfController.text = state.documento ?? '';
    _contatoController.text = state.contato ?? '';
    _dataNascimentoController.text = _formatarData(state.dataDeNascimento);
    _dataNascimentoSelecionada = state.dataDeNascimento;
  }

  void _sincronizarDadosPessoaNoBloc(BuildContext context, PessoaState state) {
    context.read<PessoaBloc>().add(
          PessoaEditou(
            nome: _nomeController.text.trim(),
            documento: _cpfController.text.trim(),
            contato: _contatoController.text.trim(),
            dataDeNascimento: _obterDataNascimentoAtual(state),
          ),
        );
  }

  DateTime? _obterDataNascimentoAtual(PessoaState state) {
    return _dataNascimentoSelecionada ??
        _parseDataDoTexto(_dataNascimentoController.text) ??
        state.dataDeNascimento;
  }

  DateTime? _parseDataDoTexto(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return null;
    final partes = texto.split('/');
    if (partes.length != 3) return null;
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);
    if (dia == null || mes == null || ano == null) return null;
    try {
      return DateTime(ano, mes, dia);
    } catch (_) {
      return null;
    }
  }

  Future<void> _selecionarEmpresa(BuildContext context) async {
    final resultado =
        await Navigator.of(context).pushNamed('/selecionar_empresa');

    if (!mounted || resultado is! Map) return;

    final idEmpresa = resultado['idEmpresa'];
    final nomeEmpresa = resultado['nomeEmpresa'];

    if (idEmpresa is! int) return;

    final nome = nomeEmpresa is String ? nomeEmpresa.trim() : '';

    context.read<PessoaBloc>().add(
          PessoaEditou(
            funcionarioEmpresaId: idEmpresa,
            funcionarioEmpresaNome: nome,
          ),
        );
  }

  String _textoEmpresaSelecionada(PessoaState state) {
    final id = state.funcionarioEmpresaId;
    final nome = state.funcionarioEmpresaNome?.trim() ?? '';

    if (id == null) return '';
    if (nome.isEmpty) return 'ID $id';
    return '$nome (ID $id)';
  }
}

enum TipoPessoaSeletor {
  fornecedor,
  cliente,
  funcionario,
}
