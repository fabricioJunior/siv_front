import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SangriaPage extends StatefulWidget {
  final int caixaId;

  const SangriaPage({
    super.key,
    required this.caixaId,
  });

  @override
  State<SangriaPage> createState() => _SangriaPageState();
}

class _SangriaPageState extends State<SangriaPage> {
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
    return BlocProvider<SangriaBloc>(
      create: (_) =>
          sl<SangriaBloc>()..add(SangriaIniciou(caixaId: widget.caixaId)),
      child: BlocConsumer<SangriaBloc, SangriaState>(
        listenWhen: (previous, current) =>
            previous.step != current.step || previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == SangriaStep.validacaoInvalida ||
              state.step == SangriaStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.erro ?? 'Falha ao criar a sangria. Tente novamente.',
                ),
              ),
            );
          }

          if (state.step == SangriaStep.criado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sangria criada com sucesso.')),
            );
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          _sincronizarControllers(state);
          final salvando = state.step == SangriaStep.salvando;

          final cores = context.sivColors;
          final textos = context.sivTextos;

          return Scaffold(
            appBar: AppBar(title: const Text('Nova sangria')),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: salvando
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<SangriaBloc>().add(SangriaSalvou());
                      }
                    },
              icon: salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(salvando ? 'Salvando...' : 'Salvar sangria'),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: cores.superficie,
                                  borderRadius: BorderRadius.circular(
                                    SivDimensoes.raio,
                                  ),
                                  border: Border.all(color: cores.hairline),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.point_of_sale_outlined,
                                      color: cores.aco,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CAIXA DE ORIGEM',
                                          style: textos.rotulo.copyWith(
                                            color: cores.textoApoio,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                        Text(
                                          '#${widget.caixaId}',
                                          style: textos.secao.copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ...sivCantosBlueprint(cores.hairline),
                            ],
                          ),
                          const SizedBox(height: SivDimensoes.gapCards),
                          TextFormField(
                            controller: _valorController,
                            decoration: const InputDecoration(
                              labelText: 'Valor',
                              hintText: 'Ex: 150,00',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descricaoController,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              hintText: 'Motivo da sangria…',
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
              ),
            ),
          );
        },
      ),
    );
  }

  void _sincronizarControllers(SangriaState state) {
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
    context.read<SangriaBloc>().add(
          SangriaCampoAlterado(
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
