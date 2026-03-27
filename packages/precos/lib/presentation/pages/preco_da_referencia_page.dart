import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precos/presentation.dart';

class PrecoDaReferenciaPage extends StatefulWidget {
  final int tabelaDePrecoId;
  final ISeletor referenciaSeletor;
  final SelectData? referenciaPreSelecionada;

  const PrecoDaReferenciaPage({
    super.key,
    required this.tabelaDePrecoId,
    required this.referenciaSeletor,
    this.referenciaPreSelecionada,
  });

  @override
  State<PrecoDaReferenciaPage> createState() => _PrecoDaReferenciaPageState();
}

class _PrecoDaReferenciaPageState extends State<PrecoDaReferenciaPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _referenciaIdController = TextEditingController();
  StreamSubscription<List<SelectData>>? _seletorSubscription;
  bool _mostrarErroReferencia = false;

  @override
  void initState() {
    super.initState();

    if (widget.referenciaPreSelecionada != null) {
      _referenciaIdController.text = widget.referenciaPreSelecionada!.id
          .toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.referenciaSeletor.setDadosSelecionados([
          widget.referenciaPreSelecionada!,
        ]);
      });
    }

    _seletorSubscription = widget.referenciaSeletor.onDataSelected?.listen((
      dados,
    ) {
      if (dados.isEmpty) {
        _referenciaIdController.clear();
      } else {
        setState(() => _mostrarErroReferencia = false);
        _referenciaIdController.text = dados.first.id.toString();
      }
    });
  }

  @override
  void dispose() {
    _seletorSubscription?.cancel();
    _valorController.dispose();
    _referenciaIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PrecosDaTabelaBloc>(
      create: (context) => sl<PrecosDaTabelaBloc>()
        ..add(PrecosDaTabelaIniciou(tabelaDePrecoId: widget.tabelaDePrecoId)),
      child: BlocConsumer<PrecosDaTabelaBloc, PrecosDaTabelaState>(
        listenWhen: (previous, current) =>
            previous.step == PrecosDaTabelaStep.salvando &&
            current.step == PrecosDaTabelaStep.carregado,
        listener: (context, state) {
          widget.referenciaSeletor.setDadosSelecionados([]);
          Navigator.of(context).pop(true);
        },
        builder: (context, state) {
          final salvando = state.step == PrecosDaTabelaStep.salvando;

          return Scaffold(
            appBar: AppBar(title: const Text('Preço da Referência')),
            body: SafeArea(
              child: Builder(
                builder: (context) {
                  if (state.step == PrecosDaTabelaStep.carregando) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (state.erro != null && state.erro!.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.erro!)));
                    });
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.referenciaSeletor,
                          if (_mostrarErroReferencia)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 12),
                              child: Text(
                                'Selecione uma referência',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _valorController,
                            enabled: !salvando,
                            autofocus: widget.referenciaPreSelecionada != null,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
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
                              onPressed: salvando ? null : _salvar,
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _salvar() {
    final referenciaId = int.tryParse(_referenciaIdController.text);
    if (referenciaId == null) {
      setState(() => _mostrarErroReferencia = true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final valor = _parseDouble(_valorController.text)!;
    context.read<PrecosDaTabelaBloc>().add(
      PrecoDaTabelaCriarSolicitado(referenciaId: referenciaId, valor: valor),
    );
  }

  bool _possuiAteDuasCasas(String value) {
    return RegExp(r'^\d+([.,]\d{1,2})?$').hasMatch(value.trim());
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}
