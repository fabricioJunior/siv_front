import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

/// Pedido de Entrada (NF-e / contagem): identificar os itens da nota, pré-cadastrar
/// o que não existe, contar fisicamente e comparar NF-e × contado. A entrada no
/// estoque continua sendo a do pedido (conferência por bip + faturar).
class PedidoEntradaPage extends StatefulWidget {
  final int pedidoId;
  final SeletorWidget categoriaSeletor;
  final SeletorWidget referenciaSeletor;
  final SeletorWidget corSeletor;
  final SeletorWidget tamanhoSeletor;

  const PedidoEntradaPage({
    super.key,
    required this.pedidoId,
    required this.categoriaSeletor,
    required this.referenciaSeletor,
    required this.corSeletor,
    required this.tamanhoSeletor,
  });

  @override
  State<PedidoEntradaPage> createState() => _PedidoEntradaPageState();
}

class _PedidoEntradaPageState extends State<PedidoEntradaPage> {
  late final PedidoEntradaBloc _bloc = sl<PedidoEntradaBloc>()
    ..add(PedidoEntradaCarregou(widget.pedidoId));

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PedidoEntradaBloc>.value(
      value: _bloc,
      child: BlocConsumer<PedidoEntradaBloc, PedidoEntradaState>(
        listenWhen: (a, b) =>
            a.erro != b.erro ||
            a.mensagem != b.mensagem ||
            a.referenciaCriadaId != b.referenciaCriadaId,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.erro != null) {
            messenger.showSnackBar(SnackBar(content: Text(state.erro!)));
          } else if (state.mensagem != null) {
            final referenciaId = state.referenciaCriadaId;
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.mensagem!),
                action: referenciaId == null
                    ? null
                    : SnackBarAction(
                        label: 'Abrir referência',
                        onPressed: () => Navigator.of(context).pushNamed(
                          '/referencia',
                          arguments: {'idReferencia': referenciaId},
                        ),
                      ),
              ),
            );
          }
        },
        builder: (context, state) {
          final resumo = state.resumo;
          return Scaffold(
            appBar: AppBar(
              title: Text('Entrada #${widget.pedidoId}'),
              actions: [
                IconButton(
                  tooltip: 'Atualizar',
                  onPressed: () =>
                      _bloc.add(PedidoEntradaCarregou(widget.pedidoId)),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: resumo == null
                ? Center(
                    child: state.carregando
                        ? const CircularProgressIndicator()
                        : const Text('Pedido de entrada não carregado.'),
                  )
                : _Conteudo(
                    resumo: resumo,
                    salvando: state.salvando,
                    seletores: widget,
                  ),
          );
        },
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final EntradaResumo resumo;
  final bool salvando;
  final PedidoEntradaPage seletores;

  const _Conteudo({
    required this.resumo,
    required this.salvando,
    required this.seletores,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      children: [
        if (salvando) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Cabecalho(resumo: resumo),
              const SizedBox(height: 12),
              if (resumo.pendencias.isNotEmpty) ...[
                _Pendencias(pendencias: resumo.pendencias),
                const SizedBox(height: 12),
              ],
              if (resumo.linhas.isEmpty)
                Text(
                  'Este pedido não tem itens de NF-e. Use a conferência do '
                  'pedido para bipar e dar entrada.',
                  style: tema.textTheme.bodyMedium,
                ),
              for (final linha in resumo.linhas)
                _CartaoLinha(
                  resumo: resumo,
                  linha: linha,
                  salvando: salvando,
                  seletores: seletores,
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    resumo.pendencias.isEmpty
                        ? 'Sem pendências: pode seguir para a conferência.'
                        : '${resumo.pendencias.length} pendência(s) antes da conferência.',
                    style: tema.textTheme.bodySmall,
                  ),
                ),
                FilledButton.icon(
                  key: const Key('pedido_entrada_conferir_button'),
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/pedido',
                    arguments: {'idPedido': resumo.pedidoId},
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Etiquetas e conferência'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _qtd(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';
String _moeda(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

class _Cabecalho extends StatelessWidget {
  final EntradaResumo resumo;
  const _Cabecalho({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final nfe = resumo.nfe;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nfe == null
                  ? 'Origem: ${resumo.origemEntrada ?? 'MANUAL'}'
                  : 'NF-e ${nfe.numero}/${nfe.serie} · ${nfe.emitenteNome}',
              style: tema.titleMedium,
            ),
            if (nfe != null) ...[
              const SizedBox(height: 4),
              Text(
                'Chave ${nfe.chaveAcesso}\nValor da nota ${_moeda(nfe.valorTotal)}',
                style: tema.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 24,
              children: [
                Text('NF-e: ${_qtd(resumo.totalNfe)} un.'),
                Text('Contado: ${_qtd(resumo.totalContado)} un.'),
                Text(
                  'Diferença: ${_qtd(resumo.totalContado - resumo.totalNfe)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pendencias extends StatelessWidget {
  final List<String> pendencias;
  const _Pendencias({required this.pendencias});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pendências antes de conferir',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            for (final p in pendencias) Text('• $p'),
          ],
        ),
      ),
    );
  }
}

class _CartaoLinha extends StatelessWidget {
  final EntradaResumo resumo;
  final EntradaLinha linha;
  final bool salvando;
  final PedidoEntradaPage seletores;

  const _CartaoLinha({
    required this.resumo,
    required this.linha,
    required this.salvando,
    required this.seletores,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final bloc = context.read<PedidoEntradaBloc>();
    final ignorada = linha.status == StatusLinhaEntrada.ignorada;
    final contada = linha.quantidadeContada;
    final dif = linha.diferenca;
    final corDif = dif == null || dif == 0
        ? null
        : (linha.divergenciaResolvida ? Colors.grey : Colors.red);

    return Card(
      key: Key('entrada_linha_${linha.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Opacity(
          opacity: ignorada ? 0.5 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${linha.sequencia}. ${linha.descricao}',
                      style: tema.titleSmall,
                    ),
                  ),
                  Chip(
                    label: Text(linha.status.rotulo),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              Text(
                [
                  if (linha.codigoFornecedor != null)
                    'Cód. fornecedor ${linha.codigoFornecedor}',
                  if (linha.ncm != null) 'NCM ${linha.ncm}',
                  if (linha.unidade != null) linha.unidade!,
                  'unit. ${_moeda(linha.valorUnitario)}',
                ].join(' · '),
                style: tema.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 24,
                children: [
                  Text('NF-e: ${_qtd(linha.quantidadeNfe)}'),
                  Text('Contado: ${contada == null ? '—' : _qtd(contada)}'),
                  Text(
                    'Diferença: ${dif == null ? '—' : (dif > 0 ? '+' : '') + _qtd(dif)}',
                    style: TextStyle(color: corDif),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (linha.status == StatusLinhaEntrada.naoCadastrado) ...[
                    OutlinedButton(
                      onPressed:
                          salvando ? null : () => _preCadastrar(context, bloc),
                      child: const Text('Pré-cadastrar'),
                    ),
                    OutlinedButton(
                      onPressed:
                          salvando ? null : () => _vincular(context, bloc),
                      child: const Text('Vincular a referência'),
                    ),
                  ],
                  if (linha.status == StatusLinhaEntrada.mapeado ||
                      linha.status == StatusLinhaEntrada.referenciaVinculada)
                    FilledButton.tonal(
                      key: Key('entrada_contar_${linha.id}'),
                      onPressed: salvando ? null : () => _contar(context, bloc),
                      child: const Text('Contar'),
                    ),
                  if (linha.status == StatusLinhaEntrada.referenciaVinculada &&
                      linha.referenciaId != null)
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        '/referencia',
                        arguments: {'idReferencia': linha.referenciaId},
                      ),
                      child: const Text('Abrir referência'),
                    ),
                  if (linha.divergente && !linha.divergenciaResolvida)
                    OutlinedButton(
                      onPressed:
                          salvando ? null : () => _resolver(context, bloc),
                      child: const Text('Resolver divergência'),
                    ),
                  if (contada == null)
                    TextButton(
                      onPressed: salvando
                          ? null
                          : () => bloc.add(
                                PedidoEntradaIgnorouLinha(
                                  linha.id,
                                  ignorar: !ignorada,
                                ),
                              ),
                      child: Text(ignorada ? 'Reativar' : 'Ignorar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _preCadastrar(
      BuildContext context, PedidoEntradaBloc bloc) async {
    final nome = TextEditingController(text: linha.descricao);
    int? categoriaId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Pré-cadastrar referência'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                seletores.categoriaSeletor(
                  SeletorData(
                    compacto: true,
                    onChanged: (itens) => setState(
                      () => categoriaId = itens.isEmpty ? null : itens.first.id,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'NCM, unidade e custo vêm da NF-e. Subcategoria, grade e '
                  'preço de venda se completam na referência.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed:
                  categoriaId == null ? null : () => Navigator.pop(ctx, true),
              child: const Text('Criar referência'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && categoriaId != null) {
      bloc.add(
        PedidoEntradaPreCadastrouLinha(
          linha.id,
          categoriaId: categoriaId!,
          nome: nome.text.trim().isEmpty ? null : nome.text.trim(),
        ),
      );
    }
    nome.dispose();
  }

  Future<void> _vincular(BuildContext context, PedidoEntradaBloc bloc) async {
    int? referenciaId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Vincular a uma referência'),
          content: SizedBox(
            width: 420,
            child: seletores.referenciaSeletor(
              SeletorData(
                compacto: true,
                onChanged: (itens) => setState(
                  () => referenciaId = itens.isEmpty ? null : itens.first.id,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed:
                  referenciaId == null ? null : () => Navigator.pop(ctx, true),
              child: const Text('Vincular'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && referenciaId != null) {
      bloc.add(PedidoEntradaVinculouLinha(linha.id, referenciaId!));
    }
  }

  Future<void> _resolver(BuildContext context, PedidoEntradaBloc bloc) async {
    final obs = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolver divergência'),
        content: TextField(
          controller: obs,
          maxLength: 255,
          decoration: const InputDecoration(
            labelText: 'Explicação (ex.: veio 1 a menos)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
    if (ok == true) {
      bloc.add(
        PedidoEntradaResolveuDivergencia(
          linha.id,
          observacao: obs.text.trim().isEmpty ? null : obs.text.trim(),
        ),
      );
    }
    obs.dispose();
  }

  Future<void> _contar(BuildContext context, PedidoEntradaBloc bloc) async {
    final itens = await showDialog<List<ItemContagem>>(
      context: context,
      builder: (_) => _ContagemDialog(
        linha: linha,
        existentes: resumo.contagensDaLinha(linha.id),
        corSeletor: seletores.corSeletor,
        tamanhoSeletor: seletores.tamanhoSeletor,
      ),
    );
    if (itens != null && itens.isNotEmpty) {
      bloc.add(PedidoEntradaRegistrouContagem(itens));
    }
  }
}

/// Contagem de uma linha. SKU já identificado: um número. Referência sem grade:
/// escolhe cores e tamanhos e digita o encontrado em cada cruzamento -- é a
/// contagem que cria cor + tamanho + SKU (nada é criado pela quantidade da nota).
class _ContagemDialog extends StatefulWidget {
  final EntradaLinha linha;
  final List<EntradaContagem> existentes;
  final SeletorWidget corSeletor;
  final SeletorWidget tamanhoSeletor;

  const _ContagemDialog({
    required this.linha,
    required this.existentes,
    required this.corSeletor,
    required this.tamanhoSeletor,
  });

  @override
  State<_ContagemDialog> createState() => _ContagemDialogState();
}

class _ContagemDialogState extends State<_ContagemDialog> {
  final _simples = TextEditingController();
  final _cores = <int, String>{};
  final _tamanhos = <int, String>{};
  final _celulas = <String, TextEditingController>{};

  bool get _skuUnico => widget.linha.status == StatusLinhaEntrada.mapeado;

  @override
  void initState() {
    super.initState();
    if (_skuUnico) {
      final atual = widget.existentes.firstOrNull;
      if (atual != null) _simples.text = _qtd(atual.quantidade);
    }
    for (final c in widget.existentes) {
      if (c.corId == null || c.tamanhoId == null) continue;
      _cores[c.corId!] = c.corNome ?? '${c.corId}';
      _tamanhos[c.tamanhoId!] = c.tamanhoNome ?? '${c.tamanhoId}';
      _celula(c.corId!, c.tamanhoId!).text = _qtd(c.quantidade);
    }
  }

  @override
  void dispose() {
    _simples.dispose();
    for (final c in _celulas.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _celula(int cor, int tamanho) =>
      _celulas.putIfAbsent('$cor|$tamanho', TextEditingController.new);

  double? _ler(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  List<ItemContagem> _montar() {
    if (_skuUnico) {
      final q = _ler(_simples);
      return q == null
          ? const []
          : [
              ItemContagem(
                linhaId: widget.linha.id,
                produtoId: widget.linha.produtoId,
                quantidade: q,
              ),
            ];
    }
    return [
      for (final cor in _cores.keys)
        for (final tam in _tamanhos.keys)
          if (_ler(_celula(cor, tam)) != null)
            ItemContagem(
              linhaId: widget.linha.id,
              referenciaId: widget.linha.referenciaId,
              corId: cor,
              tamanhoId: tam,
              quantidade: _ler(_celula(cor, tam))!,
            ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Contar: ${widget.linha.descricao}'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: _skuUnico ? _campoUnico() : _grade(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('contagem_salvar'),
          onPressed: () => Navigator.pop(context, _montar()),
          child: const Text('Salvar contagem'),
        ),
      ],
    );
  }

  Widget _campoUnico() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('NF-e: ${_qtd(widget.linha.quantidadeNfe)}'),
          TextField(
            key: const Key('contagem_quantidade'),
            controller: _simples,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration:
                const InputDecoration(labelText: 'Quantidade encontrada'),
          ),
        ],
      );

  Widget _grade() {
    final cores = _cores.entries.toList();
    final tamanhos = _tamanhos.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'NF-e: ${_qtd(widget.linha.quantidadeNfe)} — digite o que foi '
          'encontrado em cada cor e tamanho.',
        ),
        const SizedBox(height: 8),
        widget.corSeletor(
          SeletorData(
            compacto: true,
            onChanged: (itens) => setState(() {
              _cores
                ..clear()
                ..addEntries(itens.map((i) => MapEntry(i.id, i.nome)));
            }),
          ),
        ),
        const SizedBox(height: 8),
        widget.tamanhoSeletor(
          SeletorData(
            compacto: true,
            onChanged: (itens) => setState(() {
              _tamanhos
                ..clear()
                ..addEntries(itens.map((i) => MapEntry(i.id, i.nome)));
            }),
          ),
        ),
        const SizedBox(height: 12),
        if (cores.isNotEmpty && tamanhos.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(72),
              columnWidths: const {0: FixedColumnWidth(120)},
              children: [
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    for (final t in tamanhos)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          t.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                for (final c in cores)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(c.value),
                      ),
                      for (final t in tamanhos)
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: TextField(
                            key: Key('contagem_${c.key}_${t.key}'),
                            controller: _celula(c.key, t.key),
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(isDense: true),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
