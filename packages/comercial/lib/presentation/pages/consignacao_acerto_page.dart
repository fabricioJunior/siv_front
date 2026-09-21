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
  ConsignacaoAcertoBloc? _bloc;
  bool _dialogoAberto = false;
  bool _fechando = false;

  late final List<ConsignacaoItem> _itensPendentesOriginais;
  late final List<bool> _marcados;
  late final List<double> _quantidades;

  @override
  void initState() {
    super.initState();

    _itensPendentesOriginais = widget.consignacao.itens
        .where((item) => (item.pendente ?? 0) > 0)
        .toList();
    _marcados = List.filled(_itensPendentesOriginais.length, false);
    _quantidades =
        _itensPendentesOriginais.map((item) => item.pendente ?? 0).toList();
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  void _iniciarAcerto() {
    final selecionados = <ConsignacaoItem>[];
    for (var i = 0; i < _itensPendentesOriginais.length; i++) {
      if (!_marcados[i]) continue;
      final original = _itensPendentesOriginais[i];
      final pendenteOriginal = original.pendente ?? 0;
      final valorPendenteOriginal = original.valorPendente ?? 0;
      final valorUnitario =
          pendenteOriginal > 0 ? valorPendenteOriginal / pendenteOriginal : 0.0;
      final quantidade = _quantidades[i];
      if (quantidade <= 0) continue;

      selecionados.add(
        ConsignacaoItem.create(
          empresaId: original.empresaId,
          consignacaoId: original.consignacaoId,
          pessoaId: original.pessoaId,
          romaneioId: original.romaneioId,
          sequencia: original.sequencia,
          produtoId: original.produtoId,
          referenciaNome: original.referenciaNome,
          corNome: original.corNome,
          tamanhoNome: original.tamanhoNome,
          pendente: quantidade,
          valorPendente: quantidade * valorUnitario,
          operadorId: original.operadorId,
        ),
      );
    }

    if (selecionados.isEmpty) return;

    final romaneiosOrigem = selecionados
        .map((item) => item.romaneioId)
        .whereType<int>()
        .toSet()
        .toList();

    setState(() {
      _bloc = ConsignacaoAcertoBloc(
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        consignacaoId: widget.consignacao.id!,
        funcionarioId: widget.consignacao.funcionarioId,
        tabelaPrecoId: widget.consignacao.tabelaPrecoId,
        itensPendentes: selecionados,
        romaneiosOrigem: romaneiosOrigem,
      )..add(const ConsignacaoAcertoIniciado());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null) {
      return _SelecaoItensView(
        itens: _itensPendentesOriginais,
        marcados: _marcados,
        quantidades: _quantidades,
        onAlterado: () => setState(() {}),
        onContinuar: _marcados.contains(true) ? _iniciarAcerto : null,
      );
    }

    return BlocProvider<ConsignacaoAcertoBloc>.value(
      value: bloc,
      child: BlocConsumer<ConsignacaoAcertoBloc, ConsignacaoAcertoState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) async {
          if (state.step == ConsignacaoAcertoStep.aguardandoPagamento &&
              !_dialogoAberto) {
            if (state.erro != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.erro!)),
              );
            }

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
                      (a, i) =>
                          a + ((i.quantidade ?? 0) * (i.valorUnitario ?? 0)),
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

            final formasRaw =
                resultado['formasDePagamentoRealizadas'] as List<dynamic>? ??
                    const [];
            final formas = formasRaw
                .whereType<Map<String, dynamic>>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            final descontosItensRaw =
                resultado['descontosItens'] as List<dynamic>? ?? const [];
            final descontosItens = descontosItensRaw
                .whereType<Map<String, dynamic>>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            final descontosPromocaoRaw =
                resultado['descontosPromocao'] as List<dynamic>? ?? const [];
            final descontosPromocao = descontosPromocaoRaw
                .whereType<Map<String, dynamic>>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
            final incluirCpfNaNota =
                resultado['incluirCpfNaNota'] as bool? ?? true;
            final cpfNaNota = resultado['cpfNaNota']?.toString() ?? '';

            context.read<ConsignacaoAcertoBloc>().add(
                  ConsignacaoAcertoPagamentoConfirmado(
                    formasDePagamentoRealizadas: formas,
                    descontosItens: descontosItens,
                    descontosPromocao: descontosPromocao,
                    incluirCpfNaNota: incluirCpfNaNota,
                    cpfNaNota: cpfNaNota,
                  ),
                );
          }

          if (state.step == ConsignacaoAcertoStep.falha && state.erro != null) {
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
                          state.erro ?? 'Falha ao finalizar a consignação.',
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

class _SelecaoItensView extends StatelessWidget {
  final List<ConsignacaoItem> itens;
  final List<bool> marcados;
  final List<double> quantidades;
  final VoidCallback onAlterado;
  final VoidCallback? onContinuar;

  const _SelecaoItensView({
    required this.itens,
    required this.marcados,
    required this.quantidades,
    required this.onAlterado,
    required this.onContinuar,
  });

  String _formatarMoeda(double valor) => 'R\$ ${valor.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar itens para acerto')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: itens.length,
              itemBuilder: (context, i) {
                final item = itens[i];
                final pendente = item.pendente ?? 0;
                final valorPendente = item.valorPendente ?? 0;
                final nome = [
                  item.referenciaNome ?? 'Produto',
                  item.corNome,
                  item.tamanhoNome,
                ].where((s) => s != null && s.isNotEmpty).join(' - ');

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: marcados[i],
                          onChanged: (v) {
                            marcados[i] = v ?? false;
                            onAlterado();
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nome),
                              Text(
                                'Pendente: ${pendente.toStringAsFixed(2)} • '
                                '${_formatarMoeda(valorPendente)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: TextFormField(
                            enabled: marcados[i],
                            initialValue: quantidades[i].toStringAsFixed(2),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Qtd',
                              isDense: true,
                            ),
                            onChanged: (value) {
                              final parsed =
                                  double.tryParse(value.replaceAll(',', '.'));
                              if (parsed == null) return;
                              quantidades[i] = parsed.clamp(0, pendente);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: onContinuar,
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}
