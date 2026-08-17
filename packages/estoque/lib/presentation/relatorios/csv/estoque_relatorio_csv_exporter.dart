import 'dart:convert';
import 'dart:typed_data';

import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';
import 'package:estoque/domain/models/produto_do_estoque.dart';
import 'package:estoque/domain/models/produto_do_estoque_por_referencia.dart';

String _fmtData(DateTime? data) {
  if (data == null) return '-';
  final d = data.day.toString().padLeft(2, '0');
  final m = data.month.toString().padLeft(2, '0');
  return '$d/$m/${data.year}';
}

String _campo(String valor) {
  final precisaAspas =
      valor.contains(',') || valor.contains('"') || valor.contains('\n');
  if (!precisaAspas) return valor;
  return '"${valor.replaceAll('"', '""')}"';
}

String _linha(List<String> campos) => campos.map(_campo).join(',');

/// Gera CSV com BOM UTF-8 (necessário pro Excel reconhecer acentuação) e
/// abre o diálogo "Salvar como" via [ArquivoService].
Future<String?> _salvarCsv(List<String> linhas, String nomeArquivo) async {
  final conteudo = linhas.join('\r\n');
  final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(conteudo)]);
  return sl<ArquivoService>().salvarBytes(
    bytes: bytes,
    nomeSugerido: nomeArquivo,
  );
}

class EstoqueRelatorioCsvExporter {
  EstoqueRelatorioCsvExporter._();

  static Future<String?> exportarPorProduto(List<ProdutoDoEstoque> itens) {
    final linhas = [
      _linha([
        'Referência',
        'Produto',
        'Nome',
        'Cor',
        'Tamanho',
        'UM',
        'Saldo',
        'Atualizado em',
      ]),
      for (final item in itens)
        _linha([
          item.referenciaIdExterno ?? '${item.referenciaId}',
          item.produtoIdExterno ?? '${item.produtoId}',
          item.nome,
          item.corNome,
          item.tamanhoNome,
          item.unidadeMedida ?? '',
          item.saldo.toStringAsFixed(2).replaceAll('.', ','),
          _fmtData(item.atualizadoEm),
        ]),
    ];
    return _salvarCsv(linhas, 'estoque_saldo.csv');
  }

  static Future<String?> exportarPorReferencia(
    List<ProdutoDoEstoquePorReferencia> itens,
  ) {
    final linhas = [
      _linha([
        'Referência',
        'Nome',
        'Variações',
        'Saldo total',
        'Atualizado em',
      ]),
      for (final item in itens)
        _linha([
          item.referenciaIdExterno ?? '${item.referenciaId}',
          item.nome,
          '${item.quantidadeVariacoes}',
          item.saldoTotal.toStringAsFixed(2).replaceAll('.', ','),
          _fmtData(item.atualizadoEm),
        ]),
    ];
    return _salvarCsv(linhas, 'estoque_saldo_por_referencia.csv');
  }
}
