import 'package:flutter/material.dart';

import '../tema.dart';

/// Filho de um item-acordeão do [SivMenuLateral] (ver [SivMenuLateralItem.filhos]).
class SivMenuLateralFilho {
  final String label;
  final bool selecionado;
  final VoidCallback? onTap;

  /// Rótulo de agrupamento por tema, opcional -- filhos consecutivos com o
  /// mesmo grupo ganham um cabeçalho de seção acima do primeiro.
  final String? grupo;

  const SivMenuLateralFilho({
    required this.label,
    this.selecionado = false,
    this.onTap,
    this.grupo,
  });
}

/// Item do [SivMenuLateral]. A lógica de quais itens mostrar (permissão)
/// é responsabilidade de quem monta a lista -- este widget só renderiza.
class SivMenuLateralItem {
  final String label;
  final IconData icone;
  final bool selecionado;
  final VoidCallback? onTap;

  /// Item sem permissão numa prévia de acesso (ver tela de grupo de
  /// acesso) -- risca o texto e esmaece ícone/texto, sem afetar navegação
  /// real (essa flag não desabilita [onTap]).
  final bool desabilitado;

  /// Filhos de um item-acordeão -- quando não vazio, o item vira expansível
  /// (chevron, sem navegação própria via [onTap]).
  final List<SivMenuLateralFilho> filhos;
  final bool expandido;
  final VoidCallback? onToggleExpandir;

  const SivMenuLateralItem({
    required this.label,
    required this.icone,
    this.selecionado = false,
    this.onTap,
    this.desabilitado = false,
    this.filhos = const [],
    this.expandido = false,
    this.onToggleExpandir,
  });

  bool get eAcordeao => filhos.isNotEmpty;
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

  /// Botão de encolher/expandir o menu inteiro, mostrado no topo -- só
  /// aparece quando informado (controle manual, independente dos
  /// breakpoints automáticos de largura).
  final VoidCallback? onToggleColapso;

  const SivMenuLateral({
    super.key,
    required this.secoes,
    this.cabecalho,
    this.rodape,
    this.colapsado = false,
    this.onToggleColapso,
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
          if (onToggleColapso != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: colapsado ? 0 : 12,
                vertical: 8,
              ),
              child: Align(
                alignment: colapsado ? Alignment.center : Alignment.centerRight,
                child: Tooltip(
                  message: colapsado ? 'Expandir menu' : 'Encolher menu',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SivDimensoes.raio),
                    onTap: onToggleColapso,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        colapsado
                            ? Icons.chevron_right
                            : Icons.chevron_left,
                        size: 20,
                        color: cores.textoSobreEscuroApoio,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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

    final conteudo = Opacity(
      opacity: item.desabilitado ? 0.45 : 1,
      child: Container(
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
                    decoration:
                        item.desabilitado ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (item.eAcordeao)
                Icon(
                  item.expandido ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: cores.textoSobreEscuroApoio,
                ),
            ],
          ],
        ),
      ),
    );

    final onTap = item.eAcordeao ? item.onToggleExpandir : item.onTap;

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
              onTap: onTap,
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

    final itemComTooltip =
        colapsado ? Tooltip(message: item.label, child: itemWidget) : itemWidget;

    if (!item.eAcordeao || colapsado || !item.expandido) {
      return itemComTooltip;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        itemComTooltip,
        for (var i = 0; i < item.filhos.length; i++) ...[
          if (item.filhos[i].grupo != null &&
              (i == 0 || item.filhos[i].grupo != item.filhos[i - 1].grupo))
            _CabecalhoGrupoFilho(texto: item.filhos[i].grupo!),
          _SivMenuLateralFilhoWidget(filho: item.filhos[i]),
        ],
      ],
    );
  }
}

class _CabecalhoGrupoFilho extends StatelessWidget {
  final String texto;

  const _CabecalhoGrupoFilho({required this.texto});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 12, 3),
      child: Text(
        texto,
        style: context.sivTextos.rotulo.copyWith(
          color: cores.textoSobreEscuroTerciario,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SivMenuLateralFilhoWidget extends StatelessWidget {
  final SivMenuLateralFilho filho;

  const _SivMenuLateralFilhoWidget({required this.filho});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 12, SivDimensoes.gapItemMenu / 2),
      child: Material(
        color: filho.selecionado ? cores.acoAtivo : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: filho.onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              filho.label,
              style: textos.apoio.copyWith(
                color: filho.selecionado
                    ? cores.textoSobreEscuroTitulo
                    : cores.textoSobreEscuroApoio,
                fontWeight:
                    filho.selecionado ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
