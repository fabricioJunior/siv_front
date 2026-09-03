import 'package:flutter/material.dart';

import '../tema.dart';

/// Item do [SivMenuLateral]. A lógica de quais itens mostrar (permissão)
/// é responsabilidade de quem monta a lista -- este widget só renderiza.
class SivMenuLateralItem {
  final String label;
  final IconData icone;
  final bool selecionado;
  final VoidCallback? onTap;

  const SivMenuLateralItem({
    required this.label,
    required this.icone,
    this.selecionado = false,
    this.onTap,
  });
}

/// Grupo de itens do [SivMenuLateral], com título de seção opcional (ex:
/// "OPERAÇÃO", "SISTEMA").
class SivMenuLateralSecao {
  final String? titulo;
  final List<SivMenuLateralItem> itens;

  const SivMenuLateralSecao({this.titulo, required this.itens});
}

/// Menu lateral fixo de 236px de largura, fundo aço escuro. Quando
/// [colapsado], vira um rail de ícones (72px) com tooltip por item.
class SivMenuLateral extends StatelessWidget {
  final List<SivMenuLateralSecao> secoes;
  final Widget? cabecalho;
  final Widget? rodape;
  final bool colapsado;

  const SivMenuLateral({
    super.key,
    required this.secoes,
    this.cabecalho,
    this.rodape,
    this.colapsado = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      width: colapsado
          ? SivDimensoes.larguraMenuLateralRail
          : SivDimensoes.larguraMenuLateral,
      color: cores.acoEscuro,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cabecalho != null) cabecalho!,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                for (final secao in secoes) ...[
                  if (secao.titulo != null && !colapsado)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
                      child: Text(
                        secao.titulo!,
                        style: textos.apoio.copyWith(
                          color: cores.textoSobreEscuroTerciario,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  for (final item in secao.itens)
                    _SivMenuLateralItemWidget(
                      item: item,
                      colapsado: colapsado,
                    ),
                ],
              ],
            ),
          ),
          if (rodape != null) rodape!,
        ],
      ),
    );
  }
}

class _SivMenuLateralItemWidget extends StatelessWidget {
  final SivMenuLateralItem item;
  final bool colapsado;

  const _SivMenuLateralItemWidget({
    required this.item,
    required this.colapsado,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    final conteudo = Container(
      constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
      padding: EdgeInsets.symmetric(
        horizontal: colapsado ? 0 : SivDimensoes.itemMenuHorizontal,
        vertical: SivDimensoes.itemMenuVertical,
      ),
      child: Row(
        mainAxisAlignment: colapsado
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Icon(
            item.icone,
            size: 20,
            color: item.selecionado
                ? cores.textoSobreEscuroTitulo
                : cores.textoSobreEscuroApoio,
          ),
          if (!colapsado) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: textos.corpo.copyWith(
                  color: item.selecionado
                      ? cores.textoSobreEscuroTitulo
                      : cores.textoSobreEscuroApoio,
                  fontWeight: item.selecionado
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final itemWidget = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: colapsado ? 8 : 12,
        vertical: SivDimensoes.gapItemMenu / 2,
      ),
      child: Stack(
        children: [
          Material(
            color: item.selecionado ? cores.acoAtivo : Colors.transparent,
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              child: conteudo,
            ),
          ),
          if (item.selecionado)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: SivDimensoes.larguraBarraSelecionada,
                decoration: BoxDecoration(
                  color: cores.ceu,
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
              ),
            ),
        ],
      ),
    );

    return colapsado
        ? Tooltip(message: item.label, child: itemWidget)
        : itemWidget;
  }
}
