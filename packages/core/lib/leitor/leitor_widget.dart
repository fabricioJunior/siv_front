import 'package:core/bloc.dart';
import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/leitor/leitor_bloc/leitor_bloc.dart';
import 'package:core/leitor/leitor_busca_bloc/leitor_busca_bloc.dart';
import 'package:core/leitor/leitor_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeitorWidget extends StatefulWidget {
  final bool controlarQuantidade;
  final ILeitorDataDatasource dataSource;
  final LeitorController? controller;
  final ValueChanged<LeitorItemContado>? onUltimoProdutoLido;
  final ValueChanged<String>? onErro;
  final ValueChanged<String>? onAviso;
  final String campoCodigoHint;
  final double alturaLista;
  final bool autofocus;
  final int? tabelaDePrecoId;
  final bool aceitarApenasProdutosComPreco;
  final ILeitorBuscaDataDatasource? buscaDataSource;

  const LeitorWidget({
    super.key,
    required this.dataSource,
    this.controlarQuantidade = false,
    this.controller,
    this.onUltimoProdutoLido,
    this.onErro,
    this.onAviso,
    this.campoCodigoHint = 'Bipe ou informe o código de barras',
    this.alturaLista = 320,
    this.autofocus = true,
    this.tabelaDePrecoId,
    this.aceitarApenasProdutosComPreco = false,
    this.buscaDataSource,
  });

  @override
  State<LeitorWidget> createState() => _LeitorWidgetState();
}

enum _LeitorVisualizacao { porProduto, historico, grade }

