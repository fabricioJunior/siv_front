import 'package:flutter/material.dart';

import '../../tema.dart';

/// Esqueleto de carregamento: [kpis] cartões + tabela de linhas.
class RelatorioEsqueleto extends StatelessWidget {
  final int kpis;
  final int linhas;

  const RelatorioEsqueleto({super.key, this.kpis = 4, this.linhas = 6});

  @override
  Widget build(BuildContext context) {
    final cor = context.sivColors.hairline;
    Widget bloco(double h) => Container(
      height: h,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < kpis; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: bloco(72)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < linhas; i++) bloco(44),
      ],
    );
  }
}

/// Estrutura comum dos relatórios. Desktop: cabeçalho `Relatórios / Nome`
/// com [filtros] e [acoes] à direita; mobile: seta + nome e [filtros] em
/// linha de chips rolável. Estados: [carregando], [erro], [vazio].
class RelatorioScaffold extends StatelessWidget {
  final String titulo;
  final List<Widget> acoes;
  final List<Widget> filtros;
  final List<Widget> kpis;
  final Widget corpo;
  final bool carregando;
  final String? erro;
  final VoidCallback? onTentarDeNovo;
  final bool vazio;

  const RelatorioScaffold({
    super.key,
    required this.titulo,
    required this.corpo,
    this.acoes = const [],
    this.filtros = const [],
    this.kpis = const [],
    this.carregando = false,
    this.erro,
    this.onTentarDeNovo,
    this.vazio = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return LayoutBuilder(
      builder: (context, c) {
        final mobile = c.maxWidth < SivDimensoes.breakpointMenuDrawer;
        final pad = mobile ? 16.0 : SivDimensoes.paddingBarraTituloHorizontal;
        final nome = Text(
          titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textos.secao.copyWith(fontSize: 21),
        );
        final cabecalho = mobile
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(child: nome),
                  ...acoes,
                ],
              )
            : Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(
                      context,
                    ).pushReplacementNamed('/relatorios'),
                    child: Text(
                      'Relatórios /',
                      style: textos.secao.copyWith(
                        fontSize: 21,
                        color: cores.textoApoio,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: nome),
                  const Spacer(),
                  Wrap(spacing: 8, children: [...filtros, ...acoes]),
                ],
              );

        final Widget conteudo;
        if (carregando) {
          conteudo = RelatorioEsqueleto(kpis: kpis.isEmpty ? 0 : kpis.length);
        } else if (erro != null) {
          conteudo = _Mensagem(
            texto: erro!,
            acao: FilledButton(
              onPressed: onTentarDeNovo,
              child: const Text('Tentar de novo'),
            ),
          );
        } else if (vazio) {
          conteudo = const _Mensagem(
            texto: 'Nenhum resultado para o filtro selecionado.',
          );
        } else {
          conteudo = corpo;
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cabecalho,
              if (mobile && filtros.isNotEmpty)
                SizedBox(
                  height: SivDimensoes.alvoToqueMinimo + 8,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtros.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => filtros[i],
                  ),
                ),
              const SizedBox(height: 16),
              if (kpis.isNotEmpty && !carregando && erro == null) ...[
                if (mobile)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.1,
                    children: kpis,
                  )
                else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < kpis.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: kpis[i]),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              conteudo,
            ],
          ),
        );
      },
    );
  }
}

class _Mensagem extends StatelessWidget {
  final String texto;
  final Widget? acao;

  const _Mensagem({required this.texto, this.acao});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text(
            texto,
            textAlign: TextAlign.center,
            style: textos.corpo.copyWith(
              color: context.sivColors.textoApoio,
            ),
          ),
          if (acao != null) ...[const SizedBox(height: 16), acao!],
        ],
      ),
    );
  }
}
