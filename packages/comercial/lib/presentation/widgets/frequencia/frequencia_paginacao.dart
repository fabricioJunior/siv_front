import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Páginas visíveis (null = reticências): 1, vizinhas da atual e a última.
List<int?> frequenciaPaginasVisiveis(int atual, int total) {
  final s = <int>{1, total, for (var p = atual - 1; p <= atual + 1; p++) p}
      .where((p) => p >= 1 && p <= total)
      .toList()
    ..sort();
  final r = <int?>[];
  for (var k = 0; k < s.length; k++) {
    if (k > 0 && s[k] - s[k - 1] > 1) r.add(null);
    r.add(s[k]);
  }
  return r;
}

/// Paginação numerada: anterior, 1, 2, 3, …, última, próxima.
class FrequenciaPaginacao extends StatelessWidget {
  final int pagina;
  final int totalPaginas;
  final ValueChanged<int> onPagina;
  const FrequenciaPaginacao({
    super.key,
    required this.pagina,
    required this.totalPaginas,
    required this.onPagina,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    Widget botao(Widget child, {int? destino, bool ativo = false}) {
      final habilitado = destino != null && !ativo;
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Material(
          color: ativo ? c.acoEscuro : c.superficie,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            side: BorderSide(color: ativo ? c.acoEscuro : c.hairline),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            onTap: habilitado ? () => onPagina(destino) : null,
            child: SizedBox(width: 32, height: 32, child: Center(child: child)),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        botao(
          Icon(
            Icons.chevron_left,
            size: 18,
            color: pagina > 1 ? c.tinta : c.textoApoio.withValues(alpha: 0.4),
          ),
          destino: pagina > 1 ? pagina - 1 : null,
        ),
        for (final p in frequenciaPaginasVisiveis(pagina, totalPaginas))
          p == null
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text('…', style: context.sivTextos.apoio),
                )
              : botao(
                  Text(
                    '$p',
                    style: context.sivTextos.apoio.copyWith(
                      color: p == pagina ? c.textoSobreEscuroTitulo : c.tinta,
                    ),
                  ),
                  destino: p,
                  ativo: p == pagina,
                ),
        botao(
          Icon(
            Icons.chevron_right,
            size: 18,
            color: pagina < totalPaginas ? c.tinta : c.textoApoio.withValues(alpha: 0.4),
          ),
          destino: pagina < totalPaginas ? pagina + 1 : null,
        ),
      ],
    );
  }
}
