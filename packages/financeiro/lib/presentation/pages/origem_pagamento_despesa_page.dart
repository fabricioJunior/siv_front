import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/validacao_origem_pagamento_despesa.dart';
import 'package:financeiro/presentation/widgets/card_blueprint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrigemPagamentoDespesaPage extends StatefulWidget {
  final int? id;

  const OrigemPagamentoDespesaPage({super.key, this.id});

  @override
  State<OrigemPagamentoDespesaPage> createState() =>
      _OrigemPagamentoDespesaPageState();
}

class _OrigemPagamentoDespesaPageState
    extends State<OrigemPagamentoDespesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _diaVencimentoController = TextEditingController();
  final _prazoFechamentoDiasController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _diaVencimentoController.dispose();
    _prazoFechamentoDiasController.dispose();
    super.dispose();
  }

  void _salvar(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<OrigemPagamentoDespesaBloc>().add(
            OrigemPagamentoDespesaSalvou(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

    return BlocProvider<OrigemPagamentoDespesaBloc>(
      create: (_) => sl<OrigemPagamentoDespesaBloc>()
        ..add(
          OrigemPagamentoDespesaIniciou(empresaId: empresaId, id: widget.id),
        ),
      child: BlocListener<OrigemPagamentoDespesaBloc, OrigemPagamentoDespesaState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == OrigemPagamentoDespesaStep.validacaoInvalida ||
              state.step == OrigemPagamentoDespesaStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(state.erro ?? 'Falha ao salvar origem de pagamento.'),
              ),
            );
          }
          if (state.step == OrigemPagamentoDespesaStep.criado ||
              state.step == OrigemPagamentoDespesaStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.id == null ? 'Nova origem' : 'Editar origem',
            ),
          ),
          body: BlocBuilder<OrigemPagamentoDespesaBloc, OrigemPagamentoDespesaState>(
            builder: (context, state) {
              if (state.step == OrigemPagamentoDespesaStep.carregando) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              final nome = state.nome ?? '';
              if (_nomeController.text != nome) {
                _nomeController.value = TextEditingValue(
                  text: nome,
                  selection: TextSelection.collapsed(offset: nome.length),
                );
              }
              final diaVencimento = (state.diaVencimento ?? '').toString();
              if (_diaVencimentoController.text != diaVencimento) {
                _diaVencimentoController.value = TextEditingValue(
                  text: diaVencimento == 'null' ? '' : diaVencimento,
                  selection:
                      TextSelection.collapsed(offset: diaVencimento.length),
                );
              }

              final prazoFechamentoDias = (state.prazoFechamentoDias ?? '').toString();
              if (_prazoFechamentoDiasController.text != prazoFechamentoDias) {
                _prazoFechamentoDiasController.value = TextEditingValue(
                  text: prazoFechamentoDias == 'null' ? '' : prazoFechamentoDias,
                  selection:
                      TextSelection.collapsed(offset: prazoFechamentoDias.length),
                );
              }

              final tipo = state.tipo ?? TipoOrigemPagamentoDespesa.dinheiro;
              final salvando =
                  state.step == OrigemPagamentoDespesaStep.salvando;

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _RotuloCampo('NOME'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nomeController,
                                decoration: const InputDecoration(
                                  hintText: 'Ex: Banco do Brasil',
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                        ? 'Informe o nome'
                                        : null,
                                onChanged: (value) => context
                                    .read<OrigemPagamentoDespesaBloc>()
                                    .add(
                                      OrigemPagamentoDespesaCampoAlterado(
                                        nome: value,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 18),
                              _RotuloCampo('TIPO'),
                              const SizedBox(height: 6),
                              _SeletorTipo(
                                selecionado: tipo,
                                onSelecionar: (t) => context
                                    .read<OrigemPagamentoDespesaBloc>()
                                    .add(
                                      OrigemPagamentoDespesaCampoAlterado(
                                          tipo: t),
                                    ),
                              ),
                              if (tipo.diaVencimentoObrigatorio) ...[
                                const SizedBox(height: 18),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _CampoNumeroGrande(
                                        rotulo: 'DIA DE VENCIMENTO',
                                        controller: _diaVencimentoController,
                                        validator: (value) =>
                                            validarDiaVencimento(
                                                int.tryParse(value ?? '')),
                                        onChanged: (value) => context
                                            .read<OrigemPagamentoDespesaBloc>()
                                            .add(
                                              OrigemPagamentoDespesaCampoAlterado(
                                                diaVencimento:
                                                    int.tryParse(value),
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _CampoNumeroGrande(
                                        rotulo: 'FECHA DIAS ANTES',
                                        controller:
                                            _prazoFechamentoDiasController,
                                        validator: (value) =>
                                            validarPrazoFechamentoDias(
                                                int.tryParse(value ?? '')),
                                        onChanged: (value) => context
                                            .read<OrigemPagamentoDespesaBloc>()
                                            .add(
                                              OrigemPagamentoDespesaCampoAlterado(
                                                prazoFechamentoDias:
                                                    int.tryParse(value),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _NotaVencimento(
                                  diaVencimento: state.diaVencimento,
                                  prazoFechamentoDias:
                                      state.prazoFechamentoDias,
                                ),
                              ] else ...[
                                const SizedBox(height: 14),
                                _NotaSimples(
                                  texto:
                                      'Sem vencimento próprio — a despesa usa a data informada no lançamento.',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    _RodapeAcoes(salvando: salvando, onSalvar: () => _salvar(context)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RotuloCampo extends StatelessWidget {
  final String texto;

  const _RotuloCampo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(texto, style: context.sivTextos.rotulo.copyWith(fontSize: 11));
  }
}

class _SeletorTipo extends StatelessWidget {
  final TipoOrigemPagamentoDespesa selecionado;
  final ValueChanged<TipoOrigemPagamentoDespesa> onSelecionar;

  const _SeletorTipo({required this.selecionado, required this.onSelecionar});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return CardBlueprint(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tipo in TipoOrigemPagamentoDespesa.values)
            InkWell(
              onTap: () => onSelecionar(tipo),
              child: Container(
                constraints:
                    const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: tipo != TipoOrigemPagamentoDespesa.values.last
                    ? BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: cores.hairline)))
                    : null,
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cores.aco, width: 1.5),
                        color: tipo == selecionado
                            ? cores.acoAtivo
                            : Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(tipo.label, style: textos.corpo.copyWith(fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CampoNumeroGrande extends StatelessWidget {
  final String rotulo;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;

  const _CampoNumeroGrande({
    required this.rotulo,
    required this.controller,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RotuloCampo(rotulo),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: context.sivTextos.valor.copyWith(fontSize: 19),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _NotaVencimento extends StatelessWidget {
  final int? diaVencimento;
  final int? prazoFechamentoDias;

  const _NotaVencimento({this.diaVencimento, this.prazoFechamentoDias});

  @override
  Widget build(BuildContext context) {
    final dia = diaVencimento;
    final prazo = prazoFechamentoDias;
    if (dia == null || prazo == null) {
      return const _NotaSimples(
        texto:
            'Compras depois do fechamento da fatura vencem no mês seguinte.',
      );
    }
    final vencimento = DateTime(DateTime.now().year, DateTime.now().month, dia);
    final fechamento = vencimento.subtract(Duration(days: prazo)).day;
    return _NotaSimples(
      texto: 'Fatura fecha dia $fechamento. Compras depois do fechamento '
          'vencem no mês seguinte.',
    );
  }
}

class _NotaSimples extends StatelessWidget {
  final String texto;

  const _NotaSimples({required this.texto});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.selecaoFundo,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(texto,
            style: context.sivTextos.apoio.copyWith(color: cores.acoProfundo)),
      ),
    );
  }
}

class _RodapeAcoes extends StatelessWidget {
  final bool salvando;
  final VoidCallback onSalvar;

  const _RodapeAcoes({required this.salvando, required this.onSalvar});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(top: BorderSide(color: cores.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: salvando ? null : () => Navigator.of(context).pop(false),
                child: const Text('Descartar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: salvando ? null : onSalvar,
                child: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                      )
                    : const Text('Salvar origem'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
