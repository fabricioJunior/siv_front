import 'package:comercial/domain/models/danfe.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_pdf_renderer.dart';
import 'package:core/pdf.dart' show PdfPageFormat;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('renderiza PDF valido (assinatura %PDF) em 58mm e 80mm', () async {
    final dados = DanfeLayoutData(
      empresa: const DanfeEmpresa(razaoSocial: 'Loja Teste', cnpj: '00000000000191'),
      identificacao: DanfeIdentificacao(
        tipoDocumento: 'NFC-e',
        numero: '123',
        serie: '1',
        dataEmissao: DateTime(2026, 7, 18, 12),
      ),
      itens: const [
        DanfeItem(
          descricao:
              'Produto com descricao bem longa pra validar quebra automatica de linha no PDF',
          quantidade: 1,
          unidade: 'UN',
          valorUnitario: 10,
          valorTotal: 10,
        ),
      ],
      totais: const DanfeTotais(subtotal: 10, total: 10),
      pagamentos: const [DanfePagamento(forma: 'Dinheiro', valor: 10)],
      consumidor: const DanfeConsumidor(),
      autorizacao: const DanfeAutorizacao(
        chaveAcesso: '12345678901234567890123456789012345678901234',
      ),
      qrCodePayload: 'https://exemplo/consulta',
    );

    for (final formato in [PdfPageFormat.roll57, PdfPageFormat.roll80]) {
      final bytes = await DanfePdfRenderer.render(dados, pageFormat: formato);
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    }
  });
}
