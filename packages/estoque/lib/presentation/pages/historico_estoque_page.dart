import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:estoque/domain/models/filtro_historico_estoque.dart';
import 'package:estoque/domain/models/historico_estoque.dart';
import 'package:estoque/presentation.dart';
import 'package:flutter/material.dart';

/// Filtros sem seletor pronto no app (produto/operador/caixa) são resolvidos
/// aqui de forma simples:
/// - produto: campo numérico direto para `produtoId` (não existe autocomplete
///   de produto no app).
/// - operador/caixa: callback fornecido pela rota (app-level), populando um
///   dropdown simples -- evita criar dependência nova do package `estoque`
///   para `autenticacao`/`empresas`.
class HistoricoEstoquePage extends StatefulWidget {
  final SeletorWidget seletorReferencia;
  final SeletorWidget seletorFuncionario;
  final Future<List<SelectData>> Function() obterUsuarios;
  final Future<List<SelectData>> Function() obterCaixas;

  const HistoricoEstoquePage({
    super.key,
    required this.seletorReferencia,
    required this.seletorFuncionario,
    required this.obterUsuarios,
    required this.obterCaixas,
  });

  @override
  State<HistoricoEstoquePage> createState() => _HistoricoEstoquePageState();
}

class _HistoricoEstoquePageState extends State<HistoricoEstoquePage> {
  late final HistoricoEstoqueBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  int? _referenciaId;
  int? _funcionarioId;
  int? _produtoId;
  SelectData? _usuarioSelecionado;
  SelectData? _caixaSelecionado;
  late DateTime _dataInicio;
  late DateTime _dataFim;

  List<SelectData> _usuarios = const [];
  List<SelectData> _caixas = const [];

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _dataInicio = agora.subtract(const Duration(hours: 24));
    _dataFim = agora;

    _scrollController.addListener(_onScroll);
    _bloc = sl<HistoricoEstoqueBloc>()
      ..add(
        HistoricoEstoqueIniciou(filtro: _montarFiltro()),
      );

    widget.obterUsuarios().then((usuarios) {
      if (!mounted) return;
      setState(() => _usuarios = usuarios);
    });
    widget.obterCaixas().then((caixas) {
      if (!mounted) return;
      setState(() => _caixas = caixas);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  FiltroHistoricoEstoque _montarFiltro() {
    return FiltroHistoricoEstoque(
      referenciaId: _referenciaId,
      produtoId: _produtoId,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
      operadorId: _usuarioSelecionado?.id,
      funcionarioId: _funcionarioId,
      caixaId: _caixaSelecionado?.id,
    );
  }

  void _recarregar() {
    _bloc.add(HistoricoEstoqueIniciou(filtro: _montarFiltro()));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = _bloc.state;
    if (state.step == HistoricoEstoqueStep.carregando ||
        state.step == HistoricoEstoqueStep.carregandoMais ||
        !state.temMaisPaginas) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _bloc.add(const HistoricoEstoqueCarregarMaisSolicitado());
    }
  }

  Future<DateTime?> _selecionarDataHora(DateTime inicial) async {
    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(inicial.year - 5),
      lastDate: DateTime(inicial.year + 1),
    );
    if (data == null || !mounted) return null;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
    );
    if (hora == null) return null;

    return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
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
                    widget.seletorReferencia.call(
                      onChanged: (dados) {
                        _referenciaId = dados.isEmpty ? null : dados.first.id;
                      },
                    ),
                    const SizedBox(height: 12),
                    widget.seletorFuncionario.call(
                      onChanged: (dados) {
                        _funcionarioId = dados.isEmpty ? null : dados.first.id;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _produtoId?.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ID do produto',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _produtoId = int.tryParse(value.trim());
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SelectData>(
                      initialValue: _usuarioSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Usuário (operador)',
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
                    DropdownButtonFormField<SelectData>(
                      initialValue: _caixaSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Caixa (terminal)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _caixas
                          .map(
                            (caixa) => DropdownMenuItem(
                              value: caixa,
                              child: Text(caixa.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() => _caixaSelecionado = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final selecionada = await _selecionarDataHora(
                                _dataInicio,
                              );
                              if (selecionada == null) return;
                              setSheetState(() => _dataInicio = selecionada);
                            },
                            icon: const Icon(Icons.event),
                            label: Text(_formatarDataHora(_dataInicio)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final selecionada = await _selecionarDataHora(
                                _dataFim,
                              );
                              if (selecionada == null) return;
                              setSheetState(() => _dataFim = selecionada);
                            },
                            icon: const Icon(Icons.event_available),
                            label: Text(_formatarDataHora(_dataFim)),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoricoEstoqueBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Histórico de Estoque'),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Período: ${_formatarDataHora(_dataInicio)} até ${_formatarDataHora(_dataFim)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<HistoricoEstoqueBloc, HistoricoEstoqueState>(
                  builder: (context, state) {
                    if (state.step == HistoricoEstoqueStep.carregando &&
                        state.itens.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (state.step == HistoricoEstoqueStep.falha &&
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
                          'Nenhuma movimentação encontrada para os filtros informados.',
                        ),
                      );
                    }

                    final exibirLoaderFinal =
                        state.step == HistoricoEstoqueStep.carregandoMais;

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
                        return _HistoricoEstoqueCard(
                          item: state.itens[index],
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

String _formatarDataHora(DateTime data) {
  final local = data.toLocal();
  String dois(int v) => v.toString().padLeft(2, '0');
  return '${dois(local.day)}/${dois(local.month)}/${local.year} ${dois(local.hour)}:${dois(local.minute)}';
}

class _HistoricoEstoqueCard extends StatelessWidget {
  final HistoricoEstoque item;

  const _HistoricoEstoqueCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final corQuantidade = item.ehEntrada ? Colors.green : Colors.red;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.referenciaNome}${item.corNome != null ? ' • ${item.corNome}' : ''}${item.tamanhoNome != null ? ' • ${item.tamanhoNome}' : ''}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  item.quantidade > 0
                      ? '+${item.quantidade.toStringAsFixed(0)}'
                      : item.quantidade.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: corQuantidade,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Romaneio #${item.romaneioId}  •  ${_formatarDataHora(item.dataHora)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 4),
            Text(
              'Saldo após: ${item.saldoApos.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (item.pessoaNome != null) ...[
              const SizedBox(height: 4),
              Text(
                'Cliente: ${item.pessoaNome}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (item.funcionarioNome != null || item.operadorNome != null) ...[
              const SizedBox(height: 4),
              Text(
                [
                  if (item.funcionarioNome != null)
                    'Funcionário: ${item.funcionarioNome}',
                  if (item.operadorNome != null)
                    'Usuário: ${item.operadorNome}',
                ].join('  •  '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/romaneio',
                    arguments: {
                      'idRomaneio': item.romaneioId,
                      'permitirEdicao': false,
                    },
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('Ir ao romaneio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
