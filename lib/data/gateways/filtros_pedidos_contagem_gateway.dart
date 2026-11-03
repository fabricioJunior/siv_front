import 'package:comercial/data.dart';
import 'package:core/injecoes.dart';
import 'package:produtos/use_cases.dart'
    show BuscarReferencias, RecuperarCategorias, RecuperarGradeDaReferencia;

/// Ponte comercial -> produtos para os filtros de item do relatório de
/// pedidos por contagem.
class FiltrosPedidosContagemGateway implements IFiltrosPedidosContagemGateway {
  @override
  Future<List<OpcaoFiltro>> categorias() async =>
      (await sl<RecuperarCategorias>().call(inativa: false))
          .where((c) => c.id != null)
          .map((c) => OpcaoFiltro(c.id!, c.nome))
          .toList();

  @override
  Future<List<OpcaoFiltro>> referencias({
    int? categoriaId,
    required String busca,
  }) async {
    final r = await sl<BuscarReferencias>().call(
      busca: busca.isEmpty ? null : busca,
      categoriaId: categoriaId,
    );
    return [
      for (final i in r.items)
        if (i.referencia.id != null)
          OpcaoFiltro(
            i.referencia.id!,
            (i.referencia.idExterno ?? '').isEmpty
                ? i.referencia.nome
                : '${i.referencia.idExterno} · ${i.referencia.nome}',
            categoriaId: i.referencia.categoriaId,
          ),
    ];
  }

  @override
  Future<List<OpcaoFiltro>> produtos(int referenciaId) async {
    final g = await sl<RecuperarGradeDaReferencia>().call(
      referenciaId: referenciaId,
    );
    return [
      for (final p in g.produtos)
        OpcaoFiltro(
          p.produtoId,
          [
            p.corNome,
            p.tamanhoNome,
            if ((p.estampaNome ?? '').isNotEmpty) p.estampaNome!,
          ].join(' · '),
        ),
    ];
  }
}
