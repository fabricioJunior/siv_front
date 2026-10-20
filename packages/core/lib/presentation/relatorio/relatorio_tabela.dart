import 'package:flutter/material.dart';

import '../../tema.dart';
import '../siv_cantos_blueprint.dart';
import 'relatorio_kpi_card.dart';

class RelatorioColuna {
  final String id;
  final String titulo;
  final bool numerica;
  final bool ordenavel;
  final int flex;

  const RelatorioColuna({
    required this.id,
    required this.titulo,
    this.numerica = false,
    this.ordenavel = true,
    this.flex = 1,
  });
}

/// Tabela de relatório (desktop) / lista de cartões (mobile). A ordenação é
/// do servidor: o widget só mostra a seta em [ordenarPor] e dispara
/// [onOrdenar] com o id da coluna.
class RelatorioTabela<T> extends StatelessWidget {
  final List<RelatorioColuna> colunas;
  final List<T> itens;

  /// Uma célula por coluna, na ordem de [colunas].
  final List<Widget> Function(BuildContext context, T item) celulas;
  final Widget Function(BuildContext context, T item) itemMobile;
  final String? ordenarPor;
  final bool ascendente;
  final ValueChanged<String>? onOrdenar;
  final ValueChanged<T>? onTap;

  const RelatorioTabela({
    super.key,
    required this.colunas,
    required this.itens,
    required this.celulas,
    required this.itemMobile,
    this.ordenarPor,
    this.ascendente = true,
    this.onOrdenar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatorioMobile(context)) {
      return Column(
        children: [
          for (final i in itens)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: onTap == null ? null : () => onTap!(i),
                child: itemMobile(context, i),
              ),
            ),
        ],
      );
    }
    final cores = context.sivColors;
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
          _linha(
            colunas.map((c) => _cabecalho(context, c)).toList(),
            fundo: cores.superficieRecuada,
          ),
          for (final i in itens)
            Material(
              color: cores.superficie,
              child: InkWell(
                hoverColor: cores.selecaoFundo,
                onTap: onTap == null ? null : () => onTap!(i),
                child: _linha(celulas(context, i), borda: true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _linha(List<Widget> filhos, {Color? fundo, bool borda = false}) {
    return Builder(
      builder: (context) => Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(
          horizontal: SivDimensoes.linhaTabelaHorizontal,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: fundo,
          border: borda
              ? Border(top: BorderSide(color: context.sivColors.hairline))
              : null,
        ),
        child: Row(
          children: [
            for (var k = 0; k < colunas.length; k++) ...[
              if (k > 0) const SizedBox(width: SivDimensoes.gapColunaTabela),
              Expanded(
                flex: colunas[k].flex,
                child: Align(
                  alignment: colunas[k].numerica
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: filhos[k],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context, RelatorioColuna c) {
    final cores = context.sivColors;
    final ativa = c.id == ordenarPor;
    final texto = Text(
      c.titulo.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.sivTextos.apoio.copyWith(
        fontFamily: sivFonteCondensed,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: cores.acoAtivo,
      ),
    );
    if (!c.ordenavel || onOrdenar == null) return texto;
    return InkWell(
      onTap: () => onOrdenar!(c.id),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: texto),
          if (ativa)
            Icon(
              ascendente ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: cores.aco,
            ),
        ],
      ),
    );
  }
}

/// Cartão mobile padrão para [RelatorioTabela.itemMobile]: título em negrito,
/// [apoio] unido por `·`, [valor] (valor-chave) à direita. Alvo >= 56px.
class RelatorioItemMobile extends StatelessWidget {
  final String titulo;
  final List<String> apoio;
  final String? valor;

  const RelatorioItemMobile({
    super.key,
    required this.titulo,
    this.apoio = const [],
    this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border.all(color: cores.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textos.corpo.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    if (apoio.isNotEmpty)
                      Text(
                        apoio.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textos.apoio.copyWith(color: cores.textoApoio),
                      ),
                  ],
                ),
              ),
              if (valor != null) ...[
                const SizedBox(width: 12),
                Text(valor!, style: textos.secao),
              ],
            ],
          ),
        ),
        ...sivCantosBlueprint(cores.aco.withValues(alpha: 0.4)),
      ],
    );
  }
}
