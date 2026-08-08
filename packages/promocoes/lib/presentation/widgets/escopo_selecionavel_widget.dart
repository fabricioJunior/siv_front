import 'package:flutter/material.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.tipoEscopo) {
      case TipoEscopo.geral:
        return const SizedBox.shrink();
      case TipoEscopo.referencias:
        return ReferenciaSeletor(
          modo: ReferenciaSeletorModo.multipla,
          idReferenciasSelecionadasIniciais: widget.referenciaIdsIniciais,
          titulo: 'Referências elegíveis',
          onReferenciaChanged: (referencias) => widget.onReferenciaIdsChanged(
            referencias
                .where((referencia) => referencia.id != null)
                .map((referencia) => referencia.id!)
                .toList(),
          ),
        );
      case TipoEscopo.comboLevePague:
        return _buildLevePague(context);
      case TipoEscopo.comboKit:
        return _buildComboKit(context);
    }
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
