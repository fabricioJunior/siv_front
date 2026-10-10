import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Aviso âmbar curto (duplicidade, sem grupo, sem estoque, agendada). Não
/// estica: ocupa só a largura do texto.
class SivAvisoAtencao extends StatelessWidget {
  final String texto;

  const SivAvisoAtencao(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        color: cores.atencaoFundo,
        child: Text(
          texto,
          style: context.sivTextos.apoio
              .copyWith(fontSize: 12, color: cores.atencao),
        ),
      ),
    );
  }
}
