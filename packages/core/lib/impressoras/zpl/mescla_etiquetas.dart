class MesclaEtiquetas {
  static final RegExp _removerInicio = RegExp(r'^\s*\^XA\s*', multiLine: false);
  static final RegExp _removerFim = RegExp(r'\s*\^XZ\s*$', multiLine: false);

  String call(List<String> etiquetas, int quantidadeDeVias) {
    if (etiquetas.isEmpty) {
      return '';
    }

    final vias = quantidadeDeVias <= 0 ? 1 : quantidadeDeVias;
    final buffer = StringBuffer();

    for (var i = 0; i < etiquetas.length; i += vias) {
      final bloco = etiquetas.skip(i).take(vias);
      final corpoMesclado = bloco
          .map(_normalizarCorpoZpl)
          .where((zpl) => zpl.isNotEmpty)
          .join('\n');

      if (corpoMesclado.isEmpty) {
        continue;
      }

      if (buffer.isNotEmpty) {
        buffer.writeln();
      }

      buffer
        ..writeln('^XA')
        ..writeln(corpoMesclado)
        ..writeln('^XZ');
    }

    return buffer.toString().trim();
  }

  String _normalizarCorpoZpl(String zpl) {
    var valor = zpl.trim();
    valor = valor.replaceFirst(_removerInicio, '');
    valor = valor.replaceFirst(_removerFim, '');
    return valor.trim();
  }
}