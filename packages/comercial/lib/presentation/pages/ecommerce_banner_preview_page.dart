import 'package:comercial/models.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Preview EXATO de como os banners aparecem no hero do site (use_por_onde_flor) --
/// mesmos aspect-ratio literais do CSS de produção (20/7 desktop, 3/2 mobile) e
/// BoxFit.cover, pra quem cadastra ver o corte antes de publicar.
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
      aspectRatio: 20 / 7,
      banners: ativosDesktop,
      indiceAtual: _indiceDesktop,
      onIndiceChanged: (i) => setState(() => _indiceDesktop = i),
      mensagemVazio: 'Nenhum banner desktop cadastrado.',
    );
    final blocoMobile = _BlocoPreviewHero(
      titulo: 'Preview Mobile',
      aspectRatio: 3 / 2,
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
  final List<EcommerceBanner> banners;
  final int indiceAtual;
  final ValueChanged<int> onIndiceChanged;
  final String mensagemVazio;

  const _BlocoPreviewHero({
    required this.titulo,
    required this.aspectRatio,
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
          ClipRRect(
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
