import 'package:core/presentation/siv_cantos_blueprint.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Moldura "blueprint": borda reta de 1px com marcas de canto em L. Fundo
/// transparente por padrão; [fundo] só quando o conteúdo precisa de superfície.
/// Selecionado ganha borda `aco` e halo.
class SivMolduraBlueprint extends StatelessWidget {
  final Widget child;
  final bool selecionado;
  final double padding;
  final Color? fundo;

  const SivMolduraBlueprint({
    super.key,
    required this.child,
    this.selecionado = false,
    this.padding = 13,
    this.fundo,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: fundo,
            border: Border.all(
              color: selecionado ? cores.aco : cores.hairline,
            ),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            boxShadow: selecionado
                ? [
                    BoxShadow(
                      color: cores.aco.withValues(alpha: 0.12),
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
        ...sivCantosBlueprint(cores.aco.withValues(alpha: 0.4)),
      ],
    );
  }
}
