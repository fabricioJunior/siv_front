import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';

int _i(dynamic v) => (v as num?)?.toInt() ?? 0;
double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;
List<Map<String, dynamic>> _l(dynamic v) =>
    (v as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

FrequenciaClienteItem _item(Map<String, dynamic> j) => FrequenciaClienteItem(
      rank: _i(j['rank']),
      clienteId: _i(j['clienteId']),
      nome: j['nome'] as String? ?? '',
      telefone: j['telefone'] as String?,
      documento: j['documento'] as String?,
      classe: j['classe'] as String? ?? 'C',
      visitas: _i(j['visitas']),
      primeiraCompra: j['primeiraCompra'] as String?,
      ultimaCompra: j['ultimaCompra'] as String?,
      diasDesdeUltima: _i(j['diasDesdeUltima']),
      intervaloMedioDias: (j['intervaloMedioDias'] as num?)?.toDouble(),
      valor: _d(j['valor']),
      ticketMedio: _d(j['ticketMedio']),
      percentualAcumulado: _d(j['percentualAcumulado']),
      atrasado: j['atrasado'] as bool? ?? false,
      proximaCompraEsperada: j['proximaCompraEsperada'] as String?,
      categoriaPreferida: j['categoriaPreferida'] as String?,
      pagamentoPreferido: j['pagamentoPreferido'] as String?,
    );

FrequenciaClientesResumo _resumo(Map<String, dynamic> j) {
  final sc = j['vendasSemCliente'] as Map<String, dynamic>? ?? const {};
  final p = j['parametros'] as Map<String, dynamic>? ?? const {};
  return FrequenciaClientesResumo(
    clientes: _i(j['clientes']),
    valorTotal: _d(j['valorTotal']),
    visitasPorCliente: _d(j['visitasPorCliente']),
    intervaloMedioDias: _d(j['intervaloMedioDias']),
    ticketMedio: _d(j['ticketMedio']),
    atrasados: _i(j['atrasados']),
    percentualUmaVisita: _d(j['percentualUmaVisita']),
    vendasSemCliente: FrequenciaVendasSemCliente(
      valor: _d(sc['valor']),
      percentualFaturamento: _d(sc['percentualFaturamento']),
    ),
    classes: _l(j['classes'])
        .map((e) => FrequenciaClasseResumo(
              classe: e['classe'] as String? ?? '',
              clientes: _i(e['clientes']),
              percentualClientes: _d(e['percentualClientes']),
              valor: _d(e['valor']),
              percentualFaturamento: _d(e['percentualFaturamento']),
            ))
        .toList(),
    curva: _l(j['curva'])
        .map((e) => FrequenciaCurvaPonto(
              percentualClientes: _d(e['percentualClientes']),
              percentualFaturamento: _d(e['percentualFaturamento']),
            ))
        .toList(),
    distribuicaoVisitas: _l(j['distribuicaoVisitas'])
        .map((e) => FrequenciaFaixaVisitas(
              faixa: e['faixa'] as String? ?? '',
              a: _i(e['A']),
              b: _i(e['B']),
              c: _i(e['C']),
            ))
        .toList(),
    parametros: FrequenciaParametros(
      corteA: _d(p['corteA'] ?? 80),
      corteB: _d(p['corteB'] ?? 95),
      fatorAtraso: _d(p['fatorAtraso'] ?? 2),
      minimoVisitasAtraso: _i(p['minimoVisitasAtraso'] ?? 3),
    ),
  );
}

RelatorioFrequenciaClientes frequenciaClientesFromJson(Map<String, dynamic> j) {
  final m = j['meta'] as Map<String, dynamic>? ?? const {};
  return RelatorioFrequenciaClientes(
    resumo: _resumo(j['resumo'] as Map<String, dynamic>? ?? const {}),
    items: _l(j['items']).map(_item).toList(),
    meta: FrequenciaClientesMeta(
      totalItems: _i(m['totalItems']),
      itemCount: _i(m['itemCount']),
      itemsPerPage: m['itemsPerPage'] == null ? 20 : _i(m['itemsPerPage']),
      totalPages: m['totalPages'] == null ? 1 : _i(m['totalPages']),
      currentPage: m['currentPage'] == null ? 1 : _i(m['currentPage']),
    ),
  );
}
