import 'package:comercial/domain/data/repositories/i_relatorio_repository.dart';
import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';

/// Repository fake para desenvolver telas sem backend; só implementa [frequenciaClientes].
class FrequenciaClientesRepositoryFake implements IRelatorioRepository {
  static final List<FrequenciaClienteItem> _base = _gera();

  static List<FrequenciaClienteItem> _gera() {
    const nomes = ['MARCIA A. B.', 'JOANA P.', 'CARLA S.', 'ANA L.', 'BEATRIZ M.', 'LUCIA F.'];
    const cats = ['BLUSA', 'CALCA', 'VESTIDO', null];
    var acum = 0.0;
    return List.generate(48, (i) {
      final classe = i < 12 ? 'A' : (i < 28 ? 'B' : 'C');
      final visitas = classe == 'A' ? 13 - i % 6 : (classe == 'B' ? 3 + i % 3 : 1 + i % 2);
      final valor = 5300.0 - i * 100;
      final ticket = valor / visitas;
      acum += valor / 160000 * 100;
      final umaVisita = visitas == 1;
      return FrequenciaClienteItem(
        rank: i + 1,
        clienteId: 50 + i,
        nome: '${nomes[i % nomes.length]} ${i + 1}',
        telefone: '(86) 9****-${3000 + i}',
        documento: '***.316.${400 + i}-**',
        classe: classe,
        visitas: visitas,
        primeiraCompra: '2025-10-01',
        ultimaCompra: '2026-03-31',
        diasDesdeUltima: 20 + i * 4,
        intervaloMedioDias: umaVisita ? null : 15.1 + i,
        valor: valor,
        ticketMedio: double.parse(ticket.toStringAsFixed(2)),
        percentualAcumulado: double.parse(acum.toStringAsFixed(1)),
        atrasado: !umaVisita && i % 3 == 0,
        proximaCompraEsperada: umaVisita ? null : '2026-04-15',
        categoriaPreferida: cats[i % cats.length],
        pagamentoPreferido: i % 10 == 0 ? 'Pix' : null,
      );
    });
  }

  @override
  Future<RelatorioFrequenciaClientes> frequenciaClientes({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    List<int>? funcionarioIds,
    List<int>? categoriaIds,
    String? classe,
    bool atrasados = false,
    String? busca,
    String ordenarPor = 'rank',
    String ordem = 'asc',
    int page = 1,
    int limit = 20,
  }) async {
    final l = _base.where((e) =>
        (classe == null || e.classe == classe) &&
        (!atrasados || e.atrasado) &&
        (busca == null ||
            busca.isEmpty ||
            e.nome.toLowerCase().contains(busca.toLowerCase())));
    final lista = l.toList();
    Comparable<Object?> Function(FrequenciaClienteItem) k = switch (ordenarPor) {
      'nome' => (e) => e.nome,
      'classe' => (e) => e.classe,
      'visitas' => (e) => e.visitas,
      'ultimaCompra' => (e) => e.ultimaCompra ?? '',
      'intervalo' => (e) => e.intervaloMedioDias ?? double.infinity,
      'valor' => (e) => e.valor,
      'ticketMedio' => (e) => e.ticketMedio,
      'percentualAcumulado' => (e) => e.percentualAcumulado,
      _ => (e) => e.rank,
    };
    lista.sort((a, b) => k(a).compareTo(k(b)));
    if (ordem == 'desc') {
      lista.setRange(0, lista.length, lista.reversed.toList());
    }
    final total = lista.length;
    final pages = total == 0 ? 1 : (total / limit).ceil();
    final ini = ((page - 1) * limit).clamp(0, total);
    final pagina = lista.skip(ini).take(limit).toList();

    int n(String c) => _base.where((e) => e.classe == c).length;
    double v(String c) =>
        _base.where((e) => e.classe == c).fold(0.0, (s, e) => s + e.valor);
    final totalValor = v('A') + v('B') + v('C');
    final todos = _base.length;
    return RelatorioFrequenciaClientes(
      resumo: FrequenciaClientesResumo(
        clientes: todos,
        valorTotal: totalValor,
        visitasPorCliente: 4.2,
        intervaloMedioDias: 43.9,
        ticketMedio: 201.19,
        atrasados: _base.where((e) => e.atrasado).length,
        percentualUmaVisita: 25,
        vendasSemCliente: const FrequenciaVendasSemCliente(valor: 41493.88, percentualFaturamento: 12.3),
        classes: [
          for (final c in ['A', 'B', 'C'])
            FrequenciaClasseResumo(
              classe: c,
              clientes: n(c),
              percentualClientes: n(c) / todos * 100,
              valor: v(c),
              percentualFaturamento: v(c) / totalValor * 100,
            ),
        ],
        curva: [
          for (var i = 0; i <= 40; i++)
            FrequenciaCurvaPonto(
              percentualClientes: i * 2.5,
              percentualFaturamento: (100 * (1 - (1 - i / 40) * (1 - i / 40))),
            ),
        ],
        distribuicaoVisitas: const [
          FrequenciaFaixaVisitas(faixa: '1', a: 0, b: 0, c: 12),
          FrequenciaFaixaVisitas(faixa: '2-3', a: 0, b: 5, c: 4),
          FrequenciaFaixaVisitas(faixa: '4-6', a: 2, b: 11, c: 0),
          FrequenciaFaixaVisitas(faixa: '7-12', a: 6, b: 0, c: 0),
          FrequenciaFaixaVisitas(faixa: '13+', a: 4, b: 0, c: 0),
        ],
      ),
      items: pagina,
      meta: FrequenciaClientesMeta(
        totalItems: total,
        itemCount: pagina.length,
        itemsPerPage: limit,
        totalPages: pages,
        currentPage: page,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
