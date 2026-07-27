import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/leitor.dart';
import 'package:flutter/material.dart';
import 'package:precos/presentation.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/consultar_produto_bloc/consultar_produto_bloc.dart';

class ConsultarProdutoPage extends StatelessWidget {
  const ConsultarProdutoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConsultarProdutoBloc>(
      create: (_) => sl<ConsultarProdutoBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Consultar produto')),
        body: const _ConsultarProdutoBody(),
      ),
    );
  }
}

class _ConsultarProdutoBody extends StatefulWidget {
  const _ConsultarProdutoBody();

  @override
  State<_ConsultarProdutoBody> createState() => _ConsultarProdutoBodyState();
}

class _ConsultarProdutoBodyState extends State<_ConsultarProdutoBody> {
  final _codigoController = TextEditingController();
  final _codigoFocusNode = FocusNode();
  int? _tabelaDePrecoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codigoFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _codigoFocusNode.dispose();
    super.dispose();
  }

  void _submeterCodigo() {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      _solicitarFoco();
      return;
    }
    _codigoController.clear();
    context.read<ConsultarProdutoBloc>().add(ConsultarProdutoCodigoLido(codigo));
    _solicitarFoco();
  }

  void _solicitarFoco() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codigoFocusNode.requestFocus();
    });
  }

  Future<void> _abrirBuscaManual() async {
    final buscaDataSource = sl<ILeitorBuscaDataDatasource>();
    final produto = await showDialog<LeitorData>(
      context: context,
      builder: (dialogContext) => _BuscaManualDialog(
        buscaDataSource: buscaDataSource,
        tabelaDePrecoId: _tabelaDePrecoId,
      ),
    );

    if (produto == null) {
      _solicitarFoco();
      return;
    }

    if (!mounted) return;
    context.read<ConsultarProdutoBloc>().add(
      ConsultarProdutoReferenciaSelecionada(produto.idReferencia),
    );
    _solicitarFoco();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConsultarProdutoBloc>().state;
    final processando = state is ConsultarProdutoCarregarEmProgresso;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codigoController,
                  focusNode: _codigoFocusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Código de barras',
                    hintText: 'Bipe ou informe o código de barras',
                    suffixIcon: processando
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                onPressed: processando ? null : _submeterCodigo,
                icon: const Icon(Icons.qr_code),
                label: const Text('Ler'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(Icons.search_outlined, size: 18),
              label: const Text('Busca manual'),
              onPressed: processando ? null : _abrirBuscaManual,
            ),
          ),
          const SizedBox(height: 16),
          TabelasDePrecoSeletor(
            modo: TabelasDePrecoSeletorModo.unica,
            onChanged: (itens) {
              final tabelaDePrecoId = itens.isNotEmpty ? itens.first.id : null;
              setState(() => _tabelaDePrecoId = tabelaDePrecoId);
              context.read<ConsultarProdutoBloc>().add(
                ConsultarProdutoTabelaDePrecoAlterada(tabelaDePrecoId),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _ConteudoGrade(state: state),
        ],
      ),
    );
  }
}

class _BuscaManualDialog extends StatefulWidget {
  final ILeitorBuscaDataDatasource buscaDataSource;
  final int? tabelaDePrecoId;

  const _BuscaManualDialog({
    required this.buscaDataSource,
    this.tabelaDePrecoId,
  });

  @override
  State<_BuscaManualDialog> createState() => _BuscaManualDialogState();
}

