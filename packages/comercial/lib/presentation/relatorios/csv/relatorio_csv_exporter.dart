import 'dart:convert';
import 'dart:typed_data';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/models/resumo_fiscal.dart';
import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart' show formatarDataHora;

String _fmtData(String isoDate) {
  if (isoDate.isEmpty) return '-';
  final p = isoDate.split('-');
  if (p.length < 3) return isoDate;
  return '${p[2]}/${p[1]}/${p[0]}';
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

class RelatorioCsvExporter {
  RelatorioCsvExporter._();

  static Future<String?> exportarAniversariantes(
    List<RelatorioClienteAniversarianteItem> items,
  ) {
    final linhas = [
      _linha(['Nome', 'Documento', 'E-mail', 'Telefone', 'Nascimento', 'Última compra']),
      for (final item in items)
        _linha([
          item.nome,
          item.documento,
          item.email ?? '',
          item.contato ?? '',
          _fmtData(item.nascimento),
          item.dataUltimaCompra != null ? _fmtData(item.dataUltimaCompra!) : '',
        ]),
    ];
    return _salvarCsv(linhas, 'clientes_aniversariantes.csv');
  }

  static Future<String?> exportarClientesAtivos(
    List<RelatorioClienteAtivoItem> items,
  ) {
    final linhas = [
      _linha([
        'Cliente',
        'Documento',
        'Número de telefone',
        'E-mail',
        'Ultima Compra',
        'Total Comprado',
        'Quantidade',
      ]),
      for (final item in items)
        _linha([
          item.clienteNome,
          item.clienteDocumento,
          item.clienteTelefone ?? '',
          item.clienteEmail ?? '',
          _fmtData(item.dataUltimaCompra),
          item.valorTotalComprado.toStringAsFixed(2).replaceAll('.', ','),
          '${item.quantidadeCompras}',
        ]),
    ];
    return _salvarCsv(linhas, 'relatorio_clientes_ativos.csv');
  }

  static Future<String?> exportarComprasClientes(
    List<RelatorioCompraClienteItem> items,
  ) {
    final linhas = [
      _linha([
        'Cliente',
        'Documento',
        'E-mail',
        'Telefone',
        'Referência',
        'Cor',
        'Tamanho',
        'Categoria',
        'Total de compras',
        'Qtd. produtos',
        'Valor total comprado',
      ]),
      for (final item in items)
        _linha([
          item.clienteNome,
          item.clienteDocumento,
          item.clienteEmail ?? '',
          item.clienteTelefone ?? '',
          item.referenciaNome ?? '',
          item.corNome ?? '',
          item.tamanhoNome ?? '',
          item.categoriaNome ?? '',
          '${item.totalCompras}',
          '${item.quantidadeProdutos}',
          item.valorTotalCompras.toStringAsFixed(2).replaceAll('.', ','),
        ]),
    ];
    return _salvarCsv(linhas, 'compras_clientes.csv');
  }

  static Future<String?> exportarRelatorioFiscalCsv(
    List<DocumentoFiscal> items,
    ResumoFiscal resumo,
  ) {
    final linhas = [
      _linha(['Saldo consolidado', resumo.saldoConsolidado.toStringAsFixed(2).replaceAll('.', ',')]),
      _linha(['Saldo pendente', resumo.saldoPendente.toStringAsFixed(2).replaceAll('.', ',')]),
      _linha(['Saldo total', resumo.saldoTotal.toStringAsFixed(2).replaceAll('.', ',')]),
      _linha([]),
      _linha(['Data', 'Tipo', 'Status', 'Valor', 'Romaneio', 'Pedido', 'Cliente']),
      for (final item in items)
        _linha([
          item.createdAt != null ? formatarDataHora(item.createdAt) : '',
          item.tipoDocumentoLabel,
          item.status,
          item.valorLiquido.toStringAsFixed(2).replaceAll('.', ','),
          '${item.romaneioId}',
          item.pedidoId != null ? '${item.pedidoId}' : '',
          item.clienteMascarado,
        ]),
    ];
    return _salvarCsv(linhas, 'relatorio_fiscal.csv');
  }
}
