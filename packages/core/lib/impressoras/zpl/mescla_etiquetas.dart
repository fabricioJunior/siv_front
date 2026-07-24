import 'package:core/impressoras/impressao/item_de_impressao.dart';

class MesclaEtiquetas {
  static final RegExp _removerInicio = RegExp(r'^\s*\^XA\s*', multiLine: false);
  static final RegExp _removerFim = RegExp(r'\s*\^XZ\s*$', multiLine: false);

  /// Mescla itens em blocos de [quantidadeDeVias] colunas por etiqueta fisica
  /// (^XA...^XZ). Agrupa por posicao (`item.viaOrdem`), nunca pela ordem
  /// crua da lista -- se dois itens consecutivos tiverem o mesmo viaOrdem
  /// (ex: sobra de uma referencia emendando com o inicio de outra na pilha),
  /// o bloco atual e fechado e um novo bloco comeca, em vez de empilhar os
  /// dois no mesmo offset/coluna (o que sairia como duas etiquetas
  /// desenhadas uma em cima da outra na mesma posicao fisica).
  String call(List<ItemDeImpressao> itens, int quantidadeDeVias) {
    if (itens.isEmpty) {
      return '';
    }

    final vias = quantidadeDeVias <= 0 ? 1 : quantidadeDeVias;
    final buffer = StringBuffer();

    var blocoAtual = <int, String>{};

    void flush() {
      if (blocoAtual.isEmpty) return;

      final corpoMesclado = (List.generate(vias, (i) => blocoAtual[i])
            ..removeWhere((zpl) => zpl == null))
          .map((zpl) => _normalizarCorpoZpl(zpl!))
          .where((zpl) => zpl.isNotEmpty)
          .join('\n');

      blocoAtual = {};

      if (corpoMesclado.isEmpty) return;

      if (buffer.isNotEmpty) {
        buffer.writeln();
      }

      buffer
        ..writeln('^XA')
        ..writeln(corpoMesclado)
        ..writeln('^XZ');
    }

    for (final item in itens) {
      final coluna = item.viaOrdem % vias;
      if (blocoAtual.containsKey(coluna)) {
        flush();
      }
      blocoAtual[coluna] = item.zpl;
    }
    flush();

    return buffer.toString().trim();
  }

  String _normalizarCorpoZpl(String zpl) {
    var valor = zpl.trim();
    valor = valor.replaceFirst(_removerInicio, '');
    valor = valor.replaceFirst(_removerFim, '');
    return valor.trim();
  }
}
