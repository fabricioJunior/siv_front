import 'package:core/data_sourcers.dart';
import 'package:estoque/estoque.dart';

/// Lógica de filtro/ordenação/paginação de `obterSaldo` e
/// `buscarProdutosPorTexto`, independente da engine de persistência local
/// (Isar/Hive) -- opera só sobre `fetchAll`/`fetchWhere`, já definidos pela
/// `ILocalDataSource<Dto>` que a classe concreta implementa.
mixin ProdutoEstoqueQueryMixin<Dto extends ProdutoDoEstoque>
    on ILocalDataSource<Dto> {
  Future<SaldoDoEstoque> obterSaldo({
    required FiltroProdutoDoEstoque filtro,
  }) async {
    final produtos = await fetchAll();
    final termosBusca = <String>{
      ...filtro.produtoIdExternos,
      ...filtro.referenciaIdExternos,
    }.map(_normalizarTexto).where((termo) => termo.isNotEmpty).toSet();

    final filtrados = produtos.where((produto) {
      if (filtro.empresaIds.isNotEmpty &&
          !filtro.empresaIds.contains(produto.empresaId)) {
        return false;
      }
      if (filtro.referenciaIds.isNotEmpty &&
          !filtro.referenciaIds.contains(produto.referenciaId)) {
        return false;
      }
      if (filtro.produtoIds.isNotEmpty &&
          !filtro.produtoIds.contains(produto.produtoId.toInt())) {
        return false;
      }
      if (filtro.corIds.isNotEmpty && !filtro.corIds.contains(produto.corId)) {
        return false;
      }
      if (filtro.tamanhoIds.isNotEmpty &&
          !filtro.tamanhoIds.contains(produto.tamanhoId)) {
        return false;
      }
      if (filtro.disponibilidadeEstoque ==
              FiltroDisponibilidadeEstoque.comEstoque &&
          produto.saldo <= 0) {
        return false;
      }
      if (filtro.disponibilidadeEstoque ==
              FiltroDisponibilidadeEstoque.semEstoque &&
          produto.saldo > 0) {
        return false;
      }
      if (filtro.atualizadoEmInicio != null || filtro.atualizadoEmFim != null) {
        final atualizadoEm = produto.atualizadoEm;
        if (atualizadoEm == null ||
            !_estaNoIntervaloDeDatas(
              atualizadoEm,
              inicio: filtro.atualizadoEmInicio,
              fim: filtro.atualizadoEmFim,
            )) {
          return false;
        }
      }
      if (termosBusca.isEmpty) {
        return true;
      }

      final nome = _normalizarTexto(produto.nome);
      final produtoIdExterno = _normalizarTexto(produto.produtoIdExterno ?? '');
      final referenciaIdExterno = _normalizarTexto(
        produto.referenciaIdExterno ?? '',
      );

      return termosBusca.any(
        (termo) =>
            nome.contains(termo) ||
            produtoIdExterno.contains(termo) ||
            referenciaIdExterno.contains(termo),
      );
    }).toList();

    final filtradosDeduplicados = _deduplicarProdutos(filtrados)
      ..sort(_comparadorParaFiltro(filtro));

    final totalItems = filtradosDeduplicados.length;
    final totalPages = totalItems == 0
        ? 0
        : ((totalItems - 1) ~/ filtro.limit) + 1;
    final inicioCalculado = (filtro.page - 1) * filtro.limit;
    final inicio = inicioCalculado < 0
        ? 0
        : (inicioCalculado > totalItems ? totalItems : inicioCalculado);
    final fimCalculado = inicio + filtro.limit;
    final fim = fimCalculado > totalItems ? totalItems : fimCalculado;
    final itensPaginados = inicio < fim
        ? filtradosDeduplicados.sublist(inicio, fim)
        : const <ProdutoDoEstoque>[];

    return SaldoDoEstoque(
      meta: PaginacaoDoEstoque(
        totalItems: totalItems,
        itemCount: itensPaginados.length,
        itemsPerPage: filtro.limit,
        totalPages: totalPages,
        currentPage: filtro.page,
      ),
      items: itensPaginados,
    );
  }

  Future<List<ProdutoDoEstoque>> buscarProdutosPorTexto(
    String texto, {
    String? tamanho,
    String? cor,
  }) async {
    return (await fetchWhere((dto) {
      if (!dto.nome.toLowerCase().contains(texto.toLowerCase())) {
        return false;
      }
      if (tamanho != null && !dto.tamanhoNome.contains(tamanho)) {
        return false;
      }
      if (cor != null && !dto.corNome.contains(cor)) {
        return false;
      }
      return true;
    })).toList();
  }
}

