import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormaDePagamentoPage extends StatefulWidget {
  static const tipos = [
    'Dinheiro',
    'Pix',
    'Cartão',
    'Fatura',
    'Cheque',
    'Troco',
    'Voucher',
    'TED/DOC',
    'Adiantamento',
    'Crédito de devolução',
  ];

  final int? idFormaDePagamento;

  const FormaDePagamentoPage({super.key, this.idFormaDePagamento});

  @override
  State<FormaDePagamentoPage> createState() => _FormaDePagamentoPageState();
}

class _FormaDePagamentoPageState extends State<FormaDePagamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _inicioController = TextEditingController();
  final _parcelasController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    _inicioController.dispose();
    _parcelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormaDePagamentoBloc>(
      create: (_) => sl<FormaDePagamentoBloc>()
        ..add(
          FormaDePagamentoIniciou(
            idFormaDePagamento: widget.idFormaDePagamento,
          ),
        ),
      child: BlocListener<FormaDePagamentoBloc, FormaDePagamentoState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == FormaDePagamentoStep.validacaoInvalida ||
              state.step == FormaDePagamentoStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.erro ?? 'Falha ao salvar forma de pagamento.',
                ),
              ),
            );
          }

          if (state.step == FormaDePagamentoStep.criado ||
              state.step == FormaDePagamentoStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.idFormaDePagamento == null
                  ? 'Nova forma de pagamento'
                  : 'Editar forma de pagamento',
            ),
          ),
          floatingActionButton:
              BlocBuilder<FormaDePagamentoBloc, FormaDePagamentoState>(
            builder: (context, state) {
              final salvando = state.step == FormaDePagamentoStep.salvando ||
                  state.step == FormaDePagamentoStep.carregando;

              return FloatingActionButton(
                onPressed: salvando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<FormaDePagamentoBloc>().add(
                                FormaDePagamentoSalvou(),
                              );
                        }
                      },
                child: salvando
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.check),
              );
            },
          ),
          body: BlocBuilder<FormaDePagamentoBloc, FormaDePagamentoState>(
            builder: (context, state) {
              if (state.step == FormaDePagamentoStep.carregando) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              _sincronizarControllers(state);

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuracao basica',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: const InputDecoration(
                            labelText: 'Descricao',
                            hintText: 'Ex: Cartao credito 3x',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a descricao';
                            }
                            return null;
                          },
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            descricao: value,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue:
                              FormaDePagamentoPage.tipos.contains(state.tipo)
                                  ? state.tipo
                                  : FormaDePagamentoPage.tipos.first,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                          ),
                          items: FormaDePagamentoPage.tipos
                              .map(
                                (tipo) => DropdownMenuItem<String>(
                                  value: tipo,
                                  child: Text(tipo),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            tipo: value,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _inicioController,
                          decoration: const InputDecoration(
                            labelText: 'Numero inicial',
                            hintText: 'Ex: 1',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            inicio: int.tryParse(value) ?? 0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _parcelasController,
                          decoration: const InputDecoration(
                            labelText: 'Parcelas',
                            hintText: 'Ex: 1',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            final parcelas = int.tryParse(value ?? '');
                            if (parcelas == null || parcelas <= 0) {
                              return 'Informe uma quantidade valida';
                            }
                            return null;
                          },
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            parcelas: int.tryParse(value) ?? 0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Inativa'),
                          subtitle: const Text(
                            'Quando ativa, a forma continua cadastrada mas deixa de ser padrao para novas operacoes.',
                          ),
                          value: state.inativa ?? false,
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            inativa: value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _sincronizarControllers(FormaDePagamentoState state) {
    final descricao = state.descricao ?? '';
    final inicio = (state.inicio ?? 0).toString();
    final parcelas = (state.parcelas ?? 1).toString();

    if (_descricaoController.text != descricao) {
      _descricaoController.value = TextEditingValue(
        text: descricao,
        selection: TextSelection.collapsed(offset: descricao.length),
      );
    }

    if (_inicioController.text != inicio) {
      _inicioController.value = TextEditingValue(
        text: inicio,
        selection: TextSelection.collapsed(offset: inicio.length),
      );
    }

    if (_parcelasController.text != parcelas) {
      _parcelasController.value = TextEditingValue(
        text: parcelas,
        selection: TextSelection.collapsed(offset: parcelas.length),
      );
    }
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? descricao,
    int? inicio,
    int? parcelas,
    String? tipo,
    bool? inativa,
  }) {
    context.read<FormaDePagamentoBloc>().add(
          FormaDePagamentoCampoAlterado(
            descricao: descricao,
            inicio: inicio,
            parcelas: parcelas,
            tipo: tipo,
            inativa: inativa,
          ),
        );
  }
}
