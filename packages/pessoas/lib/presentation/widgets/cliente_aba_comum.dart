import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Etiqueta pequena das abas do cliente (Principal, Cancelado, Compra...).
class ClienteTag extends StatelessWidget {
  final String texto;
  final Color? cor;
  final Color? fundo;

  const ClienteTag(this.texto, {super.key, this.cor, this.fundo});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fundo,
        border: fundo == null ? Border.all(color: cores.hairline) : null,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Text(
        texto,
        style: context.sivTextos.apoio
            .copyWith(fontSize: 10.5, color: cor ?? cores.textoPrincipal),
      ),
    );
  }
}

/// Menu ⋯ das linhas/cards; `itens` = rótulo -> ação (null desabilita).
class ClienteMenuMais extends StatelessWidget {
  final Map<String, VoidCallback?> itens;

  const ClienteMenuMais(this.itens, {super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Ações',
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_horiz,
          size: 20, color: context.sivColors.textoApoio),
      onSelected: (k) => itens[k]?.call(),
      itemBuilder: (_) => [
        for (final e in itens.entries)
          PopupMenuItem(
            value: e.key,
            enabled: e.value != null,
            child: Text(e.key),
          ),
      ],
    );
  }
}

/// Confirmação em SivModal; botão de confirmar em vinho quando destrutiva.
Future<bool> confirmarCliente(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String confirmar,
}) async {
  final cores = context.sivColors;
  final ok = await SivModal.mostrar<bool>(
    context,
    titulo: titulo,
    larguraMaxima: 480,
    corpo: Text(texto, style: context.sivTextos.corpo),
    acoes: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Voltar'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cores.vinho,
          foregroundColor: cores.textoSobreEscuroTitulo,
        ),
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(confirmar),
      ),
    ],
  );
  return ok ?? false;
}
