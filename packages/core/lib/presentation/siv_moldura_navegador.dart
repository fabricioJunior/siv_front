import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Moldura de navegador para prévias do site: barra de 36px com 3 pontos e a
/// URL, e o conteúdo abaixo.
class SivMolduraNavegador extends StatelessWidget {
  final String url;
  final Widget child;

  const SivMolduraNavegador({super.key, required this.url, required this.child});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cores.superficieRecuada,
              border: Border(bottom: BorderSide(color: cores.hairline)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cores.tinta.withValues(alpha: 0.2),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    url,
                    style: textos.codigo.copyWith(
                      fontSize: 11.5,
                      color: cores.tinta.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