class _LeitorWidgetState extends State<LeitorWidget> {
  late LeitorBloc _bloc;
  late LeitorController _controller;
  late final TextEditingController _codigoController;
  late final FocusNode _codigoFocusNode;
  bool _controllerInterno = false;
  bool _modoRemocao = false;
  _LeitorVisualizacao _visualizacao = _LeitorVisualizacao.historico;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController();
    _codigoFocusNode = FocusNode();
    _controllerInterno = widget.controller == null;
    _controller = widget.controller ?? LeitorController();
    _bloc = _criarBloc();
    _controller.bind(_bloc);
  }

  @override
  void didUpdateWidget(covariant LeitorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final mudouDataSource =
        oldWidget.dataSource.runtimeType != widget.dataSource.runtimeType;
    final mudouConfiguracao =
        oldWidget.controlarQuantidade != widget.controlarQuantidade ||
            oldWidget.tabelaDePrecoId != widget.tabelaDePrecoId ||
            oldWidget.aceitarApenasProdutosComPreco !=
                widget.aceitarApenasProdutosComPreco;

    if (mudouDataSource || mudouConfiguracao) {
      final estadoAtual = _bloc.state;
      _controller.unbind(_bloc);
      _bloc.close();
      _bloc = _criarBloc(estadoInicial: estadoAtual);
      _controller.bind(_bloc);
    }

    if (oldWidget.controller != widget.controller) {
      _controller.unbind(_bloc);
      if (_controllerInterno) {
        _controller.dispose();
      }

      _controllerInterno = widget.controller == null;
      _controller = widget.controller ?? LeitorController();
      _controller.bind(_bloc);
    }
  }

  @override
  void dispose() {
    _controller.unbind(_bloc);
    _bloc.close();
    _codigoController.dispose();
    _codigoFocusNode.dispose();
    if (_controllerInterno) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    // Durante o hot reload, mantenha o estado atual do leitor ao religar o bloc.
    if (_bloc.isClosed) {
      _bloc = _criarBloc(estadoInicial: _controller.state);
    }
    _controller.bind(_bloc);
    _controller.syncState(_bloc.state);
  }

  LeitorBloc _criarBloc({LeitorState? estadoInicial}) {
    return LeitorBloc(
      dataSource: widget.dataSource,
      controlarQuantidade: widget.controlarQuantidade,
      tabelaDePrecoId: widget.tabelaDePrecoId,
      aceitarApenasProdutosComPreco: widget.aceitarApenasProdutosComPreco,
      estadoInicial: estadoInicial,
    );
  }

  void _submeterCodigo() {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      _solicitarFoco();
      return;
    }

    _codigoController.clear();
    if (_modoRemocao) {
      _controller.removerQuantidade(codigo);
    } else {
      _controller.lerCodigo(codigo);
    }

    _solicitarFoco();
  }

  void _solicitarFoco() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _codigoFocusNode.requestFocus();
      }
    });
  }

  void _mostrarMensagem(BuildContext context, String mensagem, Color cor) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exibirErro(String texto) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: _modoRemocao
              ? const Text('Erro ao remover item')
              : const Text('Erro ao ler item'),
          content: Text(texto),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatarDataHora(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    final segundo = dataHora.second.toString().padLeft(2, '0');
    return '$dia/$mes $hora:$minuto:$segundo';
  }

  String _rotuloTamanhoCor({required String tamanho, required String cor}) {
    final tamanhoNormalizado = tamanho.trim().isEmpty ? '-' : tamanho.trim();
    final corNormalizada = cor.trim().isEmpty ? '-' : cor.trim();
    return 'Cor: $corNormalizada  •  Tam: $tamanhoNormalizado';
  }

  String _normalizarRotuloGrade(String valor, {String fallback = '-'}) {
    final normalizado = valor.trim();
    return normalizado.isEmpty ? fallback : normalizado;
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _descricaoPreco(LeitorItemContado item) {
    final valorUnitario = item.valorUnitario;
    if (valorUnitario == null || valorUnitario <= 0) {
      return 'Preço não cadastrado';
    }

    return 'Preço: ${_formatarMoeda(valorUnitario)}  •  Total: ${_formatarMoeda(item.valorTotal)}';
  }

  String _nomeReferencia(List<LeitorItemContado> itensReferencia) {
    for (final item in itensReferencia) {
      final descricao = item.descricao.trim();
      if (descricao.isNotEmpty) {
        return descricao;
      }
    }
    return 'Sem descricao';
  }

  Future<void> _abrirBuscaManual() async {
    final buscaDataSource = widget.buscaDataSource;
    if (buscaDataSource == null) return;

    final resultado = await showDialog<({LeitorData produto, int quantidade})>(
      context: context,
      builder: (dialogContext) => _BuscaProdutoDialog(
        buscaDataSource: buscaDataSource,
        tabelaDePrecoId: widget.tabelaDePrecoId,
        modoRemocao: _modoRemocao,
      ),
    );

    if (resultado == null) {
      _solicitarFoco();
      return;
    }

    final codigo = resultado.produto.codigoDeBarras;
    final quantidade = resultado.quantidade;

    if (_modoRemocao) {
      _controller.removerQuantidade(codigo, quantidade: quantidade);
    } else {
      _controller.lerCodigoComQuantidade(codigo, quantidade);
    }

    _solicitarFoco();
  }

  Widget _gradePorReferencia(LeitorState state) {
    if (state.itens.isEmpty) {
      return Center(
        child: Text(
          'Nenhum produto lido ainda.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final itensPorReferencia = <int, List<LeitorItemContado>>{};
    for (final item in state.itens) {
      itensPorReferencia.putIfAbsent(item.idReferencia, () => []).add(item);
    }

    final referenciasOrdenadas = itensPorReferencia.keys.toList()..sort();

    return ListView.separated(
      itemCount: referenciasOrdenadas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final referencia = referenciasOrdenadas[index];
        final itensReferencia = itensPorReferencia[referencia]!;
        final nomeReferencia = _nomeReferencia(itensReferencia);

        final cores = itensReferencia
            .map((item) => _normalizarRotuloGrade(item.cor))
            .toSet()
            .toList()
          ..sort();
        final tamanhos = itensReferencia
            .map((item) => _normalizarRotuloGrade(item.tamanho))
            .toSet()
            .toList()
          ..sort();

        final gradeQuantidade = <String, Map<String, int>>{};
        for (final item in itensReferencia) {
          final cor = _normalizarRotuloGrade(item.cor);
          final tamanho = _normalizarRotuloGrade(item.tamanho);
          final linha = gradeQuantidade.putIfAbsent(cor, () => {});
          linha[tamanho] = (linha[tamanho] ?? 0) + item.quantidadeLida;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Referência $referencia',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                nomeReferencia,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.8,
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Cor \\ Tam',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...tamanhos.map(
                          (tamanho) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              tamanho,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...cores.map(
                      (cor) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(cor),
                          ),
                          ...tamanhos.map(
                            (tamanho) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '${gradeQuantidade[cor]?[tamanho] ?? 0}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _resumoInfoCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required ColorScheme colorScheme,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<LeitorBloc, LeitorState>(
        bloc: _bloc,
        listener: (context, state) {
          _onBlocChangeState(state, context);
        },
        builder: (context, state) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leitor de código de barras',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codigoController,
                          focusNode: _codigoFocusNode,
                          autofocus: widget.autofocus,
                          decoration: InputDecoration(
                            labelText: _modoRemocao
                                ? 'Código para remover'
                                : 'Código de barras',
                            hintText: _modoRemocao
                                ? 'Bipe para remover 1 unidade do item'
                                : widget.campoCodigoHint,
                            suffixIcon: state.processando
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submeterCodigo(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: state.processando ? null : _submeterCodigo,
                        icon: Icon(
                          _modoRemocao
                              ? Icons.remove_circle_outline
                              : Icons.qr_code,
                        ),
                        label: Text(_modoRemocao ? 'Remover' : 'Ler'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        avatar: Icon(
                          _modoRemocao
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline,
                          size: 18,
                        ),
                        tooltip: _modoRemocao
                            ? 'Toque para voltar ao modo leitura'
                            : 'Toque para ativar remoção por leitura',
                        label: Text(
                          _modoRemocao
                              ? 'Removendo por leitura (toque para desativar)'
                              : 'Ativar remoção por leitura',
                        ),
                        selected: _modoRemocao,
                        onSelected: (_) {
                          setState(() {
                            _modoRemocao = !_modoRemocao;
                          });
                          _solicitarFoco();
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.refresh_outlined, size: 18),
                        label: const Text('Limpar leitura'),
                        onPressed: state.itens.isEmpty
                            ? null
                            : () => _controller.limpar(),
                      ),
                      if (widget.buscaDataSource != null)
                        ActionChip(
                          avatar: const Icon(Icons.search_outlined, size: 18),
                          label: const Text('Busca manual'),
                          onPressed:
                              state.processando ? null : _abrirBuscaManual,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _resumoInfoCard(
                          icon: Icons.inventory_2_outlined,
                          titulo: 'Itens distintos',
                          valor: '${state.itens.length}',
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                        _resumoInfoCard(
                          icon: Icons.numbers_outlined,
                          titulo: 'Quantidade total',
                          valor: '${state.quantidadeTotalLida}',
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                        if (widget.tabelaDePrecoId != null)
                          _resumoInfoCard(
                            icon: Icons.attach_money_outlined,
                            titulo: 'Valor total',
                            valor: _formatarMoeda(state.valorTotalLido),
                            colorScheme: Theme.of(context).colorScheme,
                          ),
                        _resumoInfoCard(
                          icon: state.controlarQuantidade
                              ? Icons.lock_outline
                              : Icons.lock_open_outlined,
                          titulo: 'Controle por estoque',
                          valor:
                              state.controlarQuantidade ? 'Ativo' : 'Inativo',
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  SegmentedButton<_LeitorVisualizacao>(
                    segments: const [
                      ButtonSegment<_LeitorVisualizacao>(
                        value: _LeitorVisualizacao.historico,
                        icon: Icon(Icons.history_outlined),
                        label: Text('Histórico'),
                      ),
                      ButtonSegment<_LeitorVisualizacao>(
                        value: _LeitorVisualizacao.porProduto,
                        icon: Icon(Icons.inventory_2_outlined),
                        label: Text('Por produto'),
                      ),
                      ButtonSegment<_LeitorVisualizacao>(
                        value: _LeitorVisualizacao.grade,
                        icon: Icon(Icons.grid_view_outlined),
                        label: Text('Grade'),
                      ),
                    ],
                    selected: {_visualizacao},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _visualizacao = selection.first;
                      });
                    },
                  ),
                  const Divider(),
                  if (state.ultimoProdutoLido != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Último produto lido',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(state.ultimoProdutoLido!.descricao),
                          Text(
                            '${state.ultimoProdutoLido!.codigoDeBarras}  •  Quantidade: ${state.ultimoProdutoLido!.quantidadeLida}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _rotuloTamanhoCor(
                              tamanho: state.ultimoProdutoLido!.tamanho,
                              cor: state.ultimoProdutoLido!.cor,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (widget.tabelaDePrecoId != null)
                            Text(
                              _descricaoPreco(state.ultimoProdutoLido!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: widget.alturaLista,
                    child: switch (_visualizacao) {
                      _LeitorVisualizacao.porProduto => state.itens.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum produto lido ainda.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              itemCount: state.itens.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = state.itens[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.descricao),
                                  subtitle: Text(
                                    '${item.codigoDeBarras}  •  ${_rotuloTamanhoCor(tamanho: item.tamanho, cor: item.cor)}\nLidos: ${item.quantidadeLida}${state.controlarQuantidade ? '  •  Estoque: ${item.estoqueDisponivel}' : ''}${widget.tabelaDePrecoId != null ? '\n${_descricaoPreco(item)}' : ''}',
                                  ),
                                  trailing: Wrap(
                                    spacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      IconButton(
                                        tooltip: 'Remover uma unidade',
                                        onPressed: () =>
                                            _controller.removerQuantidade(
                                          item.codigoDeBarras,
                                        ),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Excluir item da contagem',
                                        onPressed: () =>
                                            _controller.removerItem(
                                          item.codigoDeBarras,
                                        ),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      _LeitorVisualizacao.historico => state.historico.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhuma movimentação registrada ainda.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              itemCount: state.historico.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final registro = state.historico[
                                    state.historico.length - 1 - index];
                                final foiAdicao =
                                    registro.tipo == LeitorHistoricoTipo.adicao;
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    foiAdicao
                                        ? Icons.add_circle_outline
                                        : Icons.remove_circle_outline,
                                    color: foiAdicao
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                  title: Text(
                                    '${foiAdicao ? 'Adicionado' : 'Removido'} ${registro.quantidade} un. - ${registro.descricao}',
                                  ),
                                  subtitle: Text(
                                    '${registro.codigoDeBarras}  •  ${_rotuloTamanhoCor(tamanho: registro.tamanho, cor: registro.cor)}\nSaldo do item: ${registro.quantidadeAposOperacao}  •  ${_formatarDataHora(registro.dataHora)}',
                                  ),
                                );
                              },
                            ),
                      _LeitorVisualizacao.grade => _gradePorReferencia(state),
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onBlocChangeState(LeitorState state, BuildContext context) {
    final previousState = _controller.state;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (state.tokenUltimoProduto != previousState.tokenUltimoProduto &&
          state.ultimoProdutoLido != null) {
        widget.onUltimoProdutoLido?.call(state.ultimoProdutoLido!);
      }

      if (state.tokenErro != previousState.tokenErro && state.erro != null) {
        widget.onErro?.call(state.erro!);
        _exibirErro(state.erro!);
        SystemSound.play(SystemSoundType.alert);
      }

      if (state.tokenAviso != previousState.tokenAviso && state.aviso != null) {
        widget.onAviso?.call(state.aviso!);
        _mostrarMensagem(context, state.aviso!, Colors.orange.shade700);
        SystemSound.play(SystemSoundType.alert);
      }

      _controller.syncState(state);
      _solicitarFoco();
    });
  }
}

class _BuscaProdutoDialog extends StatefulWidget {
  final ILeitorBuscaDataDatasource buscaDataSource;
  final int? tabelaDePrecoId;
  final bool modoRemocao;

  const _BuscaProdutoDialog({
    required this.buscaDataSource,
    this.tabelaDePrecoId,
    required this.modoRemocao,
  });

  @override
  State<_BuscaProdutoDialog> createState() => _BuscaProdutoDialogState();
}

class _BuscaProdutoDialogState extends State<_BuscaProdutoDialog> {
  late final LeitorBuscaBloc _buscaBloc;
  final _textoController = TextEditingController();
  final _textoFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _buscaBloc = LeitorBuscaBloc(
      dataSource: widget.buscaDataSource,
      tabelaDePrecoId: widget.tabelaDePrecoId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textoFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _buscaBloc.close();
    _textoController.dispose();
    _textoFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selecionarProduto(LeitorData produto) async {
    final quantidade = await showDialog<int>(
      context: context,
      builder: (ctx) => _QuantidadeDialog(
        produto: produto,
        modoRemocao: widget.modoRemocao,
      ),
    );
    if (quantidade == null || quantidade <= 0) return;
    if (!mounted) return;
    Navigator.of(context).pop((produto: produto, quantidade: quantidade));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _buscaBloc,
      child: BlocBuilder<LeitorBuscaBloc, LeitorBuscaState>(
        builder: (context, state) {
          final resultadosFiltrados = state.resultadosFiltrados;

          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.modoRemocao
                                ? 'Busca manual — Remover produto'
                                : 'Busca manual de produto',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textoController,
                      focusNode: _textoFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Buscar produto',
                        hintText: 'Digite o nome ou código da referência',
                        suffixIcon: state.processando
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(Icons.search_outlined),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) => _buscaBloc
                          .add(LeitorBuscaTextoBuscado(v)),
                      onChanged: (v) => _buscaBloc
                          .add(LeitorBuscaTextoBuscado(v)),
                    ),
                    if (state.tamanhosDisponiveis.isNotEmpty ||
                        state.coresDisponiveis.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (state.tamanhosDisponiveis.isNotEmpty) ...[
                              Text(
                                'Tam:',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(width: 4),
                              ...state.tamanhosDisponiveis.map(
                                (t) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: FilterChip(
                                    label: Text(t),
                                    selected: state.tamanhoFiltro == t,
                                    onSelected: (sel) => _buscaBloc.add(
                                      LeitorBuscaTamanhoFiltrado(sel ? t : null),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (state.coresDisponiveis.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Cor:',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(width: 4),
                              ...state.coresDisponiveis.map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: FilterChip(
                                    label: Text(c),
                                    selected: state.corFiltro == c,
                                    onSelected: (sel) => _buscaBloc.add(
                                      LeitorBuscaCorFiltrada(sel ? c : null),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (state.erro != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          state.erro!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    Flexible(
                      child: _textoController.text.trim().isEmpty
                          ? Center(
                              child: Text(
                                'Digite para buscar produtos.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : resultadosFiltrados.isEmpty && !state.processando
                              ? Center(
                                  child: Text(
                                    'Nenhum produto encontrado.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: resultadosFiltrados.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final produto = resultadosFiltrados[index];
                                    final tamanho = produto.tamanho.trim();
                                    final cor = produto.cor.trim();
                                    final subtitulo = [
                                      if (cor.isNotEmpty) 'Cor: $cor',
                                      if (tamanho.isNotEmpty) 'Tam: $tamanho',
                                      'Cód: ${produto.codigoDeBarras}',
                                    ].join('  •  ');
                                    return ListTile(
                                      title: Text(produto.descricao),
                                      subtitle: Text(subtitulo),
                                      trailing: const Icon(
                                        Icons.chevron_right_outlined,
                                      ),
                                      onTap: () => _selecionarProduto(produto),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuantidadeDialog extends StatefulWidget {
  final LeitorData produto;
  final bool modoRemocao;

  const _QuantidadeDialog({
    required this.produto,
    required this.modoRemocao,
  });

  @override
  State<_QuantidadeDialog> createState() => _QuantidadeDialogState();
}

class _QuantidadeDialogState extends State<_QuantidadeDialog> {
  final _quantidadeController = TextEditingController(text: '1');
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _quantidadeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _quantidadeController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _confirmar() {
    final quantidade = int.tryParse(_quantidadeController.text.trim()) ?? 0;
    if (quantidade <= 0) return;
    Navigator.of(context).pop(quantidade);
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = widget.produto.tamanho.trim();
    final cor = widget.produto.cor.trim();
    final rotulo = [
      if (cor.isNotEmpty) 'Cor: $cor',
      if (tamanho.isNotEmpty) 'Tam: $tamanho',
    ].join('  •  ');

    return AlertDialog(
      title: Text(
        widget.modoRemocao ? 'Quantidade a remover' : 'Quantidade a adicionar',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.produto.descricao,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (rotulo.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              rotulo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _quantidadeController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantidade',
              hintText: 'Informe a quantidade',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _confirmar(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: Text(widget.modoRemocao ? 'Remover' : 'Adicionar'),
        ),
      ],
    );
  }
}

class LeitorController extends ChangeNotifier {
  LeitorBloc? _bloc;
  LeitorState _state = LeitorState.initial();

  LeitorState get state => _state;
  List<LeitorItemContado> get itens => List.unmodifiable(_state.itens);
  List<LeitorHistoricoRegistro> get historico =>
      List.unmodifiable(_state.historico);
  LeitorItemContado? get ultimoProdutoLido => _state.ultimoProdutoLido;
  String? get ultimoErro => _state.erro;
  int get quantidadeTotalLida => _state.quantidadeTotalLida;
  double get valorTotalLido => _state.valorTotalLido;
  int get quantidadeItensDistintos => _state.itens.length;
  bool get controlarQuantidade => _state.controlarQuantidade;

  List<Map<String, dynamic>> get dadosAtuais {
    return _state.itens
        .map(
          (item) => {
            'codigoDeBarras': item.codigoDeBarras,
            'descricao': item.descricao,
            'idReferencia': item.idReferencia,
            'tamanho': item.tamanho,
            'cor': item.cor,
            'quantidadeLida': item.quantidadeLida,
            'estoqueDisponivel': item.estoqueDisponivel,
            'valorUnitario': item.valorUnitario,
            'valorTotal': item.valorTotal,
            ...item.dados,
          },
        )
        .toList(growable: false);
  }

  void bind(LeitorBloc bloc) {
    _bloc = bloc;
    syncState(bloc.state);
  }

  void unbind(LeitorBloc bloc) {
    if (identical(_bloc, bloc)) {
      _bloc = null;
    }
  }

  void syncState(LeitorState state) {
    _state = state;
    notifyListeners();
  }

  void lerCodigo(String codigo) {
    _bloc?.add(LeitorCodigoInformado(codigo));
  }

  void lerCodigoComQuantidade(String codigo, int quantidade) {
    _bloc?.add(LeitorCodigoInformado(codigo, quantidade: quantidade));
  }

  void removerQuantidade(String codigo, {int quantidade = 1}) {
    _bloc?.add(
      LeitorQuantidadeRemovida(codigo: codigo, quantidade: quantidade),
    );
  }

  void removerItem(String codigo) {
    _bloc?.add(LeitorItemExcluido(codigo));
  }

  void limpar() {
    _bloc?.add(const LeitorReiniciado());
  }
}
