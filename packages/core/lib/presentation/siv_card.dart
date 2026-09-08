import 'package:flutter/material.dart';

import '../tema.dart';

enum SivCardVariante { padrao, destaque }

/// Superfície branca padrão (raio 4, sombra suave, padding 20). Variante
/// [SivCardVariante.destaque] troca para o fundo aço escuro com texto
/// invertido.
class SivCard extends StatelessWidget {
  final Widget child;
  final SivCardVariante variante;
  final EdgeInsetsGeometry? padding;

  const SivCard({
    super.key,
    required this.child,
    this.variante = SivCardVariante.padrao,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final destaque = variante == SivCardVariante.destaque;

    return DefaultTextStyle.merge(
      style: TextStyle(
        color: destaque ? cores.textoSobreEscuroTitulo : cores.textoPrincipal,
      ),
      // Material(transparency) -- mesmo esquema do Card nativo do Flutter:
      // garante ancestral Material pra InkWell/Switch/TextField/InputChip
      // dentro do card, sem depender de o chamador prover um (rota via
      // MaterialPageRoute sem Scaffold, dialog, teste isolado etc.).
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: padding ?? const EdgeInsets.all(SivDimensoes.paddingCard),
          decoration: BoxDecoration(
            color: destaque ? cores.acoEscuro : cores.superficie,
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            boxShadow: destaque
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0D26282A),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}
