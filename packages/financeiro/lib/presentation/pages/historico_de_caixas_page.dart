import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:financeiro/domain/models/caixa.dart';
import 'package:financeiro/domain/models/caixa_do_historico.dart';
import 'package:financeiro/domain/models/filtro_historico_de_caixas.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

/// Terminal/usuário sem seletor pronto no `financeiro` são resolvidos via
/// callback fornecido pela rota (app-level) -- mesmo racional de
/// `HistoricoEstoquePage` (`estoque`), evita dependência nova do package
/// `financeiro` para `empresas`/`autenticacao`.
class HistoricoDeCaixasPage extends StatefulWidget {
  final Future<List<SelectData>> Function() obterTerminais;
  final Future<List<SelectData>> Function() obterUsuarios;

  const HistoricoDeCaixasPage({
    super.key,
    required this.obterTerminais,
    required this.obterUsuarios,
  });

  @override
  State<HistoricoDeCaixasPage> createState() => _HistoricoDeCaixasPageState();
}

class _HistoricoDeCaixasPageState extends State<HistoricoDeCaixasPage> {
  late final HistoricoDeCaixasBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  SelectData? _terminalSelecionado;
  SelectData? _usuarioSelecionado;
  SituacaoCaixa? _situacao;
  late DateTime _dataInicio;
  late DateTime _dataFim;

  List<SelectData> _terminais = const [];
  List<SelectData> _usuarios = const [];

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _dataFim = DateTime(hoje.year, hoje.month, hoje.day);
    _dataInicio = _dataFim.subtract(const Duration(days: 7));

    _scrollController.addListener(_onScroll);
    _bloc = sl<HistoricoDeCaixasBloc>()
      ..add(HistoricoDeCaixasIniciou(filtro: _montarFiltro()));

    widget.obterTerminais().then((terminais) {
      if (!mounted) return;
      setState(() => _terminais = terminais);
    });
    widget.obterUsuarios().then((usuarios) {
      if (!mounted) return;
      setState(() => _usuarios = usuarios);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  FiltroHistoricoDeCaixas _montarFiltro() {
    return FiltroHistoricoDeCaixas(
      terminalId: _terminalSelecionado?.id,
      operadorAberturaId: _usuarioSelecionado?.id,
      situacao: _situacao,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    );
  }

  void _recarregar() {
    _bloc.add(HistoricoDeCaixasIniciou(filtro: _montarFiltro()));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = _bloc.state;
    if (state.step == HistoricoDeCaixasStep.carregando ||
        state.step == HistoricoDeCaixasStep.carregandoMais ||
        !state.temMaisPaginas) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _bloc.add(const HistoricoDeCaixasCarregarMaisSolicitado());
    }
  }

  Future<void> _abrirFiltros() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filtros',
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SelectData>(
                      initialValue: _terminalSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Terminal',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _terminais
                          .map(
                            (terminal) => DropdownMenuItem(
                              value: terminal,
                              child: Text(terminal.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() => _terminalSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SelectData>(
                      initialValue: _usuarioSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Usuário (abertura)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _usuarios
                          .map(
                            (usuario) => DropdownMenuItem(
                              value: usuario,
                              child: Text(usuario.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() => _usuarioSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Todos'),
                          selected: _situacao == null,
                          onSelected: (_) =>
                              setSheetState(() => _situacao = null),
                        ),
                        ChoiceChip(
                          label: const Text('Aberto'),
                          selected: _situacao == SituacaoCaixa.aberto,
                          onSelected: (_) => setSheetState(
                            () => _situacao = SituacaoCaixa.aberto,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Contagem'),
                          selected: _situacao == SituacaoCaixa.contagem,
                          onSelected: (_) => setSheetState(
                            () => _situacao = SituacaoCaixa.contagem,
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Fechado'),
                          selected: _situacao == SituacaoCaixa.fechado,
                          onSelected: (_) => setSheetState(
                            () => _situacao = SituacaoCaixa.fechado,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final agora = DateTime.now();
                        final selecionado = await showDateRangePicker(
                          context: sheetContext,
                          firstDate: DateTime(agora.year - 2),
                          lastDate: agora,
                          initialDateRange: DateTimeRange(
                            start: _dataInicio,
                            end: _dataFim,
                          ),
                        );
                        if (selecionado == null) return;
                        setSheetState(() {
                          _dataInicio = selecionado.start;
                          _dataFim = selecionado.end;
                        });
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        '${_formatarData(_dataInicio)} até ${_formatarData(_dataFim)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        setState(() {});
                        _recarregar();
                      },
                      child: const Text('Aplicar filtros'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _abrirCaixa(CaixaDoHistorico caixa) {
    if (caixa.situacao == SituacaoCaixa.fechado) {
      Navigator.pushNamed(
        context,
        '/recibo_fechamento_caixa',
        arguments: {'caixaId': caixa.id},
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/fluxo_de_caixa',
      arguments: {
        'empresaId': caixa.empresaId,
        'terminalId': caixa.terminalId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoricoDeCaixasBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Histórico de Caixas'),
          actions: [
            IconButton(
              onPressed: _abrirFiltros,
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtros',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Período: ${_formatarData(_dataInicio)} até ${_formatarData(_dataFim)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child:
                    BlocBuilder<HistoricoDeCaixasBloc, HistoricoDeCaixasState>(
                  builder: (context, state) {
                    if (state.step == HistoricoDeCaixasStep.carregando &&
                        state.itens.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (state.step == HistoricoDeCaixasStep.falha &&
                        state.itens.isEmpty) {
                      return Center(
                        child: Text(
                          state.erro ?? 'Erro ao carregar histórico.',
                        ),
                      );
                    }

                    if (state.itens.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum caixa encontrado para os filtros informados.',
                        ),
                      );
                    }

                    final exibirLoaderFinal =
                        state.step == HistoricoDeCaixasStep.carregandoMais;

                    return ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          state.itens.length + (exibirLoaderFinal ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= state.itens.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        }
                        final caixa = state.itens[index];
                        return _CaixaDoHistoricoCard(
                          caixa: caixa,
                          onTap: () => _abrirCaixa(caixa),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatarData(DateTime data) {
  final local = data.toLocal();
  String dois(int v) => v.toString().padLeft(2, '0');
  return '${dois(local.day)}/${dois(local.month)}/${local.year}';
}

String _formatarHora(DateTime data) {
  final local = data.toLocal();
  String dois(int v) => v.toString().padLeft(2, '0');
  return '${dois(local.hour)}:${dois(local.minute)}';
}

class _CaixaDoHistoricoCard extends StatelessWidget {
  final CaixaDoHistorico caixa;
  final VoidCallback onTap;

  const _CaixaDoHistoricoCard({required this.caixa, required this.onTap});

  (String, Color) get _situacaoInfo => switch (caixa.situacao) {
        SituacaoCaixa.aberto => ('Aberto', Colors.green),
        SituacaoCaixa.contagem => ('Em contagem', Colors.amber.shade800),
        SituacaoCaixa.fechado => ('Fechado', Colors.blueGrey),
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (situacaoLabel, situacaoCor) = _situacaoInfo;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Caixa #${caixa.id}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: situacaoCor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      situacaoLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: situacaoCor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Abertura: ${_formatarData(caixa.abertura)} ${_formatarHora(caixa.abertura)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
              if (caixa.fechamento != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Fechamento: ${_formatarData(caixa.fechamento!)} ${_formatarHora(caixa.fechamento!)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Aberto por: ${caixa.operadorAberturaNome}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
