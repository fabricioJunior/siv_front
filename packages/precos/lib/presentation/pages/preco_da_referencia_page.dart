import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precos/presentation.dart';

class PrecoDaReferenciaPage extends StatefulWidget {
  final int tabelaDePrecoId;
  final int referenciaId;
  final String referenciaNome;
  final double valorInicial;
  final Widget imagensDaReferencia;

  const PrecoDaReferenciaPage({
    super.key,
    required this.tabelaDePrecoId,
    required this.referenciaId,
    required this.referenciaNome,
    required this.valorInicial,
    required this.imagensDaReferencia,
  });

  @override
  State<PrecoDaReferenciaPage> createState() => _PrecoDaReferenciaPageState();
}

class _PrecoDaReferenciaPageState extends State<PrecoDaReferenciaPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _valorFocusNode = FocusNode();
  final _tabelaNomeController = TextEditingController();
  final _referenciaIdController = TextEditingController();
  final _referenciaNomeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _referenciaIdController.text = widget.referenciaId.toString();
    _referenciaNomeController.text = widget.referenciaNome;
    _valorController.text = widget.valorInicial.toStringAsFixed(2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _valorFocusNode.requestFocus();
      _valorController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _valorController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _valorController.dispose();
    _valorFocusNode.dispose();
    _tabelaNomeController.dispose();
    _referenciaIdController.dispose();
    _referenciaNomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EditarPrecoDaReferenciaBloc>(
          create: (context) => sl<EditarPrecoDaReferenciaBloc>(),
        ),
        BlocProvider<TabelaDePrecoBloc>(
          create: (context) => sl<TabelaDePrecoBloc>()
            ..add(
              TabelaDePrecoIniciou(idTabelaDePreco: widget.tabelaDePrecoId),
            ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<
            EditarPrecoDaReferenciaBloc,
            EditarPrecoDaReferenciaState
          >(
            listenWhen: (previous, current) =>
                previous.step == EditarPrecoDaReferenciaStep.salvando &&
                current.step == EditarPrecoDaReferenciaStep.sucesso,
            listener: (context, state) => Navigator.of(context).pop(true),
          ),
          BlocListener<TabelaDePrecoBloc, TabelaDePrecoState>(
            listener: (context, state) {
              if (state.nome != null &&
                  _tabelaNomeController.text != state.nome) {
                _tabelaNomeController.text = state.nome!;
              }
            },
          ),
        ],
        child:
            BlocBuilder<
              EditarPrecoDaReferenciaBloc,
              EditarPrecoDaReferenciaState
            >(
              builder: (context, state) {
                final salvando =
                    state.step == EditarPrecoDaReferenciaStep.salvando;

                if (state.erro != null && state.erro!.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.erro!)));
                  });
                }

                return Scaffold(
                  appBar: AppBar(title: const Text('Preço da Referência')),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlocBuilder<TabelaDePrecoBloc, TabelaDePrecoState>(
                              builder: (context, tabelaState) {
                                final carregandoTabela =
                                    tabelaState.tabelaDePrecoStep ==
                                    TabelaDePrecoStep.carregando;

                                return TextFormField(
                                  controller: _tabelaNomeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Tabela de preço',
                                    suffixIcon: carregandoTabela
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _referenciaNomeController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Nome da referência',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _referenciaIdController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'ID da referência',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _valorController,
                              focusNode: _valorFocusNode,
                              enabled: !salvando,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                                TextInputFormatter.withFunction((
                                  oldValue,
                                  newValue,
                                ) {
                                  final text = newValue.text;
                                  if (text.isEmpty) return newValue;
                                  if (!RegExp(
                                    r'^\d+([.,]\d{0,2})?$',
                                  ).hasMatch(text)) {
                                    return oldValue;
                                  }
                                  return newValue;
                                }),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Valor',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe o valor';
                                }
                                if (!_possuiAteDuasCasas(value)) {
                                  return 'Use no máximo 2 casas decimais';
                                }
                                if (_parseDouble(value) == null) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: salvando
                                    ? null
                                    : () => _salvar(context),
                                icon: salvando
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: const Text('Salvar preço'),
                              ),
                            ),
                            const SizedBox(height: 32),
                            widget.imagensDaReferencia,
                          ],
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

  void _salvar(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final valor = _parseDouble(_valorController.text)!;
    context.read<EditarPrecoDaReferenciaBloc>().add(
      EditarPrecoDaReferenciaSalvou(
        tabelaDePrecoId: widget.tabelaDePrecoId,
        referenciaId: widget.referenciaId,
        valor: valor,
      ),
    );
  }

  bool _possuiAteDuasCasas(String value) {
    return RegExp(r'^\d+([.,]\d{1,2})?$').hasMatch(value.trim());
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}
