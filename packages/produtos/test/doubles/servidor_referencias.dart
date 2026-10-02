import 'package:produtos/data/remote/dtos/categoria_dto.dart';
import 'package:produtos/domain/data/repositorios/i_referencias_busca_repository.dart';
import 'package:produtos/models.dart';

Referencia fakeReferencia(
  int id,
  String nome, {
  required int categoriaId,
  required String categoria,
  String? ncm = '61091000',
  int? peso = 250,
  int? marcaId,
}) => Referencia.create(
  id: id,
  nome: nome,
  idExterno: '${1000 + id}',
  categoriaId: categoriaId,
  categoria: CategoriaDto(id: categoriaId, nome: categoria, inativa: false),
  marcaId: marcaId,
  ncm: ncm,
  pesoGramas: peso,
  atualizadoEm: DateTime(2026, 9, 30, 14, 5),
);

typedef ChamadaBusca = ({
  String? busca,
  int? categoriaId,
  bool semNcm,
  bool semPeso,
  String orderBy,
  String orderDir,
  int page,
});

/// Servidor falso: aplica busca, categoria, pendências, ordenação e paginação como o `GET /referencias/busca` e
/// registra cada chamada para o teste conferir o que o app pediu.
class ServidorReferenciasFake implements IReferenciasBuscaRepository {
  final List<ItemListaReferencia> todos;
  final int tamanhoPagina;
  final chamadas = <ChamadaBusca>[];
  Object? falha;

  ServidorReferenciasFake(this.todos, {this.tamanhoPagina = 50});

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp('[áàâã]'), 'a').replaceAll('ç', 'c');

  static bool _semNcm(Referencia r) =>
      !RegExp(r'^\d{8}$').hasMatch(r.ncm ?? '');

  static bool _semPeso(Referencia r) => (r.pesoGramas ?? 0) <= 0;

  bool _busca(Referencia r, String? busca) {
    final termo = _norm((busca ?? '').trim());
    if (termo.isEmpty) return true;
    return _norm(r.nome).contains(termo) ||
        (r.idExterno ?? '').toLowerCase().contains(termo) ||
        '${r.id}' == termo;
  }

  @override
  Future<ReferenciasBuscaResultado> buscar({
    String? busca,
    int? categoriaId,
    bool semNcm = false,
    bool semPeso = false,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) async {
    chamadas.add((
      busca: busca,
      categoriaId: categoriaId,
      semNcm: semNcm,
      semPeso: semPeso,
      orderBy: orderBy,
      orderDir: orderDir,
      page: page,
    ));
    if (falha != null) throw falha!;

    final porBusca = todos.where((i) => _busca(i.referencia, busca)).toList();
    final porCategoria = porBusca
        .where(
          (i) => categoriaId == null || i.referencia.categoriaId == categoriaId,
        )
        .toList();
    bool pend(ItemListaReferencia i) =>
        (!semNcm || _semNcm(i.referencia)) &&
        (!semPeso || _semPeso(i.referencia));

    final filtrados = porCategoria.where(pend).toList()
      ..sort((a, b) {
        final c = orderBy == 'nome'
            ? a.referencia.nome.compareTo(b.referencia.nome)
            : a.referencia.id!.compareTo(b.referencia.id!);
        return orderDir == 'DESC' ? -c : c;
      });

    final categorias = <int, String>{
      for (final i in todos)
        i.referencia.categoriaId!: i.referencia.categoria!.nome,
    };
    final inicio = (page - 1) * tamanhoPagina;
    return ReferenciasBuscaResultado(
      items: filtrados.skip(inicio).take(tamanhoPagina).toList(),
      totalItems: filtrados.length,
      totalPages: (filtrados.length / tamanhoPagina).ceil(),
      currentPage: page,
      resumo: ResumoReferencias(
        semNcm: porCategoria.where((i) => _semNcm(i.referencia)).length,
        semPeso: porCategoria.where((i) => _semPeso(i.referencia)).length,
        categorias: [
          for (final e
              in (categorias.entries.toList()
                ..sort((a, b) => a.value.compareTo(b.value))))
            CategoriaDoResumo(
              id: e.key,
              nome: e.value,
              total: porBusca
                  .where(pend)
                  .where((i) => i.referencia.categoriaId == e.key)
                  .length,
            ),
        ],
      ),
    );
  }
}
