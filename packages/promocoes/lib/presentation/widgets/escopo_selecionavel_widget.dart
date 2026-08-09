import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

// Reaproveitado no form de promocao e no form de cupom -- renderiza os
// campos de escopo condicionalmente conforme o tipoEscopo atual.
class EscopoSelecionavelWidget extends StatefulWidget {
  final TipoEscopo tipoEscopo;
  final List<int> referenciaIdsIniciais;
  final List<ItemComboKit> comboKitInicial;
  final int? quantidadeLevaInicial;
  final int? quantidadePagaInicial;
  final ValueChanged<List<int>> onReferenciaIdsChanged;
  final ValueChanged<List<ItemComboKit>> onComboKitChanged;
  final ValueChanged<int?> onQuantidadeLevaChanged;
  final ValueChanged<int?> onQuantidadePagaChanged;

  const EscopoSelecionavelWidget({
    super.key,
    required this.tipoEscopo,
    this.referenciaIdsIniciais = const [],
    this.comboKitInicial = const [],
    this.quantidadeLevaInicial,
    this.quantidadePagaInicial,
    required this.onReferenciaIdsChanged,
    required this.onComboKitChanged,
    required this.onQuantidadeLevaChanged,
    required this.onQuantidadePagaChanged,
  });

  @override
  State<EscopoSelecionavelWidget> createState() =>
      _EscopoSelecionavelWidgetState();
}

class _EscopoSelecionavelWidgetState extends State<EscopoSelecionavelWidget> {
  late List<_ComboKitLinha> _linhasComboKit;
  late List<int> _referenciaIds;
  int _referenciaSeletorVersao = 0;

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
    _referenciaIds = List.of(widget.referenciaIdsIniciais);
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
      case TipoEscopo.comboLevePague:
        return _buildLevePague(context);
      case TipoEscopo.comboKit:
        return _buildComboKit(context);
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
