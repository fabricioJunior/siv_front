import 'package:comercial/models.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Trilha de etapas do pedido. Só leitura: etapa feita não reabre por clique.
/// Horizontal com rolagem (serve para desktop e mobile).
class TrilhaPedidoWidget extends StatelessWidget {
  final TrilhaPedido trilha;

  const TrilhaPedidoWidget({super.key, required this.trilha});

  @override
  Widget build(BuildContext context) {
    if (trilha.etapas.isEmpty) return const SizedBox.shrink();
    final cores = context.sivColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(bottom: BorderSide(color: cores.hairline)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            for (var i = 0; i < trilha.etapas.length; i++) ...[
              if (i > 0)
                Container(
                  width: 28,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: trilha.etapas[i - 1].estado == EstadoEtapa.feita
                      ? cores.aco
                      : cores.hairline,
                ),
              _Etapa(etapa: trilha.etapas[i], indice: i + 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _Etapa extends StatelessWidget {
  final EtapaPedido etapa;
  final int indice;

  const _Etapa({required this.etapa, required this.indice});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final atual = etapa.estado == EstadoEtapa.atual;
    final feita = etapa.estado == EstadoEtapa.feita;
    final futura = etapa.estado == EstadoEtapa.futura;

    return Opacity(
      opacity: futura ? 0.55 : 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: Key('trilha_etapa_${etapa.id.name}'),
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: atual ? cores.acoEscuro : (feita ? cores.aco : null),
              border: Border.all(color: atual || feita ? cores.aco : cores.hairline),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            child: feita
                ? Icon(Icons.check, size: 14, color: cores.textoSobreEscuroTitulo)
                : Text(
                    '$indice',
                    style: textos.rotulo.copyWith(
                      color: atual ? cores.textoSobreEscuroTitulo : null,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                etapa.titulo.toUpperCase(),
                style: textos.rotulo.copyWith(
                  fontWeight: atual ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              Text(etapa.subtitulo, style: textos.apoio.copyWith(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
