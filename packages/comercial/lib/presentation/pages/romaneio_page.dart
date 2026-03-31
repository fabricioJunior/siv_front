import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RomaneioPage extends StatefulWidget {
  final int? idRomaneio;

  const RomaneioPage({super.key, this.idRomaneio});

  @override
  State<RomaneioPage> createState() => _RomaneioPageState();
}

class _RomaneioPageState extends State<RomaneioPage> {
  static const _operacoes = [
    'compra',
    'compra_devolucao',
    'venda',
    'venda_devolucao',
    'consignacao_saida',
    'consignacao_devolucao',
    'consignacao_acerto',
    'transferencia_saida',
    'transferencia_entrada',
    'transferencia_devolucao',
    'outros',
  ];

  final _formKey = GlobalKey<FormState>();
  final _pessoaIdController = TextEditingController();
  final _funcionarioIdController = TextEditingController();
  final _tabelaPrecoIdController = TextEditingController();
  final _observacaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pessoaIdController.dispose();
    _funcionarioIdController.dispose();
    _tabelaPrecoIdController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RomaneioBloc>(
      create: (_) => sl<RomaneioBloc>()
        ..add(RomaneioIniciou(idRomaneio: widget.idRomaneio)),
      child: BlocListener<RomaneioBloc, RomaneioState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == RomaneioStep.criado ||
              state.step == RomaneioStep.salvo) {
            Navigator.of(context).pop(true);
            return;
          }

          if (state.step == RomaneioStep.observacaoAtualizada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Observacao atualizada com sucesso.'),
              ),
            );
            return;
          }

          if (state.step == RomaneioStep.validacaoInvalida ||
              state.step == RomaneioStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.erro ?? 'Falha ao processar romaneio.'),
              ),
            );
          }
        },
        child: BlocBuilder<RomaneioBloc, RomaneioState>(
          builder: (context, state) {
            final carregando = state.step == RomaneioStep.carregando ||
                state.step == RomaneioStep.salvando ||
                state.step == RomaneioStep.processando;

            if (state.step != RomaneioStep.carregando) {
              _sincronizarControllers(state);
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.idRomaneio == null
                    ? 'Novo romaneio'
                    : 'Romaneio #${widget.idRomaneio}'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: carregando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<RomaneioBloc>().add(RomaneioSalvou());
                        }
                      },
                child: const Icon(Icons.save),
              ),
              body: state.step == RomaneioStep.carregando
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _pessoaIdController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Pessoa ID',
                              ),
                              validator: _required,
                              onChanged: (value) => _onCampoAlterado(
                                context,
                                pessoaId: value,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _funcionarioIdController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Funcionario ID',
                              ),
                              validator: _required,
                              onChanged: (value) => _onCampoAlterado(
                                context,
                                funcionarioId: value,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _tabelaPrecoIdController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Tabela de preco ID',
                              ),
                              validator: _required,
                              onChanged: (value) => _onCampoAlterado(
                                context,
                                tabelaPrecoId: value,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _operacoes.contains(state.operacao)
                                  ? state.operacao
                                  : _operacoes[2],
                              decoration:
                                  const InputDecoration(labelText: 'Operacao'),
                              items: _operacoes
                                  .map(
                                    (op) => DropdownMenuItem(
                                      value: op,
                                      child: Text(op),
                                    ),
                                  )
                                  .toList(),
                              onChanged: carregando
                                  ? null
                                  : (value) => _onCampoAlterado(
                                        context,
                                        operacao: value,
                                      ),
                            ),
                            if (state.id != null) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _observacaoController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Observacao',
                                ),
                                onChanged: (value) => _onCampoAlterado(
                                  context,
                                  observacao: value,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.icon(
                                  onPressed: carregando
                                      ? null
                                      : () {
                                          context.read<RomaneioBloc>().add(
                                                RomaneioObservacaoAtualizada(
                                                  observacao:
                                                      _observacaoController
                                                          .text,
                                                ),
                                              );
                                        },
                                  icon: const Icon(Icons.edit_note),
                                  label: const Text('Atualizar observacao'),
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
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    return null;
  }

  void _sincronizarControllers(RomaneioState state) {
    _sincronizarController(_pessoaIdController, state.pessoaId ?? '');
    _sincronizarController(_funcionarioIdController, state.funcionarioId ?? '');
    _sincronizarController(_tabelaPrecoIdController, state.tabelaPrecoId ?? '');
    _sincronizarController(_observacaoController, state.observacao ?? '');
  }

  void _sincronizarController(TextEditingController controller, String value) {
    if (controller.text == value) return;

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? pessoaId,
    String? funcionarioId,
    String? tabelaPrecoId,
    String? operacao,
    String? observacao,
  }) {
    context.read<RomaneioBloc>().add(
          RomaneioCampoAlterado(
            pessoaId: pessoaId,
            funcionarioId: funcionarioId,
            tabelaPrecoId: tabelaPrecoId,
            operacao: operacao,
            observacao: observacao,
          ),
        );
  }
}