class _BuscaManualDialogState extends State<_BuscaManualDialog> {
  late final LeitorBuscaBloc _buscaBloc;
  final _textoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buscaBloc = LeitorBuscaBloc(
      dataSource: widget.buscaDataSource,
      tabelaDePrecoId: widget.tabelaDePrecoId,
    );
  }

  @override
  void dispose() {
    _buscaBloc.close();
    _textoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _buscaBloc,
      child: BlocBuilder<LeitorBuscaBloc, LeitorBuscaState>(
        builder: (context, state) {
          final resultados = state.resultadosFiltrados;

          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
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
                            'Busca manual de produto',
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
                      autofocus: true,
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
                      onSubmitted: (v) =>
                          _buscaBloc.add(LeitorBuscaTextoBuscado(v)),
                      onChanged: (v) =>
                          _buscaBloc.add(LeitorBuscaTextoBuscado(v)),
                    ),
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
                    const SizedBox(height: 8),
                    Flexible(
                      child: _textoController.text.trim().isEmpty
                          ? Center(
                              child: Text(
                                'Digite para buscar produtos.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : resultados.isEmpty && !state.processando
                              ? Center(
                                  child: Text(
                                    'Nenhum produto encontrado.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: resultados.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final produto = resultados[index];
                                    final subtitulo = [
                                      if (produto.cor.trim().isNotEmpty)
                                        'Cor: ${produto.cor.trim()}',
                                      if (produto.tamanho.trim().isNotEmpty)
                                        'Tam: ${produto.tamanho.trim()}',
                                      'Cód: ${produto.codigoDeBarras}',
                                    ].join('  •  ');
                                    return ListTile(
                                      title: Text(produto.descricao),
                                      subtitle: Text(subtitulo),
                                      trailing: const Icon(
                                        Icons.chevron_right_outlined,
                                      ),
                                      onTap: () =>
                                          Navigator.of(context).pop(produto),
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

class _ConteudoGrade extends StatelessWidget {
  final ConsultarProdutoState state;

  const _ConteudoGrade({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is ConsultarProdutoInitial) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Bipe um código de barras ou use a busca manual para consultar um produto.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state is ConsultarProdutoCarregarEmProgresso) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final mensagemErro = state.mensagemErro;
    if (mensagemErro != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            mensagemErro,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final grade = state.grade;
    if (grade == null) return const SizedBox.shrink();

    return _GradeConteudo(grade: grade);
  }
}

class _GradeConteudo extends StatelessWidget {
  final GradeDaReferencia grade;

  const _GradeConteudo({required this.grade});

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagemUrl = grade.imagem?.url;

    final coresOrdenadas = grade.produtos
        .map((p) => p.corNome.trim().isEmpty ? '-' : p.corNome.trim())
        .toSet()
        .toList()
      ..sort();
    final tamanhosOrdenados = grade.produtos
        .map((p) => p.tamanhoNome.trim().isEmpty ? '-' : p.tamanhoNome.trim())
        .toSet()
        .toList()
      ..sort();

    final saldoPorCorETamanho = <String, Map<String, int>>{};
    for (final produto in grade.produtos) {
      final cor = produto.corNome.trim().isEmpty ? '-' : produto.corNome.trim();
      final tamanho = produto.tamanhoNome.trim().isEmpty
          ? '-'
          : produto.tamanhoNome.trim();
      final linha = saldoPorCorETamanho.putIfAbsent(cor, () => {});
      linha[tamanho] = (linha[tamanho] ?? 0) + produto.saldo;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 96,
                height: 96,
                child: imagemUrl != null
                    ? Image.network(
                        imagemUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImagem(theme),
                      )
                    : _placeholderImagem(theme),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(grade.nome, style: theme.textTheme.titleMedium),
                  if (grade.referenciaIdExterno != null)
                    Text(
                      'Referência: ${grade.referenciaIdExterno}',
                      style: theme.textTheme.bodySmall,
                    ),
                  if (grade.unidadeMedida != null)
                    Text(
                      'Unidade: ${grade.unidadeMedida}',
                      style: theme.textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    grade.valor != null
                        ? _formatarMoeda(grade.valor!)
                        : 'Preço não cadastrado',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total em estoque: ${grade.totalEmEstoque}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (grade.produtos.isEmpty)
          Text(
            'Nenhuma variação cadastrada para este produto.',
            style: theme.textTheme.bodyMedium,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(
                color: theme.colorScheme.outlineVariant,
                width: 0.8,
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Cor \\ Tam',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...tamanhosOrdenados.map(
                      (tamanho) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          tamanho,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                ...coresOrdenadas.map(
                  (cor) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(cor),
                      ),
                      ...tamanhosOrdenados.map(
                        (tamanho) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '${saldoPorCorETamanho[cor]?[tamanho] ?? 0}',
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
    );
  }

  Widget _placeholderImagem(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
