import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

// Reaproveitado no form de promocao e no form de cupom -- renderiza os
// campos de escopo condicionalmente conforme o tipoEscopo atual.
class EscopoSelecionavelWidget extends StatefulWidget {
  final TipoEscopo tipoEscopo;
  final List<int> referenciaIdsIniciais;
  final List<PromocaoCategoria> categoriasIniciais;
  final List<int> excecaoReferenciaIdsIniciais;
  final List<ItemComboKit> comboKitInicial;
  final int? quantidadeLevaInicial;
  final int? quantidadePagaInicial;
  final List<PromocaoFaixa> faixasInicial;
  final ValueChanged<List<int>> onReferenciaIdsChanged;
  final ValueChanged<List<PromocaoCategoria>>? onCategoriasChanged;
  final ValueChanged<List<int>>? onExcecaoReferenciaIdsChanged;
  final ValueChanged<List<ItemComboKit>> onComboKitChanged;
  final ValueChanged<int?> onQuantidadeLevaChanged;
  final ValueChanged<int?> onQuantidadePagaChanged;
  final ValueChanged<List<PromocaoFaixa>> onFaixasChanged;

  const EscopoSelecionavelWidget({
    super.key,
    required this.tipoEscopo,
    this.referenciaIdsIniciais = const [],
    this.categoriasIniciais = const [],
    this.excecaoReferenciaIdsIniciais = const [],
    this.comboKitInicial = const [],
    this.quantidadeLevaInicial,
    this.quantidadePagaInicial,
    this.faixasInicial = const [],
    required this.onReferenciaIdsChanged,
    this.onCategoriasChanged,
    this.onExcecaoReferenciaIdsChanged,
    required this.onComboKitChanged,
    required this.onQuantidadeLevaChanged,
    required this.onQuantidadePagaChanged,
    required this.onFaixasChanged,
  });

  @override
  State<EscopoSelecionavelWidget> createState() =>
      _EscopoSelecionavelWidgetState();
}

class _EscopoSelecionavelWidgetState extends State<EscopoSelecionavelWidget> {
  late List<_ComboKitLinha> _linhasComboKit;
  late List<_FaixaLinha> _linhasFaixa;
  late List<int> _referenciaIds;
  int _referenciaSeletorVersao = 0;
  // Escopo por categoria: categorias escolhidas + subcategorias escolhidas
  // (agrupadas pela categoria delas) -- os pares PromocaoCategoria sao
  // derivados dos dois em _notificarCategorias.
  late Set<int> _categoriaIds;
  late Map<int, Set<int>> _subCategoriaIdsPorCategoria;
  late List<int> _excecaoReferenciaIds;

