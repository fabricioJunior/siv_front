import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ItemMaisAcao {
  /// Letra de atalho dentro do menu; null = sem atalho (Cancelar).
  final String? letra;
  final String rotulo;
  final IconData icone;
  final VoidCallback onTap;
  final bool alerta;

  const ItemMaisAcao({
    this.letra,
    required this.rotulo,
    required this.icone,
    required this.onTap,
    this.alerta = false,
  });
}

/// Menu "Mais ações" (F10): letra escolhe o item, Esc fecha. Itens sem letra
/// (Cancelar) ficam no fim, separados.
Future<void> abrirMaisAcoes(BuildContext context, List<ItemMaisAcao> itens) async {
  final escolhido = await showDialog<ItemMaisAcao>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (ctx) => _MenuMaisAcoes(itens: itens),
  );
  escolhido?.onTap();
}

class _MenuMaisAcoes extends StatelessWidget {
  final List<ItemMaisAcao> itens;

  const _MenuMaisAcoes({required this.itens});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final comLetra = itens.where((i) => i.letra != null).toList();
    final semLetra = itens.where((i) => i.letra == null).toList();

    Widget linha(ItemMaisAcao i) => InkWell(
          key: Key('mais_acao_${i.letra ?? 'cancelar'}'),
          onTap: () => Navigator.of(context).pop(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(i.icone, size: 18, color: i.alerta ? cores.vinho : null),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    i.rotulo,
                    style: textos.corpo.copyWith(color: i.alerta ? cores.vinho : null),
                  ),
                ),
                if (i.letra != null) Text(i.letra!, style: textos.rotulo),
              ],
            ),
          ),
        );

    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        final tecla = e.character?.toUpperCase();
        for (final i in comLetra) {
          if (i.letra == tecla) {
            Navigator.of(context).pop(i);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 88),
          child: Material(
            color: cores.superficie,
            elevation: 6,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: cores.hairline),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 340),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final i in comLetra) linha(i),
                  if (semLetra.isNotEmpty) Divider(height: 1, color: cores.hairline),
                  for (final i in semLetra) linha(i),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
