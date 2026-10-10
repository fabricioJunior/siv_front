import 'package:comercial/models.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Preview de como os banners aparecem no hero do site (use_por_onde_flor), com
/// BoxFit.cover, pra quem cadastra ver o corte antes de publicar.
///
/// O hero virou foto em tela cheia: a forma não vem mais do arquivo, e sim do que
/// sobra da viewport abaixo do topo fixo. As proporções abaixo são a tela típica --
/// 1440x730 no desktop (~2:1) e 390x728 no iPhone (~9:16) -- e batem com o tamanho
/// de arquivo recomendado no formulário.
class EcommerceBannerPreviewPage extends StatefulWidget {
  final List<EcommerceBanner> banners;

  const EcommerceBannerPreviewPage({super.key, required this.banners});

  @override
  State<EcommerceBannerPreviewPage> createState() => _EcommerceBannerPreviewPageState();
}

class _EcommerceBannerPreviewPageState extends State<EcommerceBannerPreviewPage> {
  // Largura mínima pra caber os dois blocos lado a lado sem espremer o hero.
  static const double _breakpointLadoALado = 900;

  int _indiceDesktop = 0;
  int _indiceMobile = 0;

  List<EcommerceBanner> _ativos(EcommerceBannerDispositivo dispositivo) {
    final lista = widget.banners
        .where((b) => b.dispositivo == dispositivo && b.ativo)
        .toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final ativosDesktop = _ativos(EcommerceBannerDispositivo.desktop);
    final ativosMobile = _ativos(EcommerceBannerDispositivo.mobile);
    final isTelaPequena =
        MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

    final blocoDesktop = _BlocoPreviewHero(
      titulo: 'Preview Desktop',
      aspectRatio: 2 / 1,
      banners: ativosDesktop,
      indiceAtual: _indiceDesktop,
      onIndiceChanged: (i) => setState(() => _indiceDesktop = i),
      mensagemVazio: 'Nenhum banner desktop cadastrado.',
    );
    final blocoMobile = _BlocoPreviewHero(
      titulo: 'Preview Mobile',
      aspectRatio: 9 / 16,
      larguraMaxima: 300,
      banners: ativosMobile,
      indiceAtual: _indiceMobile,
      onIndiceChanged: (i) => setState(() => _indiceMobile = i),
      mensagemVazio: 'Nenhum banner mobile cadastrado — usará o desktop no site.',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Preview no site')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: SivDimensoes.paginaHorizontal,
          vertical: SivDimensoes.paginaVertical,
        ),
        child: isTelaPequena
            ? blocoMobile
            : LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < _breakpointLadoALado) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        blocoDesktop,
                        const SizedBox(height: SivDimensoes.gapCards),
                        blocoMobile,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: blocoDesktop),
                      const SizedBox(width: SivDimensoes.gapCards),
                      Expanded(child: blocoMobile),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _BlocoPreviewHero extends StatelessWidget {
  final String titulo;
  final double aspectRatio;

  /// `null` = usa a largura toda (desktop). O mobile limita, senão 9:16 vira uma torre.
  final double? larguraMaxima;
  final List<EcommerceBanner> banners;
  final int indiceAtual;
  final ValueChanged<int> onIndiceChanged;
  final String mensagemVazio;

  const _BlocoPreviewHero({
    required this.titulo,
    required this.aspectRatio,
    this.larguraMaxima,
    required this.banners,
    required this.indiceAtual,
    required this.onIndiceChanged,
    required this.mensagemVazio,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final indice = banners.isEmpty ? 0 : indiceAtual.clamp(0, banners.length - 1);
    final banner = banners.isEmpty ? null : banners[indice];

    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: textos.rotulo),
          const SizedBox(height: 8),
          // Em 9:16 o bloco ocuparia a coluna inteira em altura: limita à largura
          // de um celular, como no site.
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: larguraMaxima ?? double.infinity),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SivDimensoes.raio),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
              child: banner == null
                  ? Container(
                      color: cores.superficieRecuada,
                      alignment: Alignment.center,
                      child: Text(
                        mensagemVazio,
                        textAlign: TextAlign.center,
                        style: textos.apoio,
                      ),
                    )
                  : banner.type == EcommerceBannerTipo.video
                      ? Container(
                          color: cores.superficieRecuada,
                          alignment: Alignment.center,
                          child: Icon(Icons.videocam_outlined, color: cores.textoApoio, size: 40),
                        )
                      : Image.network(
                          banner.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: cores.superficieRecuada,
                            child: Icon(Icons.image_not_supported_outlined, color: cores.textoApoio),
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < banners.length; i++)
                  GestureDetector(
                    onTap: () => onIndiceChanged(i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == indice ? cores.aco : cores.hairline,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
