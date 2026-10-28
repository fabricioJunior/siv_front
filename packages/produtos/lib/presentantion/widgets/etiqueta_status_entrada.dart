import 'package:core/borda_tracejada.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';

const _azulNova = Color(0xFF5980A6);
const _fundoEspera = Color(0xFFEEF3F7);
const _bordaEspera = Color(0xFFC9D7E4);

/// Etiquetas de status de entrada da referência. O estado vai no texto, não só
/// na cor: "Nova" é tracejada; as de espera têm fundo e borda cheios.
class EtiquetaStatusEntrada extends StatelessWidget {
  final ReferenciaStatusEntrada? status;

  const EtiquetaStatusEntrada({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status;
    if (s == null || s.semStatus) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (s.nova) const _Etiqueta('Nova', tracejada: true),
        if (s.aguardandoPrimeiraEntrada)
          const _Etiqueta('Aguardando 1ª entrada'),
        if (s.aguardandoReposicao) const _Etiqueta('Aguardando reposição'),
      ],
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final bool tracejada;

  const _Etiqueta(this.texto, {this.tracejada = false});

  @override
  Widget build(BuildContext context) {
    final conteudo = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tracejada ? _azulNova : const Color(0xFF34495E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    if (tracejada) return BordaTracejada(cor: _azulNova, child: conteudo);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _fundoEspera,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _bordaEspera),
      ),
      child: conteudo,
    );
  }
}
