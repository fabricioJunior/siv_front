import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

class AbrirConsignacaoPage extends StatefulWidget {
  final SeletorWidget pessoaSeletor;
  final SeletorWidget funcionarioSeletor;
  final SeletorWidget tabelaDePrecoSeletor;

  const AbrirConsignacaoPage({
    super.key,
    required this.pessoaSeletor,
    required this.funcionarioSeletor,
    required this.tabelaDePrecoSeletor,
  });

  @override
  State<AbrirConsignacaoPage> createState() => _AbrirConsignacaoPageState();
}

class _AbrirConsignacaoPageState extends State<AbrirConsignacaoPage> {
  final TextEditingController _observacaoController = TextEditingController();

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AbrirConsignacaoBloc>(
      create: (_) => sl<AbrirConsignacaoBloc>(),
      child: BlocConsumer<AbrirConsignacaoBloc, AbrirConsignacaoState>(
        listenWhen: (previous, current) =>
            (previous.erro != current.erro && current.erro != null) ||
            (previous.step != current.step &&
                current.step == AbrirConsignacaoStep.sucesso),
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }

          final consignacao = state.consignacaoCriada;
          if (state.step == AbrirConsignacaoStep.sucesso &&
              consignacao != null) {
            Navigator.of(context).pushReplacementNamed(
              '/consignacao_bipagem',
              arguments: {
                'consignacaoId': consignacao.id,
                'pessoaId': consignacao.pessoaId,
                'funcionarioId': consignacao.funcionarioId,
                'tabelaPrecoId': consignacao.tabelaPrecoId,
                'origem': OrigemCompartilhadaTipo.consignacaoSaida.name,
              },
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<AbrirConsignacaoBloc>();

          return Scaffold(
            appBar: AppBar(title: const Text('Abrir consignação')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Dados da consignação',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        widget.pessoaSeletor.buildComParametros(
                          SeletorParamentros(
                            itemsSelecionadosInicial:
                                state.pessoaSelecionada == null
                                    ? null
                                    : [state.pessoaSelecionada!],
                            onChanged: (selecionados) {
                              bloc.add(
                                AbrirConsignacaoPessoaSelecionada(
                                  pessoaSelecionada: selecionados.isEmpty
                                      ? null
                                      : selecionados.first,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        widget.funcionarioSeletor.buildComParametros(
                          SeletorParamentros(
                            itemsSelecionadosInicial:
                                state.funcionarioSelecionado == null
                                    ? null
                                    : [state.funcionarioSelecionado!],
                            onChanged: (selecionados) {
                              bloc.add(
                                AbrirConsignacaoFuncionarioSelecionado(
                                  funcionarioSelecionado: selecionados.isEmpty
                                      ? null
                                      : selecionados.first,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        widget.tabelaDePrecoSeletor.buildComParametros(
                          SeletorParamentros(
                            itemsSelecionadosInicial:
                                state.tabelaSelecionada == null
                                    ? null
                                    : [state.tabelaSelecionada!],
                            onChanged: (selecionados) {
                              bloc.add(
                                AbrirConsignacaoTabelaSelecionada(
                                  tabelaSelecionada: selecionados.isEmpty
                                      ? null
                                      : selecionados.first,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _observacaoController,
                          maxLength: 254,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Observação (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => bloc.add(
                            AbrirConsignacaoObservacaoAlterada(
                              observacao: value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: state.podeConfirmar
                              ? () => bloc.add(
                                    const AbrirConsignacaoConfirmarSolicitado(),
                                  )
                              : null,
                          icon: state.step == AbrirConsignacaoStep.salvando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                          label: Text(
                            state.step == AbrirConsignacaoStep.salvando
                                ? 'Abrindo...'
                                : 'Abrir consignação e ler produtos',
                          ),
                        ),
                      ],
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
}
