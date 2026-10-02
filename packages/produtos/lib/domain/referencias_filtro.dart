import 'package:produtos/models.dart';

/// Quantas referências do recorte atual (busca + categoria) têm cada pendência.
class ReferenciasPendencias {
  final int semNcm;
  final int semPeso;

  const ReferenciasPendencias({required this.semNcm, required this.semPeso});
}

/// Filtros da lista de Referências, aplicados em memória sobre a lista já carregada
/// (a busca por nº e as contagens dos chips não existem no servidor).
class ReferenciasFiltro {
  final String busca;
  final int? categoriaId;
  final bool semNcm;
  final bool semPeso;

  const ReferenciasFiltro({
    this.busca = '',
    this.categoriaId,
    this.semNcm = false,
    this.semPeso = false,
  });

  bool get ativo =>
      busca.trim().isNotEmpty || categoriaId != null || semNcm || semPeso;

  ReferenciasFiltro copyWith({
    String? busca,
    Object? categoriaId = _manter,
    bool? semNcm,
    bool? semPeso,
  }) {
    return ReferenciasFiltro(
      busca: busca ?? this.busca,
      categoriaId: identical(categoriaId, _manter)
          ? this.categoriaId
          : categoriaId as int?,
      semNcm: semNcm ?? this.semNcm,
      semPeso: semPeso ?? this.semPeso,
    );
  }

  static const _manter = Object();

  static bool semNcmDe(Referencia r) => (r.ncm ?? '').trim().isEmpty;

  static bool semPesoDe(Referencia r) => (r.pesoGramas ?? 0) <= 0;

  /// Categoria que a referência exibe (a do objeto, ou só o id se o objeto não veio).
  static int? categoriaDe(Referencia r) => r.categoria?.id ?? r.categoriaId;

  /// Número que o usuário enxerga: o ID externo (código do sistema de origem) ou, se
  /// não houver, o ID interno.
  static String numeroDe(Referencia r) {
    final externo = (r.idExterno ?? '').trim();
    return externo.isNotEmpty ? externo : '${r.id ?? ''}';
  }

  /// Minúsculas e sem acento, para "camisa" achar "Camisá" e "CAMISA".
  static String normalizar(String texto) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const para = 'aaaaaeeeeiiiiooooouuuucn';
    final buffer = StringBuffer();
    for (final c in texto.toLowerCase().split('')) {
      final i = de.indexOf(c);
      buffer.write(i >= 0 ? para[i] : c);
    }
    return buffer.toString();
  }

  bool _passaBusca(Referencia r) {
    final termo = normalizar(busca.trim());
    if (termo.isEmpty) return true;
    return normalizar(r.nome).contains(termo) ||
        normalizar(numeroDe(r)).contains(termo) ||
        '${r.id ?? ''}'.contains(termo);
  }

  bool _passaCategoria(Referencia r) =>
      categoriaId == null || categoriaDe(r) == categoriaId;

  /// Recorte por busca e categoria: é a base das contagens dos chips de pendência.
  List<Referencia> recorte(List<Referencia> todas) =>
      todas.where((r) => _passaBusca(r) && _passaCategoria(r)).toList();

  List<Referencia> aplicar(List<Referencia> todas) {
    return recorte(todas).where((r) {
      if (semNcm && !semNcmDe(r)) return false;
      if (semPeso && !semPesoDe(r)) return false;
      return true;
    }).toList();
  }

  ReferenciasPendencias contar(List<Referencia> todas) {
    final base = recorte(todas);
    return ReferenciasPendencias(
      semNcm: base.where(semNcmDe).length,
      semPeso: base.where(semPesoDe).length,
    );
  }

  bool _passaPendencias(Referencia r) =>
      (!semNcm || semNcmDe(r)) && (!semPeso || semPesoDe(r));

  /// Quantas referências cada categoria teria com a busca e as pendências atuais,
  /// ignorando a categoria escolhida (é o número que a folha de categorias mostra).
  Map<int, int> contarPorCategoria(List<Referencia> todas) {
    final contagem = <int, int>{};
    for (final r in todas) {
      final id = categoriaDe(r);
      if (id == null || !_passaBusca(r) || !_passaPendencias(r)) continue;
      contagem[id] = (contagem[id] ?? 0) + 1;
    }
    return contagem;
  }

  /// Categorias presentes na lista, em ordem alfabética.
  static List<({int id, String nome})> categoriasDe(List<Referencia> todas) {
    final porId = <int, String>{};
    for (final r in todas) {
      final id = categoriaDe(r);
      final nome = r.categoria?.nome;
      if (id != null && nome != null && nome.isNotEmpty) porId[id] = nome;
    }
    final lista = [for (final e in porId.entries) (id: e.key, nome: e.value)]
      ..sort((a, b) => normalizar(a.nome).compareTo(normalizar(b.nome)));
    return lista;
  }
}