  @override
  void initState() {
    super.initState();
    _linhasComboKit = widget.comboKitInicial
        .map(
          (item) => _ComboKitLinha(
            referenciaId: item.referenciaId,
            quantidade: item.quantidadeExigida,
          ),
        )
        .toList();
    _linhasFaixa = widget.faixasInicial
        .map(
          (faixa) => _FaixaLinha(
            quantidadeMinima: faixa.quantidadeMinima,
            valorDesconto: faixa.valorDesconto,
          ),
        )
        .toList();
    _referenciaIds = List.of(widget.referenciaIdsIniciais);
    _categoriaIds = widget.categoriasIniciais
        .map((categoria) => categoria.categoriaId)
        .toSet();
    _subCategoriaIdsPorCategoria = {};
    for (final par in widget.categoriasIniciais) {
      if (par.subCategoriaId == null) continue;
      _subCategoriaIdsPorCategoria
          .putIfAbsent(par.categoriaId, () => <int>{})
          .add(par.subCategoriaId!);
    }
    _excecaoReferenciaIds = List.of(widget.excecaoReferenciaIdsIniciais);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.tipoEscopo) {
      case TipoEscopo.geral:
        return const SizedBox.shrink();
      case TipoEscopo.referencias:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _adicionarPorCategoria(context),
                icon: const Icon(Icons.category_outlined, size: 18),
                label: const Text('Adicionar por categoria'),
              ),
            ),
            ReferenciaSeletor(
              key: ValueKey('referencia-seletor-$_referenciaSeletorVersao'),
              modo: ReferenciaSeletorModo.multipla,
              idReferenciasSelecionadasIniciais: _referenciaIds,
              titulo: 'Referências elegíveis',
              onReferenciaChanged: (referencias) {
                _referenciaIds = referencias
                    .where((referencia) => referencia.id != null)
                    .map((referencia) => referencia.id!)
                    .toList();
                widget.onReferenciaIdsChanged(_referenciaIds);
              },
            ),
          ],
        );
      case TipoEscopo.categorias:
        return _buildCategorias(context);
      case TipoEscopo.comboLevePague:
        return _buildLevePague(context);
      case TipoEscopo.comboKit:
        return _buildComboKit(context);
      case TipoEscopo.faixaQuantidade:
        return _buildFaixaQuantidade(context);
    }
  }

  Future<void> _adicionarPorCategoria(BuildContext context) async {
    final novosIds = await showDialog<List<int>>(
      context: context,
      builder: (_) => const _DialogoAdicionarReferenciasPorCategoria(),
    );
    if (novosIds == null || novosIds.isEmpty) return;
    setState(() {
      _referenciaIds = {..._referenciaIds, ...novosIds}.toList();
      _referenciaSeletorVersao++;
    });
    widget.onReferenciaIdsChanged(_referenciaIds);
  }

  // Escopo "categoria mais excecoes": a promocao vale pras categorias/
  // subcategorias escolhidas, menos as referencias listadas em Excecoes.
  Widget _buildCategorias(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final categoriaIds = _categoriaIds.toList();
    final subIdsSelecionados = [
      for (final subs in _subCategoriaIdsPorCategoria.values) ...subs,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promoção vale para as categorias escolhidas',
          style: textos.apoio,
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        CategoriaSeletor(
          modo: CategoriaSeletorModo.multipla,
          titulo: 'Categorias',
          idCategoriasSelecionadasIniciais: categoriaIds,
          onCategoriaChanged: (categorias) {
            setState(() {
              _categoriaIds = categorias
                  .map((categoria) => categoria.id)
                  .whereType<int>()
                  .toSet();
            });
            _notificarCategorias();
          },
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        SubCategoriaSeletor(
          categoriaIds: categoriaIds,
          idsSelecionadosIniciais: subIdsSelecionados,
          titulo: 'Subcategorias (opcional)',
          onSubCategoriaChanged: (subs) {
            final agrupadas = <int, Set<int>>{};
            for (final sub in subs) {
              if (sub.id == null) continue;
              agrupadas
                  .putIfAbsent(sub.categoriaId, () => <int>{})
                  .add(sub.id!);
            }
            setState(() => _subCategoriaIdsPorCategoria = agrupadas);
            _notificarCategorias();
          },
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        Text('Exceções (ficam de fora)', style: textos.secao),
        const SizedBox(height: SivDimensoes.gapItemMenu),
        Text(
          'Referências que não entram na promoção mesmo estando nas '
          'categorias escolhidas.',
          style: textos.apoio,
        ),
        const SizedBox(height: SivDimensoes.gapItemMenu),
        ReferenciaSeletor(
          modo: ReferenciaSeletorModo.multipla,
          idReferenciasSelecionadasIniciais: _excecaoReferenciaIds,
          titulo: 'Referências excluídas',
          onReferenciaChanged: (referencias) {
            _excecaoReferenciaIds = referencias
                .map((referencia) => referencia.id)
                .whereType<int>()
                .toList();
            widget.onExcecaoReferenciaIdsChanged?.call(_excecaoReferenciaIds);
          },
        ),
        if (widget.referenciaIdsIniciais.isNotEmpty) ...[
          const SizedBox(height: SivDimensoes.gapCards),
          Container(
            constraints: const BoxConstraints(
              minHeight: SivDimensoes.alvoToqueMinimo,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.itemMenuHorizontal,
              vertical: SivDimensoes.itemMenuVertical,
            ),
            decoration: BoxDecoration(
              color: cores.selecaoFundo,
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              'Hoje a regra atinge '
              '${widget.referenciaIdsIniciais.length} referências.',
              style: textos.corpo,
            ),
          ),
        ],
      ],
    );
  }

  void _notificarCategorias() {
    final pares = <PromocaoCategoria>[];
    for (final categoriaId in _categoriaIds) {
      final subs = _subCategoriaIdsPorCategoria[categoriaId] ?? const <int>{};
      if (subs.isEmpty) {
        pares.add(PromocaoCategoria(categoriaId: categoriaId));
        continue;
      }
      pares.addAll(
        subs.map(
          (subId) => PromocaoCategoria(
            categoriaId: categoriaId,
            subCategoriaId: subId,
          ),
        ),
      );
    }
    widget.onCategoriasChanged?.call(pares);
  }

  Widget _buildLevePague(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReferenciaSeletor(
          modo: ReferenciaSeletorModo.multipla,
          idReferenciasSelecionadasIniciais: widget.referenciaIdsIniciais,
          titulo: 'Grupo elegível de referências',
          onReferenciaChanged: (referencias) => widget.onReferenciaIdsChanged(
            referencias
                .where((referencia) => referencia.id != null)
                .map((referencia) => referencia.id!)
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.quantidadeLevaInicial?.toString() ?? '',
                decoration: const InputDecoration(labelText: 'Leva (quantidade)'),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    widget.onQuantidadeLevaChanged(int.tryParse(value)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: widget.quantidadePagaInicial?.toString() ?? '',
                decoration: const InputDecoration(labelText: 'Paga (quantidade)'),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    widget.onQuantidadePagaChanged(int.tryParse(value)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComboKit(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Itens do combo', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (var i = 0; i < _linhasComboKit.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ReferenciaSeletor(
                    key: ValueKey('combo-kit-referencia-$i'),
                    modo: ReferenciaSeletorModo.unica,
                    idReferenciasSelecionadasIniciais:
                        _linhasComboKit[i].referenciaId == null
                            ? const []
                            : [_linhasComboKit[i].referenciaId!],
                    titulo: 'Referência',
                    onReferenciaChanged: (referencias) {
                      _linhasComboKit[i].referenciaId =
                          referencias.isNotEmpty ? referencias.first.id : null;
                      _notificarComboKit();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue:
                        _linhasComboKit[i].quantidade?.toString() ?? '1',
                    decoration: const InputDecoration(labelText: 'Qtd'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _linhasComboKit[i].quantidade = int.tryParse(value);
                      _notificarComboKit();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() => _linhasComboKit.removeAt(i));
                    _notificarComboKit();
                  },
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _linhasComboKit.add(_ComboKitLinha())),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar item'),
        ),
      ],
    );
  }

  Widget _buildFaixaQuantidade(BuildContext context) {
    final linhasOrdenadas = List<_FaixaLinha>.from(_linhasFaixa)
      ..sort(
        (a, b) => (a.quantidadeMinima ?? 0).compareTo(b.quantidadeMinima ?? 0),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReferenciaSeletor(
          modo: ReferenciaSeletorModo.multipla,
          idReferenciasSelecionadasIniciais: widget.referenciaIdsIniciais,
          titulo: 'Referências elegíveis (opcional -- vazio aplica no '
              'carrinho inteiro)',
          onReferenciaChanged: (referencias) => widget.onReferenciaIdsChanged(
            referencias
                .where((referencia) => referencia.id != null)
                .map((referencia) => referencia.id!)
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        Text('Faixas progressivas', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final linha in linhasOrdenadas)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: linha.quantidadeMinima?.toString() ?? '',
                    decoration:
                        const InputDecoration(labelText: 'Quantidade mínima'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      linha.quantidadeMinima = int.tryParse(value);
                      _notificarFaixas();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: linha.valorDesconto?.toString() ?? '',
                    decoration: const InputDecoration(labelText: 'Desconto'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      linha.valorDesconto = double.tryParse(value);
                      _notificarFaixas();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() => _linhasFaixa.remove(linha));
                    _notificarFaixas();
                  },
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _linhasFaixa.add(_FaixaLinha())),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar faixa'),
        ),
      ],
    );
  }

  void _notificarFaixas() {
    final faixas = _linhasFaixa
        .where(
          (linha) =>
              linha.quantidadeMinima != null &&
              linha.quantidadeMinima! > 0 &&
              linha.valorDesconto != null &&
              linha.valorDesconto! > 0,
        )
        .map(
          (linha) => PromocaoFaixa(
            quantidadeMinima: linha.quantidadeMinima!,
            valorDesconto: linha.valorDesconto!,
          ),
        )
        .toList();
    widget.onFaixasChanged(faixas);
  }

  void _notificarComboKit() {
    final itens = _linhasComboKit
        .where(
          (linha) =>
              linha.referenciaId != null &&
              linha.quantidade != null &&
              linha.quantidade! > 0,
        )
        .map(
          (linha) => ItemComboKit(
            referenciaId: linha.referenciaId!,
            quantidadeExigida: linha.quantidade!,
          ),
        )
        .toList();
    widget.onComboKitChanged(itens);
  }
}

