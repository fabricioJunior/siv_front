import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Miniatura de produto/lista. Sem [url], mostra um retângulo vazio.
class SivMiniatura extends StatelessWidget {
  final String? url;
  final double largura;
  final double altura;

  const SivMiniatura({
    super.key,
    this.url,
    required this.largura,
    required this.altura,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final vazia = Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: cores.superficieRecuada,
        border: Border.all(color: cores.hairline),
      ),
    );
    if (url == null || url!.isEmpty) return vazia;
    return Image.network(
      url!,
      width: largura,
      height: altura,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => vazia,
    );
  }
}
