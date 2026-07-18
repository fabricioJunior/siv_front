import 'dart:typed_data';

import 'package:comercial/domain/models/documento_fiscal.dart';
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
