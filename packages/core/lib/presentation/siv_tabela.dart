import 'package:flutter/material.dart';

import '../tema.dart';

/// Coluna configurável de [SivTabela].
class SivTabelaColuna {
  final String titulo;
  final TextAlign alinhamento;
  final int flex;

  const SivTabelaColuna({
    required this.titulo,
    this.alinhamento = TextAlign.left,
    this.flex = 1,
  });

  /// Atalho para colunas numéricas -- alinhadas à direita.
  const SivTabelaColuna.numerica({required this.titulo, this.flex = 1})
    : alinhamento = TextAlign.right;
}

/// Tabela do design system: cabeçalho recuado, linhas alternadas, linha
/// selecionada com fundo `#F0F5FA` e barra de acento à esquerda, rodapé
/// com contagem.
class SivTabela extends StatelessWidget {
  final List<SivTabelaColuna> colunas;
  final int quantidadeLinhas;
  final List<Widget> Function(BuildContext context, int indice) linhaBuilder;
  final bool Function(int indice)? linhaSelecionada;
  final void Function(int indice)? onLinhaTap;
  final String? rodape;

  const SivTabela({
    super.key,
    required this.colunas,
    required this.quantidadeLinhas,
    required this.linhaBuilder,
    this.linhaSelecionada,
    this.onLinhaTap,
    this.rodape,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        border: Border.all(color: cores.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: cores.superficieRecuada,
            padding: const EdgeInsets.symmetric(
              horizontal: SivDimensoes.cabecalhoTabelaHorizontal,
              vertical: SivDimensoes.cabecalhoTabelaVertical,
            ),
            child: Row(
              children: [
                for (final coluna in colunas)
                  Expanded(
                    flex: coluna.flex,
                    child: Text(
                      coluna.titulo,
                      textAlign: coluna.alinhamento,
                      style: textos.rotulo,
                    ),
                  ),
              ],
            ),
          ),
          for (var indice = 0; indice < quantidadeLinhas; indice++)
            _SivTabelaLinha(
              corFundo: indice.isEven
                  ? cores.superficie
                  : cores.superficieRecuada,
              corSelecionada: cores.selecaoFundo,
              corBarra: cores.aco,
              selecionada: linhaSelecionada?.call(indice) ?? false,
              onTap: onLinhaTap == null ? null : () => onLinhaTap!(indice),
              child: Row(
                children: [
                  for (final entrada in colunas.asMap().entries)
                    Expanded(
                      flex: entrada.value.flex,
                      child: Align(
                        alignment: entrada.value.alinhamento == TextAlign.right
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: linhaBuilder(context, indice)[entrada.key],
                      ),
                    ),
                ],
              ),
            ),
          if (rodape != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: SivDimensoes.cabecalhoTabelaHorizontal,
                vertical: SivDimensoes.cabecalhoTabelaVertical,
              ),
              decoration: BoxDecoration(
                color: cores.superficieRecuada,
                border: Border(top: BorderSide(color: cores.hairline)),
              ),
              child: Text(rodape!, style: textos.apoio),
            ),
        ],
      ),
    );
  }
}

class _SivTabelaLinha extends StatelessWidget {
  final Color corFundo;
  final Color corSelecionada;
  final Color corBarra;
  final bool selecionada;
  final VoidCallback? onTap;
  final Widget child;

  const _SivTabelaLinha({
    required this.corFundo,
    required this.corSelecionada,
    required this.corBarra,
    required this.selecionada,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionada ? corSelecionada : corFundo,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: SivDimensoes.alvoToqueMinimo,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SivDimensoes.linhaTabelaHorizontal,
            vertical: SivDimensoes.linhaTabelaVertical,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selecionada ? corBarra : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
