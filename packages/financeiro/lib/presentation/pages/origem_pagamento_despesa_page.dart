import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
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

  @override
  void dispose() {
    _nomeController.dispose();
    _diaVencimentoController.dispose();
    super.dispose();
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
            title: Text(
              widget.id == null ? 'Nova origem de pagamento' : 'Editar origem',
            ),
          ),
          floatingActionButton:
              BlocBuilder<OrigemPagamentoDespesaBloc, OrigemPagamentoDespesaState>(
            builder: (context, state) {
              final salvando =
                  state.step == OrigemPagamentoDespesaStep.salvando ||
                      state.step == OrigemPagamentoDespesaStep.carregando;
              return FloatingActionButton(
                onPressed: salvando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context
                              .read<OrigemPagamentoDespesaBloc>()
                              .add(OrigemPagamentoDespesaSalvou());
                        }
                      },
                child: salvando
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.check),
              );
            },
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

              final tipo = state.tipo ?? TipoOrigemPagamentoDespesa.dinheiro;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(labelText: 'Nome'),
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
                        const SizedBox(height: 12),
                        DropdownButtonFormField<TipoOrigemPagamentoDespesa>(
                          initialValue: tipo,
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          items: TipoOrigemPagamentoDespesa.values
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            context.read<OrigemPagamentoDespesaBloc>().add(
                                  OrigemPagamentoDespesaCampoAlterado(
                                    tipo: value,
                                  ),
                                );
                          },
                        ),
                        if (tipo.diaVencimentoObrigatorio) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _diaVencimentoController,
                            decoration: const InputDecoration(
                              labelText: 'Dia de vencimento',
                              hintText: 'Ex: 10',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              final dia = int.tryParse(value ?? '');
                              if (dia == null || dia <= 0 || dia > 31) {
                                return 'Informe um dia válido (1-31)';
                              }
                              return null;
                            },
                            onChanged: (value) => context
                                .read<OrigemPagamentoDespesaBloc>()
                                .add(
                                  OrigemPagamentoDespesaCampoAlterado(
                                    diaVencimento: int.tryParse(value),
                                  ),
                                ),
                          ),
                        ],
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
}
