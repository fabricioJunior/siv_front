import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/pagamento_contexto.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart' show Pessoa;
import 'package:pessoas/uses_cases.dart' show RecuperarPessoa;

class ConsignacaoAcertoPage extends StatefulWidget {
  final Consignacao consignacao;
  final FormaPagamentoGradeWidget formaPagamentoGrade;

  const ConsignacaoAcertoPage({
    super.key,
    required this.consignacao,
    required this.formaPagamentoGrade,
  });

  @override
  State<ConsignacaoAcertoPage> createState() => _ConsignacaoAcertoPageState();
}

class _ConsignacaoAcertoPageState extends State<ConsignacaoAcertoPage> {
  ConsignacaoAcertoBloc? _bloc;
  PagamentosRealizadosBloc? _pagamentoBloc;
  String? _assinaturaSelecao;
  Pessoa? _pessoa;
  // Esc na etapa de pagamento volta à seleção sem perder o acerto já criado.
  bool _emSelecao = true;
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
    _pagamentoBloc?.close();
    super.dispose();
  }

  // E-mail e preferência de nota da consignatária; sem cadastro, abre sem eles.
  Future<Pessoa?> _carregarPessoa() async {
    final id = widget.consignacao.pessoaId;
    if (id == null) return null;
    try {
      return await sl<RecuperarPessoa>().call(idPessoa: id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _iniciarAcerto() async {
    final assinatura = [_marcados, _quantidades].join('|');
    if (_bloc != null && _assinaturaSelecao == assinatura) {
      if (_bloc!.state.step == ConsignacaoAcertoStep.aguardandoPagamento) {
        setState(() => _emSelecao = false);
        return;
      }
    }

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

    final pessoa = await _carregarPessoa();
    if (!mounted) return;

    _bloc?.close();
    _pagamentoBloc?.close();
    _pagamentoBloc = null;
    _assinaturaSelecao = assinatura;
    _pessoa = pessoa;
    setState(() {
      _emSelecao = false;
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

  // Valor adiantado (pago no ato da consignação) abate automaticamente no
  // backend (ReceberService) do total exigido nesse acerto, sem gerar
  // lançamento próprio: vira abatimento do resumo, e o operador cobra só a
  // diferença.
  PagamentoContexto _contexto(ConsignacaoAcertoState state) {
    final valorTotalProdutos = state.itens.fold<double>(
      0,
      (a, i) => a + ((i.quantidade ?? 0) * (i.valorUnitario ?? 0)),
    );
    final adiantado = (widget.consignacao.valorAdiantadoDisponivel ?? 0)
        .clamp(0, valorTotalProdutos)
        .toDouble();

    return PagamentoContexto.consignacaoAcerto(
      hashLista: 'consignacao-${widget.consignacao.id}',
      resumo: PagamentosRealizadosResumo(
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
        valorTotalProdutos: valorTotalProdutos,
      ),
      titulo: 'Consignação #${widget.consignacao.id} · acerto',
      subtitulo: widget.consignacao.nomePessoa,
      abatimentos: [
        if (adiantado > 0)
          PagamentoAbatimento(rotulo: 'Adiantado na saída', valor: adiantado),
      ],
      pessoaId: widget.consignacao.pessoaId,
      emailInicial: _pessoa?.email,
      enviarNotaPorEmailInicial: _pessoa?.enviarNotaPorEmail ?? false,
    );
  }

  void _confirmarPagamento(
    BuildContext context,
    Map<String, dynamic> resultado,
  ) {
    List<Map<String, dynamic>> lista(String chave) =>
        (resultado[chave] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    context.read<ConsignacaoAcertoBloc>().add(
          ConsignacaoAcertoPagamentoConfirmado(
            formasDePagamentoRealizadas: lista('formasDePagamentoRealizadas'),
            descontosItens: lista('descontosItens'),
            descontosPromocao: lista('descontosPromocao'),
            cupons: (resultado['cupons'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .toList(),
            valorTaxaEntrega:
                (resultado['valorTaxaEntrega'] as num?)?.toDouble() ?? 0,
            incluirCpfNaNota: resultado['incluirCpfNaNota'] as bool? ?? true,
            cpfNaNota: resultado['cpfNaNota']?.toString() ?? '',
            enviarNotaPorEmail:
                resultado['enviarNotaPorEmail'] as bool? ?? false,
            emailNota: resultado['emailNota']?.toString() ?? '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null || _emSelecao) {
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
        // Falha ao receber volta a aguardandoPagamento com erro: a etapa
        // reabre com a mensagem junto do botão.
        listenWhen: (previous, current) =>
            previous.step == ConsignacaoAcertoStep.finalizando &&
            current.step == ConsignacaoAcertoStep.aguardandoPagamento,
        listener: (context, state) => _pagamentoBloc?.add(
          PagamentosRealizadosReaberto(
            erro: state.erro ?? 'Falha ao receber o pagamento.',
          ),
        ),
        builder: (context, state) {
          if (state.step == ConsignacaoAcertoStep.aguardandoPagamento ||
              state.step == ConsignacaoAcertoStep.finalizando) {
            final contexto = _contexto(state);
            _pagamentoBloc ??= contexto.criarBloc();
            return BlocProvider.value(
              value: _pagamentoBloc!,
              child: PagamentoEtapa(
                contexto: contexto,
                formaPagamentoGrade: widget.formaPagamentoGrade,
                onConfirmado: (resultado) =>
                    _confirmarPagamento(context, resultado),
                onVoltar: () {
                  if (state.step == ConsignacaoAcertoStep.aguardandoPagamento) {
                    setState(() => _emSelecao = true);
                  }
                },
              ),
            );
          }
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

class _SelecaoItensView extends StatefulWidget {
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

  @override
  State<_SelecaoItensView> createState() => _SelecaoItensViewState();
}

enum _ModoSelecao { porItem, porMovimentacao }

class _SelecaoItensViewState extends State<_SelecaoItensView> {
  final _buscaController = TextEditingController();
  String _busca = '';
  _ModoSelecao _modo = _ModoSelecao.porItem;
  Map<int, Romaneio>? _romaneiosPorId;
  String? _erroRomaneios;

  @override
  void initState() {
    super.initState();
    _carregarRomaneios();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarRomaneios() async {
    final ids =
        widget.itens.map((item) => item.romaneioId).whereType<int>().toSet();
    try {
      final recuperarRomaneio = sl<RecuperarRomaneio>();
      final romaneios = await Future.wait(
        ids.map((id) => recuperarRomaneio.call(id)),
      );
      if (!mounted) return;
      setState(() {
        _romaneiosPorId = {for (final r in romaneios) r.id!: r};
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroRomaneios = 'Falha ao carregar movimentações.');
    }
  }

  String _nomeItem(ConsignacaoItem item) => [
        item.referenciaNome ?? 'Produto',
        item.corNome,
        item.tamanhoNome,
      ].where((s) => s != null && s.isNotEmpty).join(' - ');

  String _formatarMoeda(double valor) => 'R\$ ${valor.toStringAsFixed(2)}';

  String _rotuloOperacao(TipoOperacao? operacao) {
    switch (operacao) {
      case TipoOperacao.consignacao_saida:
        return 'Saída de produtos';
      case TipoOperacao.consignacao_devolucao:
        return 'Devolução';
      case TipoOperacao.consignacao_acerto:
        return 'Acerto';
      default:
        return 'Movimentação';
    }
  }

  String _formatarData(DateTime data) {
    final local = data.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar itens para acerto')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SegmentedButton<_ModoSelecao>(
              segments: const [
                ButtonSegment(
                  value: _ModoSelecao.porItem,
                  label: Text('Por itens'),
                  icon: Icon(Icons.checklist_outlined),
                ),
                ButtonSegment(
                  value: _ModoSelecao.porMovimentacao,
                  label: Text('Por movimentações'),
                  icon: Icon(Icons.receipt_long_outlined),
                ),
              ],
              selected: {_modo},
              onSelectionChanged: (selecionados) =>
                  setState(() => _modo = selecionados.first),
            ),
          ),
          Expanded(
            child: _modo == _ModoSelecao.porItem
                ? _buildPorItem(context)
                : _buildPorMovimentacao(context),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: widget.onContinuar,
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPorItem(BuildContext context) {
    final buscaNormalizada = _busca.trim().toLowerCase();
    final indicesVisiveis = [
      for (var i = 0; i < widget.itens.length; i++)
        if (buscaNormalizada.isEmpty ||
            _nomeItem(widget.itens[i]).toLowerCase().contains(buscaNormalizada))
          i,
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _buscaController,
            decoration: const InputDecoration(
              hintText: 'Buscar por produto, cor ou tamanho',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _busca = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              TextButton(
                onPressed: indicesVisiveis.isEmpty
                    ? null
                    : () {
                        for (final i in indicesVisiveis) {
                          widget.marcados[i] = true;
                        }
                        widget.onAlterado();
                      },
                child: const Text('Marcar todos'),
              ),
              TextButton(
                onPressed: indicesVisiveis.isEmpty
                    ? null
                    : () {
                        for (final i in indicesVisiveis) {
                          widget.marcados[i] = false;
                        }
                        widget.onAlterado();
                      },
                child: const Text('Desmarcar todos'),
              ),
            ],
          ),
        ),
        Expanded(
          child: indicesVisiveis.isEmpty
              ? const Center(child: Text('Nenhum item encontrado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: indicesVisiveis.length,
                  itemBuilder: (context, posicao) {
                    final i = indicesVisiveis[posicao];
                    final item = widget.itens[i];
                    final pendente = item.pendente ?? 0;
                    final valorPendente = item.valorPendente ?? 0;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: widget.marcados[i],
                              onChanged: (v) {
                                widget.marcados[i] = v ?? false;
                                widget.onAlterado();
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_nomeItem(item)),
                                  Text(
                                    'Pendente: ${pendente.toStringAsFixed(2)} • '
                                    '${_formatarMoeda(valorPendente)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: TextFormField(
                                enabled: widget.marcados[i],
                                initialValue:
                                    widget.quantidades[i].toStringAsFixed(2),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Qtd',
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  final parsed = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (parsed == null) return;
                                  widget.quantidades[i] =
                                      parsed.clamp(0, pendente);
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
      ],
    );
  }

  Widget _buildPorMovimentacao(BuildContext context) {
    final romaneios = _romaneiosPorId;
    if (_erroRomaneios != null) {
      return Center(child: Text(_erroRomaneios!));
    }
    if (romaneios == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final gruposPorRomaneio = <int, List<int>>{};
    for (var i = 0; i < widget.itens.length; i++) {
      final romaneioId = widget.itens[i].romaneioId;
      if (romaneioId == null) continue;
      gruposPorRomaneio.putIfAbsent(romaneioId, () => []).add(i);
    }

    final romaneioIdsOrdenados = gruposPorRomaneio.keys.toList()
      ..sort((a, b) {
        final dataA = romaneios[a]?.criadoEm ?? romaneios[a]?.data;
        final dataB = romaneios[b]?.criadoEm ?? romaneios[b]?.data;
        if (dataA == null || dataB == null) return 0;
        return dataB.compareTo(dataA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: romaneioIdsOrdenados.length,
      itemBuilder: (context, posicao) {
        final romaneioId = romaneioIdsOrdenados[posicao];
        final indices = gruposPorRomaneio[romaneioId]!;
        final romaneio = romaneios[romaneioId];
        final data = romaneio?.criadoEm ?? romaneio?.data;
        final todosMarcados = indices.every((i) => widget.marcados[i]);
        final valorTotal = indices.fold<double>(
          0,
          (soma, i) => soma + (widget.itens[i].pendente ?? 0),
        );
        final valorMonetario = indices.fold<double>(
          0,
          (soma, i) => soma + (widget.itens[i].valorPendente ?? 0),
        );

        return Card(
          child: CheckboxListTile(
            value: todosMarcados,
            onChanged: (marcar) {
              for (final i in indices) {
                widget.marcados[i] = marcar ?? false;
                widget.quantidades[i] = (marcar ?? false)
                    ? (widget.itens[i].pendente ?? 0)
                    : widget.quantidades[i];
              }
              widget.onAlterado();
            },
            title: Text(
              'ID $romaneioId • ${_rotuloOperacao(romaneio?.operacao)}',
            ),
            subtitle: Text(
              '${data != null ? _formatarData(data) : '-'} • '
              '${indices.length} produto(s) • '
              '${valorTotal.toStringAsFixed(2)} un. • '
              '${_formatarMoeda(valorMonetario)}',
            ),
          ),
        );
      },
    );
  }
}
