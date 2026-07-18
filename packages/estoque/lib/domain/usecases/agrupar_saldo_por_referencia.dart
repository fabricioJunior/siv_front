import 'package:estoque/domain/models/filtro_produto_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque_por_referencia.dart';

typedef PaginaAgrupadaPorReferencia = ({
  List<ProdutoDoEstoquePorReferencia> items,
  int totalItems,
  int totalPages,
});

/// Agrega, em memória, itens de estoque (grão de SKU) por referência,
/// somando o saldo de todas as variações (cor+tamanho) de cada referência.
class AgruparSaldoPorReferencia {
  PaginaAgrupadaPorReferencia call({
    required List<ProdutoDoEstoque> itens,
    CampoOrdenacaoEstoque? ordenarPor,
    DirecaoOrdenacaoEstoque ordenarDirecao = DirecaoOrdenacaoEstoque.asc,
    required int page,
    required int limit,
  }) {
    final agregados = _agrupar(itens)
      ..sort(_comparador(ordenarPor, ordenarDirecao));

    final totalItems = agregados.length;
    final totalPages = totalItems == 0 ? 0 : ((totalItems - 1) ~/ limit) + 1;
    final inicioCalculado = (page - 1) * limit;
    final inicio = inicioCalculado < 0
        ? 0
        : (inicioCalculado > totalItems ? totalItems : inicioCalculado);
    final fimCalculado = inicio + limit;
    final fim = fimCalculado > totalItems ? totalItems : fimCalculado;

    return (
      items: inicio < fim
          ? agregados.sublist(inicio, fim)
          : const <ProdutoDoEstoquePorReferencia>[],
      totalItems: totalItems,
      totalPages: totalPages,
    );
  }

  List<ProdutoDoEstoquePorReferencia> _agrupar(List<ProdutoDoEstoque> itens) {
    final acumuladores = <int, _Acumulador>{};

    for (final item in itens) {
      final acumulador = acumuladores.putIfAbsent(
        item.referenciaId,
        () => _Acumulador(
          referenciaId: item.referenciaId,
          referenciaIdExterno: item.referenciaIdExterno,
          nome: item.nome,
        ),
      );
      acumulador.somar(item);
    }

    return acumuladores.values.map((a) => a.toModel()).toList();
  }

  int Function(ProdutoDoEstoquePorReferencia, ProdutoDoEstoquePorReferencia)
  _comparador(CampoOrdenacaoEstoque? campo, DirecaoOrdenacaoEstoque direcao) {
    int Function(ProdutoDoEstoquePorReferencia, ProdutoDoEstoquePorReferencia)
    base;
    switch (campo) {
      case CampoOrdenacaoEstoque.saldo:
        base = (a, b) => a.saldoTotal.compareTo(b.saldoTotal);
        break;
      case CampoOrdenacaoEstoque.referenciaIdExterno:
        base = (a, b) => (a.referenciaIdExterno ?? '').compareTo(
          b.referenciaIdExterno ?? '',
        );
        break;
      case CampoOrdenacaoEstoque.atualizadoEm:
        base = (a, b) =>
            (a.atualizadoEm ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(
                  b.atualizadoEm ?? DateTime.fromMillisecondsSinceEpoch(0),
                );
        break;
      case CampoOrdenacaoEstoque.nome:
      case null:
        base = (a, b) => a.nome.compareTo(b.nome);
        break;
    }

    return direcao == DirecaoOrdenacaoEstoque.desc
        ? (a, b) => base(b, a)
        : base;
  }
}

class _Acumulador {
  final int referenciaId;
  final String? referenciaIdExterno;
  final String nome;
  double saldoTotal = 0;
  int quantidadeVariacoes = 0;
  DateTime? atualizadoEm;

  _Acumulador({
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.nome,
  });

  void somar(ProdutoDoEstoque item) {
    saldoTotal += item.saldo;
    quantidadeVariacoes++;
    final atualizadoEmItem = item.atualizadoEm;
    if (atualizadoEmItem != null &&
        (atualizadoEm == null || atualizadoEmItem.isAfter(atualizadoEm!))) {
      atualizadoEm = atualizadoEmItem;
    }
  }

  ProdutoDoEstoquePorReferencia toModel() => ProdutoDoEstoquePorReferencia(
    referenciaId: referenciaId,
    referenciaIdExterno: referenciaIdExterno,
    nome: nome,
    saldoTotal: saldoTotal,
    quantidadeVariacoes: quantidadeVariacoes,
    atualizadoEm: atualizadoEm,
  );
}
