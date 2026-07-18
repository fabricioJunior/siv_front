import 'package:comercial/domain/models/danfe.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_esc_pos_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

DanfeLayoutData _dados({String? qrCodePayload}) => DanfeLayoutData(
      empresa: const DanfeEmpresa(razaoSocial: 'Loja Teste', cnpj: '00000000000191'),
      identificacao: DanfeIdentificacao(
        tipoDocumento: 'NFC-e',
        numero: '123',
        serie: '1',
        dataEmissao: DateTime(2026, 7, 18, 12),
      ),
      itens: const [
        DanfeItem(
          descricao: 'Produto teste',
          quantidade: 1,
          unidade: 'UN',
          valorUnitario: 10,
          valorTotal: 10,
        ),
      ],
      totais: const DanfeTotais(subtotal: 10, total: 10),
      pagamentos: const [DanfePagamento(forma: 'Dinheiro', valor: 10)],
      consumidor: const DanfeConsumidor(),
      autorizacao: const DanfeAutorizacao(chaveAcesso: '12345678901234567890123456789012345678901234'),
      qrCodePayload: qrCodePayload,
    );

void main() {
  group('DanfeEscPosRenderer', () {
    test('gera bytes nao vazios e termina com comando de corte (GS V)', () {
      final bytes = DanfeEscPosRenderer.render(_dados(), largura: DanfeLarguraPapel.mm80);

      expect(bytes, isNotEmpty);
      // GS V 0 -- corte total, ultimo comando emitido.
      expect(bytes.sublist(bytes.length - 3), [0x1D, 0x56, 0x00]);
    });

    test('inclui comando de QR Code (GS ( k) quando ha payload de QR', () {
      final bytes = DanfeEscPosRenderer.render(
        _dados(qrCodePayload: 'https://exemplo/consulta'),
        largura: DanfeLarguraPapel.mm58,
      );

      final marcador = [0x1D, 0x28, 0x6B];
      var encontrado = false;
      for (var i = 0; i <= bytes.length - marcador.length; i++) {
        if (bytes[i] == marcador[0] && bytes[i + 1] == marcador[1] && bytes[i + 2] == marcador[2]) {
          encontrado = true;
          break;
        }
      }
      expect(encontrado, isTrue);
    });

    test('nao inclui comando de QR Code quando payload e nulo', () {
      final bytes = DanfeEscPosRenderer.render(_dados(), largura: DanfeLarguraPapel.mm58);

      final marcador = [0x1D, 0x28, 0x6B];
      var encontrado = false;
      for (var i = 0; i <= bytes.length - marcador.length; i++) {
        if (bytes[i] == marcador[0] && bytes[i + 1] == marcador[1] && bytes[i + 2] == marcador[2]) {
          encontrado = true;
          break;
        }
      }
      expect(encontrado, isFalse);
    });
  });
}
