import 'package:comercial/domain/models/trilha_entrada.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

Color _corSegmento(SivColors c, StatusPasso s) => switch (s) {
      StatusPasso.ativo => c.acoEscuro,
      StatusPasso.concluido => c.aco,
      StatusPasso.atencao => c.atencaoBorda,
      StatusPasso.futuro => c.hairline,
    };

/// Mobile: 5 segmentos de 4px; tocar abre a trilha completa.
class TrilhaSegmentos extends StatelessWidget {
  final List<PassoTrilha> passos;
  final ValueChanged<int> onSelecionar;

  const TrilhaSegmentos({
    super.key,
    required this.passos,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return InkWell(
      key: const Key('trilha_segmentos'),
      onTap: () => abrirTrilhaCompleta(context, passos, onSelecionar),
      child: Padding(
        // 44px de alvo de toque sem engordar o desenho (segmentos de 4px).
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            for (final p in passos)
              Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: _corSegmento(cores, p.status),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> abrirTrilhaCompleta(
  BuildContext context,
  List<PassoTrilha> passos,
  ValueChanged<int> onSelecionar,
) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in passos)
            ListTile(
              key: Key('trilha_passo_${p.indice}'),
              minVerticalPadding: 12,
              leading: _Marcador(passo: p),
              title: Text('${p.indice + 1}. ${p.titulo}'),
              subtitle: Text(p.subtitulo),
              onTap: () {
                Navigator.pop(ctx);
                onSelecionar(p.indice);
              },
            ),
        ],
      ),
    ),
  );
}

class _Marcador extends StatelessWidget {
  final PassoTrilha passo;
  const _Marcador({required this.passo});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final ativo = passo.status == StatusPasso.ativo;
    final concluido = passo.status == StatusPasso.concluido;
    final atencao = passo.status == StatusPasso.atencao;
    final borda = atencao ? cores.atencaoBorda : cores.aco;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ativo ? cores.acoEscuro : null,
        border: ativo ? null : Border.all(color: borda),
      ),
      child: concluido
          ? Icon(Icons.check, size: 16, color: cores.aco)
          : Text(
              '${passo.indice + 1}',
              style: textos.rotulo.copyWith(
                letterSpacing: 0,
                color: ativo
                    ? cores.textoSobreEscuroTitulo
                    : atencao
                        ? cores.parcialTexto
                        : cores.textoApoio,
              ),
            ),
    );
  }
}

/// Desktop: os 5 passos lado a lado, com status e subtítulo curto.
class TrilhaPassos extends StatelessWidget {
  final List<PassoTrilha> passos;
  final ValueChanged<int> onSelecionar;

  const TrilhaPassos({
    super.key,
    required this.passos,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Row(
      children: [
        for (final p in passos)
          Expanded(
            child: Opacity(
              opacity: p.status == StatusPasso.futuro ? 0.55 : 1,
              child: InkWell(
                key: Key('trilha_passo_${p.indice}'),
                onTap: () => onSelecionar(p.indice),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: p.status == StatusPasso.ativo
                            ? cores.acoEscuro
                            : cores.hairline,
                        width: p.status == StatusPasso.ativo ? 3 : 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _Marcador(passo: p),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.titulo, style: textos.secao),
                            Text(
                              p.subtitulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textos.apoio.copyWith(
                                color: p.status == StatusPasso.atencao
                                    ? cores.parcialTexto
                                    : cores.textoApoio,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
