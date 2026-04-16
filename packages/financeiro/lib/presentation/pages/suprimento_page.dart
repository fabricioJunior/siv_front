import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuprimentoPage extends StatefulWidget {
  final int caixaId;

  const SuprimentoPage({
    super.key,
    required this.caixaId,
  });

  @override
  State<SuprimentoPage> createState() => _SuprimentoPageState();
}

class _SuprimentoPageState extends State<SuprimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SuprimentoBloc>(
      create: (_) =>
          sl<SuprimentoBloc>()..add(SuprimentoIniciou(caixaId: widget.caixaId)),
      child: BlocConsumer<SuprimentoBloc, SuprimentoState>(
        listenWhen: (previous, current) =>
            previous.step != current.step || previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == SuprimentoStep.validacaoInvalida ||
              state.step == SuprimentoStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.erro ?? 'Falha ao criar o suprimento. Tente novamente.',
                ),
              ),
            );
          }

          if (state.step == SuprimentoStep.criado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Suprimento criado com sucesso.')),
            );
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          _sincronizarControllers(state);
          final salvando = state.step == SuprimentoStep.salvando;

          return Scaffold(
            appBar: AppBar(title: const Text('Novo suprimento')),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: salvando
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<SuprimentoBloc>().add(SuprimentoSalvou());
                      }
                    },
              icon: salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(salvando ? 'Salvando...' : 'Salvar'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.point_of_sale_outlined),
                          title: const Text('Caixa de destino'),
                          subtitle: Text('ID do caixa: ${widget.caixaId}'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Dados do suprimento',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _valorController,
                        decoration: const InputDecoration(
                          labelText: 'Valor',
                          hintText: 'Ex: 150,00',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9,\.]')),
                        ],
                        validator: (value) {
                          final valor = _parseValor(value ?? '');
                          if (valor == null || valor <= 0) {
                            return 'Informe um valor válido';
                          }
                          return null;
                        },
                        onChanged: (value) => _onCampoAlterado(
                          context,
                          valor: value,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Informe o motivo do suprimento',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        minLines: 2,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'A descrição é obrigatória';
                          }
                          return null;
                        },
                        onChanged: (value) => _onCampoAlterado(
                          context,
                          descricao: value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _sincronizarControllers(SuprimentoState state) {
    if (_valorController.text != state.valor) {
      _valorController.value = TextEditingValue(
        text: state.valor,
        selection: TextSelection.collapsed(offset: state.valor.length),
      );
    }

    if (_descricaoController.text != state.descricao) {
      _descricaoController.value = TextEditingValue(
        text: state.descricao,
        selection: TextSelection.collapsed(offset: state.descricao.length),
      );
    }
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? valor,
    String? descricao,
  }) {
    context.read<SuprimentoBloc>().add(
          SuprimentoCampoAlterado(
            valor: valor,
            descricao: descricao,
          ),
        );
  }

  double? _parseValor(String texto) {
    final valor = texto.trim();
    if (valor.isEmpty) {
      return null;
    }

    final normalizado = valor.contains(',') && valor.contains('.')
        ? valor.replaceAll('.', '').replaceAll(',', '.')
        : valor.replaceAll(',', '.');

    return double.tryParse(normalizado);
  }
}
