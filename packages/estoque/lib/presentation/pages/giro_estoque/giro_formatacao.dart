import 'package:estoque/domain/models/relatorio_giro_estoque.dart';

/// Formatação pt_BR sem depender de `intl` (não é dependência do pacote).
String fmtN(num v, [int casas = 0]) {
  final s = v.toStringAsFixed(casas);
  final partes = s.split('.');
  final negativo = partes[0].startsWith('-');
  final inteiro = partes[0].replaceFirst('-', '').replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]}.',
      );
  return '${negativo ? '-' : ''}$inteiro${casas > 0 ? ',${partes[1]}' : ''}';
}

/// 100% e 0% sem casas; demais com [casas].
String fmtPct(double? v, [int casas = 2]) {
  if (v == null) return '—';
  return '${v == 100 || v == 0 ? fmtN(v) : fmtN(v, casas)}%';
}

String fmtMoeda(double? v) => v == null ? '—' : 'R\$ ${fmtN(v, 2)}';

String fmtUnDia(double? v, [int casas = 2]) => v == null ? '—' : fmtN(v, casas);

String _dois(int n) => n.toString().padLeft(2, '0');

String fmtDia(DateTime? d) => d == null ? '—' : '${_dois(d.day)}/${_dois(d.month)}';

String fmtDiaAno(DateTime d) => '${fmtDia(d)}/${d.year}';

String diasT(int? n) => n == null ? '—' : (n == 1 ? '1 dia' : '$n dias');

String ordinalLote(int n) => '$nº lote';

/// "~1 dia", "~3 dias", "Esgotado" ou "Sem venda".
String previsaoT(GiroEstoqueLinha l) {
  if (l.semHistorico) return '—';
  final d = l.diasParaEsgotar;
  if (d == null) return 'Sem venda';
  if (d == 0) return 'Esgotado';
  return '~${diasT(d)}';
}

String subtituloLinha(GiroEstoqueLinha l) {
  if (l.semHistorico) return 'Sem histórico de entrada suficiente';
  return [
    if (l.variacaoLabel != null) l.variacaoLabel!,
    if (l.ref.isNotEmpty) 'REF ${l.ref}',
    if (l.variacaoLabel == null && l.categoria.isNotEmpty) l.categoria,
    if (l.variacaoLabel == null && l.fornecedor.isNotEmpty) l.fornecedor,
  ].join(' · ');
}

/// "Entradas de dd/MM/yyyy a dd/MM/yyyy" (ou "de hoje, dd/MM/yyyy").
String periodoTexto(FiltroGiroEstoque f) {
  final (ini, fim) = f.intervalo();
  if (f.periodo == PeriodoGiro.hoje) return 'Entradas de hoje, ${fmtDiaAno(fim)}';
  return 'Entradas de ${fmtDia(ini)} a ${fmtDiaAno(fim)}';
}

String nomeCompleto(GiroEstoqueLinha l) =>
    l.variacaoLabel == null ? l.nome : '${l.nome} · ${l.variacaoLabel}';

String nomeAba(AbaGiro a) => switch (a) {
      AbaGiro.ranking => 'Ranking de giro',
      AbaGiro.reposicao => 'Possível reposição',
      AbaGiro.parado => 'Estoque parado',
    };

String _loteT(GiroEstoqueLinha l) =>
    l.loteOrdem > 1 ? ordinalLote(l.loteOrdem) : '';

/// Colunas (cabeçalho, valor) do arquivo exportado para cada aba.
List<(String, String Function(GiroEstoqueLinha))> colunasExportacaoGiro(
  AbaGiro aba,
) =>
    switch (aba) {
      AbaGiro.ranking => [
          ('#', (l) => l.rank?.toString() ?? '—'),
          ('Produto', nomeCompleto),
          ('Ref.', (l) => l.ref),
          ('Categoria', (l) => l.categoria),
          ('Fornecedor', (l) => l.fornecedor),
          ('Entrada', (l) => '${fmtDia(l.dataEntrada)} ${_loteT(l)}'.trim()),
          ('Inicial', (l) => l.inicial?.toString() ?? '—'),
          ('Vendido', (l) => '${l.vendido}'),
          ('% vendido', (l) => fmtPct(l.pctVendido)),
          ('Estoque', (l) => '${l.estoque}'),
          ('Dias', (l) => l.diasGiro?.toString() ?? '—'),
          ('Un./dia', (l) => fmtUnDia(l.velocidade)),
          ('Previsão', previsaoT),
          ('Classificação', (l) => l.classificacao.label),
        ],
      AbaGiro.reposicao => [
          ('Produto', nomeCompleto),
          ('Ref.', (l) => l.ref),
          ('Estoque', (l) => '${l.estoque}'),
          ('Un./dia', (l) => fmtUnDia(l.velocidade)),
          ('Esgota em', previsaoT),
          ('Última entrada', (l) => fmtDia(l.dataEntrada)),
          ('Vendido', (l) => '${l.vendido}'),
          ('Giro', (l) => l.classificacao.label),
          ('Sugestão (un.)', (l) => l.sugestaoReposicao?.toString() ?? '—'),
        ],
      AbaGiro.parado => [
          ('Produto', nomeCompleto),
          ('Ref.', (l) => l.ref),
          ('Entrada', (l) => fmtDia(l.dataEntrada)),
          ('Dias em estoque', (l) => '${l.diasEmEstoque}'),
          ('Inicial', (l) => l.inicial?.toString() ?? '—'),
          ('Vendido', (l) => '${l.vendido}'),
          ('Estoque', (l) => '${l.estoque}'),
          ('% vendido', (l) => fmtPct(l.pctVendido)),
          ('Giro', (l) => l.classificacao.label),
          ('Valor parado', (l) => fmtMoeda(l.valorParado)),
        ],
    };

/// Linhas de cabeçalho dos arquivos: título, período, filtros e geração.
List<String> cabecalhoExportacaoGiro(AbaGiro aba, FiltroGiroEstoque f) {
  final agora = DateTime.now();
  final hora =
      '${_dois(agora.hour)}:${_dois(agora.minute)}';
  return [
    'Giro de Estoque — ${nomeAba(aba)}',
    periodoTexto(f),
    'Filtros: ${f.descricao.isEmpty ? 'nenhum' : f.descricao.join(' | ')}',
    'Gerado em: ${fmtDiaAno(agora)} $hora',
  ];
}
