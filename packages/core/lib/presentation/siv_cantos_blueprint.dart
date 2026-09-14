import 'package:flutter/material.dart';

/// 4 cantos em L (estilo "blueprint") sobre os vértices de um [Stack] --
/// usar como últimos filhos de um `Stack` que envolve o conteúdo
/// destacado. Extraído do [core/leitor/leitor_widget.dart] pra reuso em
/// telas que precisam do mesmo destaque visual (ex: card de configuração).
List<Widget> sivCantosBlueprint(Color cor, {double tamanho = 8}) {
  Widget canto({required bool top, required bool left}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          border: Border(
            top: top ? BorderSide(color: cor) : BorderSide.none,
            bottom: !top ? BorderSide(color: cor) : BorderSide.none,
            left: left ? BorderSide(color: cor) : BorderSide.none,
            right: !left ? BorderSide(color: cor) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  return [
    canto(top: true, left: true),
    canto(top: true, left: false),
    canto(top: false, left: true),
    canto(top: false, left: false),
  ];
}
