import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DespesaDoCaixaPage extends StatefulWidget {
  final int caixaId;

  const DespesaDoCaixaPage({
    super.key,
    required this.caixaId,
  });

  @override
  State<DespesaDoCaixaPage> createState() => _DespesaDoCaixaPageState();
}

class _DespesaDoCaixaPageState extends State<DespesaDoCaixaPage> {
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
    return BlocProvider<DespesaDoCaixaBloc>(
      create: (_) =>
          sl<DespesaDoCaixaBloc>()..add(DespesaDoCaixaIniciou(caixaId: widget.caixaId)),
      child: BlocConsumer<DespesaDoCaixaBloc, DespesaDoCaixaState>(
        listenWhen: (previous, current) =>
            previous.step != current.step || previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == DespesaDoCaixaStep.validacaoInvalida ||
              state.step == DespesaDoCaixaStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.erro ?? 'Falha ao lançar a despesa. Tente novamente.',
                ),
              ),
            );
          }

          if (state.step == DespesaDoCaixaStep.criado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Despesa lançada com sucesso.')),
            );
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          _sincronizarControllers(state);
          final salvando = state.step == DespesaDoCaixaStep.salvando;

          final cores = context.sivColors;
          final textos = context.sivTextos;

          return Scaffold(
            appBar: AppBar(title: const Text('Nova despesa')),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: salvando
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<DespesaDoCaixaBloc>().add(DespesaDoCaixaSalvou());
                      }
                    },
              icon: salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(salvando ? 'Salvando...' : 'Salvar despesa'),
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
                          DropdownButtonFormField<int>(
                            initialValue: state.categoriaId,
                            decoration: const InputDecoration(
                              labelText: 'Categoria',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: [
                              for (final c in state.categorias)
                                DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nome),
                                ),
                            ],
                            validator: (value) =>
                                value == null ? 'Selecione a categoria' : null,
                            onChanged: (value) => _onCampoAlterado(
                              context,
                              categoriaId: value,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descricaoController,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              hintText: 'Descreva a despesa…',
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

  void _sincronizarControllers(DespesaDoCaixaState state) {
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
    int? categoriaId,
  }) {
    context.read<DespesaDoCaixaBloc>().add(
          DespesaDoCaixaCampoAlterado(
            valor: valor,
            descricao: descricao,
            categoriaId: categoriaId,
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