// Estado efemero de UI enquanto o combo e montado -- so vira ItemComboKit
// (imutavel) quando referencia e quantidade estao preenchidas.
class _ComboKitLinha {
  int? referenciaId;
  int? quantidade;

  _ComboKitLinha({this.referenciaId, this.quantidade = 1});
}

// Estado efemero de UI enquanto a faixa e montada -- so vira PromocaoFaixa
// (imutavel) quando quantidadeMinima e valorDesconto estao preenchidos.
class _FaixaLinha {
  int? quantidadeMinima;
  double? valorDesconto;

  _FaixaLinha({this.quantidadeMinima, this.valorDesconto});
}

// Dialogo de selecao em massa: escolhe categorias, mostra previa com
// contagem de referencias ativas e retorna os IDs pra mesclar no escopo.
// E' um snapshot -- referencias cadastradas depois na categoria nao entram
// automaticamente.
class _DialogoAdicionarReferenciasPorCategoria extends StatefulWidget {
  const _DialogoAdicionarReferenciasPorCategoria();

  @override
  State<_DialogoAdicionarReferenciasPorCategoria> createState() =>
      _DialogoAdicionarReferenciasPorCategoriaState();
}

class _DialogoAdicionarReferenciasPorCategoriaState
    extends State<_DialogoAdicionarReferenciasPorCategoria> {
  late final ReferenciasBloc _referenciasBloc;
  List<Categoria> _categoriasSelecionadas = const [];

  @override
  void initState() {
    super.initState();
    _referenciasBloc = sl<ReferenciasBloc>()
      ..add(ReferenciasIniciou(inativo: false));
  }

  @override
  void dispose() {
    _referenciasBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriaIds = _categoriasSelecionadas
        .map((categoria) => categoria.id)
        .whereType<int>()
        .toSet();

    return AlertDialog(
      title: const Text('Adicionar referências por categoria'),
      content: SizedBox(
        width: 480,
        child: BlocProvider<ReferenciasBloc>.value(
          value: _referenciasBloc,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoriaSeletor(
                modo: CategoriaSeletorModo.multipla,
                titulo: 'Categorias',
                onCategoriaChanged: (categorias) =>
                    setState(() => _categoriasSelecionadas = categorias),
              ),
              const SizedBox(height: 12),
              BlocBuilder<ReferenciasBloc, ReferenciasState>(
                builder: (context, state) {
                  if (categoriaIds.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  if (state is ReferenciasCarregarEmProgresso) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }
                  if (state is ReferenciasCarregarFalha) {
                    return Text(
                      'Não foi possível carregar as referências.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    );
                  }
                  final referencias = state.referencias
                      .where(
                        (referencia) =>
                            referencia.id != null &&
                            categoriaIds.contains(referencia.categoriaId),
                      )
                      .toList();
                  if (referencias.isEmpty) {
                    return Text(
                      'Nenhuma referência ativa encontrada nessa(s) '
                      'categoria(s).',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  final nomesCategorias = _categoriasSelecionadas
                      .map((categoria) => categoria.nome)
                      .join(', ');
                  return Text(
                    'Adicionar ${referencias.length} referências de '
                    '$nomesCategorias?',
                    style: theme.textTheme.bodyMedium,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final referencias = _referenciasBloc.state.referencias
                .where(
                  (referencia) =>
                      referencia.id != null &&
                      categoriaIds.contains(referencia.categoriaId),
                )
                .map((referencia) => referencia.id!)
                .toList();
            if (referencias.isEmpty) return;
            Navigator.of(context).pop(referencias);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
