import 'package:comercial/domain/models/relatorio_movimentacoes.dart';

int? _in(dynamic v) => (v as num?)?.toInt();

MovimentacaoItem _item(Map<String, dynamic> j) => MovimentacaoItem(
      id: '${j['id']}',
      dataHora: DateTime.tryParse('${j['dataHora']}'),
      tipo: j['tipo'] as String? ?? '',
      produtoId: _in(j['produtoId']),
      produtoNome: j['produtoNome'] as String?,
      referenciaIdExterno: j['referenciaIdExterno'] as String?,
      descricao: j['descricao'] as String?,
      quantidade: _in(j['quantidade']) ?? 0,
      responsavelId: _in(j['responsavelId']),
      responsavelNome: j['responsavelNome'] as String?,
      documentoTipo: j['documentoTipo'] as String?,
      documentoId: _in(j['documentoId']),
    );

RelatorioMovimentacoes movimentacoesFromJson(Map<String, dynamic> j) {
  final m = j['meta'] as Map<String, dynamic>? ?? const {};
  final c = j['contagemPorTipo'] as Map<String, dynamic>? ?? const {};
  return RelatorioMovimentacoes(
    items: (j['items'] as List<dynamic>? ?? [])
        .map((e) => _item(e as Map<String, dynamic>))
        .toList(),
    meta: MovimentacoesMeta(
      totalItems: _in(m['totalItems']) ?? 0,
      itemCount: _in(m['itemCount']) ?? 0,
      itemsPerPage: _in(m['itemsPerPage']) ?? 50,
      totalPages: _in(m['totalPages']) ?? 1,
      currentPage: _in(m['currentPage']) ?? 1,
    ),
    contagemPorTipo: {for (final e in c.entries) e.key: _in(e.value) ?? 0},
  );
}
