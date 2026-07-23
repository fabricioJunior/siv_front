import 'dart:typed_data';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/pedido_item.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:comercial/domain/models/romaneio_item.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_pdf_renderer.dart';
import 'package:comercial/presentation/relatorios/nota_entrega/nota_entrega_pdf_renderer.dart';
import 'package:core/impressoras/printers/sefaz_nfce_portais.dart';
import 'package:core/pdf.dart' show PdfPageFormat;

/// Gera o PDF da Nota de Entrega -- documento simplificado pro entregador,
/// com o endereco de entrega e nome do cliente em destaque. Sempre
/// renderizado localmente (sem dependencia de servidor), por isso
/// `erroServidor` fica sempre `null` -- mantido no retorno so pra seguir o
/// mesmo padrao de [NotaFiscalPdfExporter.gerarBytes] usado por
/// `imprimirDocumentoPdf`/`comAvisoServidor`.
class NotaEntregaPdfExporter {
  NotaEntregaPdfExporter._();

  static Future<({Uint8List bytes, Object? erroServidor})> gerarBytes({
    required Romaneio romaneio,
    required List<RomaneioItem> itens,
    required String enderecoFormatado,
    DocumentoFiscal? documentoFiscal,
    bool documentoFiscalFalhou = false,
    PdfPageFormat pageFormat = DanfePdfRenderer.roll80Seguro,
  }) async {
    final dados = NotaEntregaLayoutData(
      enderecoFormatado: enderecoFormatado,
      googleMapsUrl: _googleMapsUrl(enderecoFormatado),
      nomeCliente: (romaneio.pessoaNome?.trim().isNotEmpty ?? false)
          ? romaneio.pessoaNome!.trim().toUpperCase()
          : 'CLIENTE NÃO IDENTIFICADO',
      // "data" é coluna DATE no banco (sem hora, sempre 00:00) -- criadoEm
      // tem o timestamp completo da venda, é o que reflete o horário real.
      dataCompra: romaneio.criadoEm ?? romaneio.data,
      numeroRomaneio: romaneio.id,
      empresaNome: romaneio.empresaNome ?? 'Empresa não identificada',
      empresaCnpj: romaneio.empresaCnpj,
      itens: itens
          .where((item) => (item.quantidade ?? 0) != 0)
          .map(
            (item) => NotaEntregaItem(
              descricao: (item.referenciaNome?.trim().isNotEmpty ?? false)
                  ? item.referenciaNome!.trim()
                  : (item.referenciaDescricao?.trim().isNotEmpty ?? false)
                      ? item.referenciaDescricao!.trim()
                      : 'Produto #${item.produtoId ?? '-'}',
              valor: item.valorTotalLiquido ?? item.valorTotalBruto,
            ),
          )
          .toList(growable: false),
      dadosFiscais: _dadosFiscais(documentoFiscal, documentoFiscalFalhou),
    );

    final bytes =
        await NotaEntregaPdfRenderer.render(dados, pageFormat: pageFormat);
    return (bytes: bytes, erroServidor: null);
  }

  /// Mesmo documento, mas gerado a partir de um Pedido ainda em andamento --
  /// não depende de romaneio/faturamento (que só existe depois de faturado),
  /// já que a entrega física acontece ANTES disso: o entregador precisa da
  /// nota de entrega pra sair com o pacote, não depois de confirmar a
  /// entrega. Sem documento fiscal nesse ponto (pedido não faturado ainda),
  /// por isso não recebe `documentoFiscal` -- os campos fiscais só existem
  /// no PDF do romaneio já encerrado.
  static Future<({Uint8List bytes, Object? erroServidor})> gerarBytesParaPedido({
    required int numeroPedido,
    required String? pessoaNome,
    required DateTime? dataPedido,
    required String empresaNome,
    String? empresaCnpj,
    required String enderecoFormatado,
    required List<PedidoItem> itens,
    PdfPageFormat pageFormat = DanfePdfRenderer.roll80Seguro,
  }) async {
    final dados = NotaEntregaLayoutData(
      enderecoFormatado: enderecoFormatado,
      googleMapsUrl: _googleMapsUrl(enderecoFormatado),
      nomeCliente: (pessoaNome?.trim().isNotEmpty ?? false)
          ? pessoaNome!.trim().toUpperCase()
          : 'CLIENTE NÃO IDENTIFICADO',
      dataCompra: dataPedido,
      numeroRomaneio: numeroPedido,
      rotuloNumero: 'Pedido',
      empresaNome: empresaNome,
      empresaCnpj: empresaCnpj,
      itens: itens
          .where((item) => (item.solicitado ?? 0) != 0)
          .map(
            (item) => NotaEntregaItem(
              descricao: (item.referenciaNome?.trim().isNotEmpty ?? false)
                  ? item.referenciaNome!.trim()
                  : 'Produto #${item.produtoId ?? '-'}',
              valor: ((item.valorUnitario ?? 0) - (item.valorUnitDesconto ?? 0)) *
                  (item.solicitado ?? 0),
            ),
          )
          .toList(growable: false),
      dadosFiscais: null,
    );

    final bytes =
        await NotaEntregaPdfRenderer.render(dados, pageFormat: pageFormat);
    return (bytes: bytes, erroServidor: null);
  }

  /// Monta a URL de busca do Google Maps a partir do endereco ja formatado
  /// (multi-linha, com "CEP:" etc) -- a API de busca do Maps aceita texto
  /// livre, entao nao precisa dos campos crus do endereco separados.
  static String? _googleMapsUrl(String enderecoFormatado) {
    final query = enderecoFormatado.replaceAll('\n', ', ').trim();
    if (query.isEmpty) return null;
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
  }

  static NotaEntregaDadosFiscais? _dadosFiscais(
    DocumentoFiscal? documento,
    bool documentoFiscalFalhou,
  ) {
    if (documento == null || documentoFiscalFalhou) return null;
    final chaveAcesso = documento.chaveAcesso;
    if (chaveAcesso == null || chaveAcesso.trim().isEmpty) return null;

    return NotaEntregaDadosFiscais(
      numeroNota: _numeroNota(chaveAcesso),
      protocolo: documento.protocolo,
      qrCodeUrl: sefazNfceUrl(chaveAcesso),
    );
  }

  /// Extrai o numero da nota a partir da chave de acesso (44 digitos,
  /// padrao SEFAZ): posicoes 25-33 = numero. Mesma logica de
  /// `_numeroSerie` em `danfe_mapper.dart`.
  static String? _numeroNota(String? chaveAcesso) {
    final chave = chaveAcesso?.replaceAll(RegExp(r'\D'), '');
    if (chave == null || chave.length != 44) return null;
    return chave.substring(25, 34).replaceFirst(RegExp(r'^0+(?=\d)'), '');
  }
}
