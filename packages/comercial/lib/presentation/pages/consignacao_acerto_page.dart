import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

class ConsignacaoAcertoPage extends StatefulWidget {
  final Consignacao consignacao;
  final SeletorWidget formasDePagamentoSeletor;

  const ConsignacaoAcertoPage({
    super.key,
    required this.consignacao,
    required this.formasDePagamentoSeletor,
  });

  @override
  State<ConsignacaoAcertoPage> createState() => _ConsignacaoAcertoPageState();
}

class _ConsignacaoAcertoPageState extends State<ConsignacaoAcertoPage> {
  late final ConsignacaoAcertoBloc _bloc;
  bool _dialogoAberto = false;
  bool _fechando = false;

  @override
  void initState() {
    super.initState();

    final itensPendentes = widget.consignacao.itens
        .where((item) => (item.pendente ?? 0) > 0)
        .toList();
    final romaneiosOrigem = widget.consignacao.itens
        .map((item) => item.romaneioId)
        .whereType<int>()
        .toSet()
        .toList();

    _bloc = ConsignacaoAcertoBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      consignacaoId: widget.consignacao.id!,
      funcionarioId: widget.consignacao.funcionarioId,
      tabelaPrecoId: widget.consignacao.tabelaPrecoId,
      itensPendentes: itensPendentes,
      romaneiosOrigem: romaneiosOrigem,
    )..add(const ConsignacaoAcertoIniciado());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsignacaoAcertoBloc>.value(
      value: _bloc,
      child: BlocConsumer<ConsignacaoAcertoBloc, ConsignacaoAcertoState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) async {
          if (state.step == ConsignacaoAcertoStep.aguardandoPagamento &&
              !_dialogoAberto) {
            _dialogoAberto = true;
            final resultado = await showDialog<Map<String, dynamic>>(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return PagamentosRealizadosWidget(
                  hashLista: 'consignacao-${widget.consignacao.id}',
                  resumoInicial: PagamentosRealizadosResumo(
                    listaCompartilhada: null,
                    produtosCompartilhados: state.itens
                        .map(
                          (item) => ProdutoCompartilhado.create(
                            produtoId: item.produtoId ?? 0,
                            quantidade: (item.quantidade ?? 0).toInt(),
                            valorUnitario: item.valorUnitario ?? 0,
                            nome: item.referenciaNome ?? 'Produto',
                            corNome: item.corNome ?? '',
                            tamanhoNome: item.tamanhoNome ?? '',
                          ),
                        )
                        .toList(),
                    quantidadeTotalProdutos: state.itens
                        .fold<double>(0, (a, i) => a + (i.quantidade ?? 0))
                        .toInt(),
                    valorTotalProdutos: state.itens.fold<double>(
                      0,
                      (a, i) => a + ((i.quantidade ?? 0) * (i.valorUnitario ?? 0)),
                    ),
                  ),
                  pessoaId: widget.consignacao.pessoaId,
                  formasDePagamentoSeletor: widget.formasDePagamentoSeletor,
                );
              },
            );

            _dialogoAberto = false;
            if (!context.mounted) return;

            if (resultado == null) {
              Navigator.of(context).pop(false);
              return;
            }

            final formasRaw = resultado['formasDePagamentoRealizadas']
                    as List<dynamic>? ??
                const [];
            final formas = formasRaw
                .whereType<Map<String, dynamic>>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            final incluirCpfNaNota =
                resultado['incluirCpfNaNota'] as bool? ?? true;
            final cpfNaNota = resultado['cpfNaNota']?.toString() ?? '';

            context.read<ConsignacaoAcertoBloc>().add(
                  ConsignacaoAcertoPagamentoConfirmado(
                    formasDePagamentoRealizadas: formas,
                    incluirCpfNaNota: incluirCpfNaNota,
                    cpfNaNota: cpfNaNota,
                  ),
                );
          }

          if (state.step == ConsignacaoAcertoStep.falha &&
              state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Finalizar consignação')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: switch (state.step) {
                ConsignacaoAcertoStep.processando ||
                ConsignacaoAcertoStep.aguardandoPagamento ||
                ConsignacaoAcertoStep.finalizando =>
                  const Center(child: CircularProgressIndicator.adaptive()),
                ConsignacaoAcertoStep.falha => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.erro ??
                              'Falha ao finalizar a consignação.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(
                            state.romaneio != null,
                          ),
                          child: const Text('Voltar'),
                        ),
                      ],
                    ),
                  ),
                ConsignacaoAcertoStep.sucesso => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Acerto realizado com sucesso (romaneio #${state.romaneio?.id}).',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _fechando
                              ? null
                              : () async {
                                  setState(() => _fechando = true);
                                  try {
                                    await sl<FecharConsignacao>()
                                        .call(widget.consignacao.id!);
                                    if (context.mounted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            mensagemDeErroApi(
                                              e,
                                              'Falha ao fechar a consignação.',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    setState(() => _fechando = false);
                                  }
                                },
                          icon: _fechando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.lock_outline),
                          label: const Text('Fechar consignação'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Voltar sem fechar'),
                        ),
                      ],
                    ),
                  ),
              },
            ),
          );
        },
      ),
    );
  }
}