bool _estaNoIntervaloDeDatas(
  DateTime data, {
  required DateTime? inicio,
  required DateTime? fim,
}) {
  final dataNormalizada = DateTime(data.year, data.month, data.day);
  final inicioNormalizado = inicio == null
      ? null
      : DateTime(inicio.year, inicio.month, inicio.day);
  final fimNormalizado =
      fim == null ? null : DateTime(fim.year, fim.month, fim.day);

  if (inicioNormalizado != null && dataNormalizada.isBefore(inicioNormalizado)) {
    return false;
  }
  if (fimNormalizado != null && dataNormalizada.isAfter(fimNormalizado)) {
    return false;
  }

  return true;
}

int Function(ProdutoDoEstoque, ProdutoDoEstoque) _comparadorParaFiltro(
  FiltroProdutoDoEstoque filtro,
) {
  if (filtro.ordenacoes.isEmpty) return _ordenarProdutoParaSaldo;

  final comparadores = filtro.ordenacoes
      .map(_comparadorParaItem)
      .toList(growable: false);

  return (a, b) {
    for (final comparador in comparadores) {
      final resultado = comparador(a, b);
      if (resultado != 0) return resultado;
    }
    return 0;
  };
}

int Function(ProdutoDoEstoque, ProdutoDoEstoque) _comparadorParaItem(
  OrdenacaoEstoqueItem item,
) {
  int Function(ProdutoDoEstoque, ProdutoDoEstoque) base;
  switch (item.campo) {
    case CampoOrdenacaoEstoque.nome:
      base = (a, b) => a.nome.compareTo(b.nome);
      break;
    case CampoOrdenacaoEstoque.saldo:
      base = (a, b) => a.saldo.compareTo(b.saldo);
      break;
    case CampoOrdenacaoEstoque.referenciaIdExterno:
      base = (a, b) =>
          (a.referenciaIdExterno ?? '').compareTo(b.referenciaIdExterno ?? '');
      break;
    case CampoOrdenacaoEstoque.atualizadoEm:
      base = (a, b) => (a.atualizadoEm ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(b.atualizadoEm ?? DateTime.fromMillisecondsSinceEpoch(0));
      break;
    case CampoOrdenacaoEstoque.corNome:
      base = (a, b) => a.corNome.compareTo(b.corNome);
      break;
    case CampoOrdenacaoEstoque.tamanhoNome:
      base = (a, b) => a.tamanhoNome.compareTo(b.tamanhoNome);
      break;
  }

  return item.direcao == DirecaoOrdenacaoEstoque.desc
      ? (a, b) => base(b, a)
      : base;
}

int _ordenarProdutoParaSaldo(ProdutoDoEstoque a, ProdutoDoEstoque b) {
  final aComEstoque = a.saldo > 0;
  final bComEstoque = b.saldo > 0;

  if (aComEstoque != bComEstoque) {
    return aComEstoque ? -1 : 1;
  }

  final ordemReferencia = a.referenciaId.compareTo(b.referenciaId);
  if (ordemReferencia != 0) {
    return ordemReferencia;
  }

  final ordemProduto = a.produtoId.compareTo(b.produtoId);
  if (ordemProduto != 0) {
    return ordemProduto;
  }

  final ordemCor = a.corId.compareTo(b.corId);
  if (ordemCor != 0) {
    return ordemCor;
  }

  return a.tamanhoId.compareTo(b.tamanhoId);
}

List<ProdutoDoEstoque> _deduplicarProdutos(List<ProdutoDoEstoque> produtos) {
  final unicosPorChave = <String, ProdutoDoEstoque>{};

  for (final produto in produtos) {
    final chave =
        '${produto.empresaId}:${produto.produtoId}:${produto.corId}:${produto.tamanhoId}';
    final existente = unicosPorChave[chave];
    if (existente == null) {
      unicosPorChave[chave] = produto;
      continue;
    }

    final atualizacaoExistente = existente.atualizadoEm;
    final atualizacaoNova = produto.atualizadoEm;
    final deveSubstituir = atualizacaoNova != null &&
        (atualizacaoExistente == null ||
            atualizacaoNova.isAfter(atualizacaoExistente));

    if (deveSubstituir) {
      unicosPorChave[chave] = produto;
    }
  }

  return unicosPorChave.values.toList(growable: false);
}

String _normalizarTexto(String valor) {
  var normalizado = valor.trim().toLowerCase();
  const substituicoesAcentos = {
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'õ': 'o',
    'ô': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };

  substituicoesAcentos.forEach((comAcento, semAcento) {
    normalizado = normalizado.replaceAll(comAcento, semAcento);
  });

  return normalizado;
}
