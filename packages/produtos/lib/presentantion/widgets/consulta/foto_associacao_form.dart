import 'package:flutter/material.dart';
import 'package:produtos/models.dart';

/// Cor, estampa e tamanho obrigatórios; opções só da grade da referência.
class FotoAssociacaoForm extends StatelessWidget {
  final OpcoesAssociacaoFoto opcoes;
  final AssociacaoFoto valor;
  final ValueChanged<AssociacaoFoto> onChanged;
  final bool mostrarErros;

  const FotoAssociacaoForm({
    super.key,
    required this.opcoes,
    required this.valor,
    required this.onChanged,
    this.mostrarErros = false,
  });

  Widget _campo({
    required String rotulo,
    required String? atual,
    required List<(String, String)> itens,
    required ValueChanged<String?>? onChanged,
  }) {
    final valido = itens.any((i) => i.$1 == atual) ? atual : null;
    return DropdownButtonFormField<String>(
      key: ValueKey('$rotulo-$valido-${itens.length}'),
      initialValue: valido,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: '$rotulo *',
        isDense: true,
        errorText: mostrarErros && valido == null ? 'Obrigatório' : null,
      ),
      items: [
        for (final i in itens) DropdownMenuItem(value: i.$1, child: Text(i.$2)),
      ],
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final estampas = opcoes.estampasDaCor(valor.cor);
    return Column(
      children: [
        _campo(
          rotulo: 'Cor',
          atual: valor.cor,
          itens: [for (final c in opcoes.cores) (c, c)],
          onChanged: (v) => onChanged(valor.comCor(v, opcoes)),
        ),
        const SizedBox(height: 8),
        _campo(
          rotulo: 'Estampa',
          atual: valor.estampa,
          itens: [for (final e in estampas) (e, e)],
          onChanged: valor.cor == null
              ? null
              : (v) => onChanged(valor.copyWith(estampa: v)),
        ),
        const SizedBox(height: 8),
        _campo(
          rotulo: 'Tamanho',
          atual: valor.tamanho,
          itens: [
            for (final t in opcoes.tamanhos) (t, t),
            (tamanhoTodos, 'Todos os tamanhos'),
          ],
          onChanged: (v) => onChanged(valor.copyWith(tamanho: v)),
        ),
      ],
    );
  }
}
