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

/// Menu lateral fixo de 236px de largura, fundo aço escuro.
class SivMenuLateral extends StatelessWidget {
  final List<SivMenuLateralItem> itens;
  final Widget? cabecalho;

  const SivMenuLateral({super.key, required this.itens, this.cabecalho});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      width: SivDimensoes.larguraMenuLateral,
      color: cores.acoEscuro,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cabecalho != null) cabecalho!,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                for (final item in itens)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: SivDimensoes.gapItemMenu / 2,
                    ),
                    child: Material(
                      color: item.selecionado
                          ? cores.acoAtivo
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(SivDimensoes.raio),
                      child: InkWell(
                        onTap: item.onTap,
                        borderRadius: BorderRadius.circular(
                          SivDimensoes.raio,
                        ),
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: SivDimensoes.alvoToqueMinimo,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: SivDimensoes.itemMenuHorizontal,
                            vertical: SivDimensoes.itemMenuVertical,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icone,
                                size: 20,
                                color: item.selecionado
                                    ? cores.textoSobreEscuroTitulo
                                    : cores.textoSobreEscuroApoio,
                              ),
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
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
