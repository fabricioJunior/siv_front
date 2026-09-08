import 'package:flutter/material.dart';

import '../tema.dart';

/// Modal de tarefa (busca/lista/formulário): cabeçalho e rodapé fixos,
/// corpo rolável. Rodapé mostra o contador da seleção à esquerda e as
/// ações à direita. `ESC` fecha, exceto quando [fechavel] é `false`
/// (processo em andamento).
class SivModal extends StatelessWidget {
  final String titulo;
  final Widget corpo;
  final String? contadorSelecao;
  final List<Widget> acoes;
  final bool fechavel;

  const SivModal({
    super.key,
    required this.titulo,
    required this.corpo,
    this.contadorSelecao,
    this.acoes = const [],
    this.fechavel = true,
  });

  static Future<T?> mostrar<T>(
    BuildContext context, {
    required String titulo,
    required Widget corpo,
    String? contadorSelecao,
    List<Widget> acoes = const [],
    bool fechavel = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: fechavel,
      barrierColor: context.sivColors.acoEscuro.withValues(alpha: 0.35),
      builder: (_) => SivModal(
        titulo: titulo,
        corpo: corpo,
        contadorSelecao: contadorSelecao,
        acoes: acoes,
        fechavel: fechavel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SivDimensoes.paddingCard,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cores.hairline),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(titulo, style: textos.secao)),
                  if (fechavel)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SivDimensoes.paddingCard),
                child: corpo,
              ),
            ),
            if (contadorSelecao != null || acoes.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SivDimensoes.paddingCard,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: cores.hairline)),
                ),
                child: Row(
                  children: [
                    if (contadorSelecao != null)
                      Text(
                        contadorSelecao!,
                        style: textos.apoio.copyWith(
                          color: cores.textoApoio,
                        ),
                      ),
                    const Spacer(),
                    for (var i = 0; i < acoes.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      acoes[i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
