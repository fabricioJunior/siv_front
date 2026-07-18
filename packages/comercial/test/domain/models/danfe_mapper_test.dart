import 'package:comercial/data/remote/dtos/documento_fiscal_dto.dart';
import 'package:comercial/domain/models/danfe_mapper.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:flutter_test/flutter_test.dart';

DocumentoFiscalDto _documento({
  Map<String, dynamic>? destinatario,
  List<Map<String, dynamic>>? produtos,
  String? pessoaNome,
  Map<String, dynamic>? pedido,
  String chaveAcesso = '35260112345678000199650010000012341234567890',
}) {
  return DocumentoFiscalDto.fromJson({
    'id': 1,
    'empresaId': 1,
    'romaneioId': 10,
    'acao': 'emitir',
    'tipoDocumento': 'nfce',
    'status': 'emitida',
    'provider': 'webmania',
    'chaveAcesso': chaveAcesso,
    'protocolo': '135260000012345',
    'tentativas': 1,
    'maxTentativas': 5,
    'updatedAt': '2026-07-18T12:00:00.000Z',
    'payload': {
      'pessoaNome': pessoaNome,
      'webmania': {
        'payload': {
          'modelo': 2,
          'pedido': pedido ??
              {
                'forma_pagamento': '01',
                'valor_pagamento': '20.00',
                'desconto': 0,
                'total': 20.0,
              },
          'destinatario': destinatario,
          'produtos': produtos ??
              [
                {
                  'codigo': '123',
                  'nome': 'Produto Teste',
                  'unidade': 'UN',
                  'quantidade': 2,
                  'subtotal': 20.0,
                  'total': 20.0,
                },
              ],
        },
      },
    },
  });
}

void main() {
  group('construirDanfeLayoutData', () {
    test('mapeia consumidor identificado (cpf/nome)', () {
      final doc = _documento(
        pessoaNome: 'Fulano de Tal',
        destinatario: {'cpf': '12345678900', 'nome_completo': 'Fulano de Tal'},
      );

      final romaneio = Romaneio.create(incluirCpfNaNota: true);

      final dados = construirDanfeLayoutData(doc, romaneio: romaneio);

      expect(dados.consumidor.identificado, isTrue);
      expect(dados.consumidor.nome, 'Fulano de Tal');
      expect(dados.consumidor.documento, '12345678900');
    });

    test('sem destinatario -> consumidor nao identificado', () {
      final doc = _documento();
      final romaneio = Romaneio.create(incluirCpfNaNota: true);

      final dados = construirDanfeLayoutData(doc, romaneio: romaneio);

      expect(dados.consumidor.identificado, isFalse);
      expect(dados.consumidor.documento, isNull);
    });

    test('cpf nao solicitado na nota -> consumidor nao identificado mesmo com nome', () {
      final doc = _documento(
        pessoaNome: 'Fulano de Tal',
        destinatario: {'cpf': '12345678900', 'nome_completo': 'Fulano de Tal'},
      );
      final romaneio = Romaneio.create(incluirCpfNaNota: false);

      final dados = construirDanfeLayoutData(doc, romaneio: romaneio);

      expect(dados.consumidor.identificado, isFalse);
      expect(dados.consumidor.nome, isNull);
      expect(dados.consumidor.documento, isNull);
    });

    test('sem romaneio -> consumidor nao identificado mesmo com nome/cpf', () {
      final doc = _documento(
        pessoaNome: 'Fulano de Tal',
        destinatario: {'cpf': '12345678900', 'nome_completo': 'Fulano de Tal'},
      );

      final dados = construirDanfeLayoutData(doc);

      expect(dados.consumidor.identificado, isFalse);
    });

    test('item com desconto (subtotal > total) calcula desconto do item', () {
      final doc = _documento(
        produtos: [
          {
            'codigo': '1',
            'nome': 'Produto com desconto',
            'unidade': 'UN',
            'quantidade': 1,
            'subtotal': 10.0,
            'total': 8.0,
          },
        ],
      );

      final dados = construirDanfeLayoutData(doc);

      expect(dados.itens.single.desconto, 2.0);
    });

    test('item sem desconto (subtotal == total) nao seta desconto', () {
      final doc = _documento(
        produtos: [
          {
            'codigo': '1',
            'nome': 'Produto sem desconto',
            'unidade': 'UN',
            'quantidade': 1,
            'subtotal': 10.0,
            'total': 10.0,
          },
        ],
      );

      final dados = construirDanfeLayoutData(doc);

      expect(dados.itens.single.desconto, isNull);
    });

    test('chave de acesso e protocolo mapeados pra autorizacao', () {
      final doc = _documento();

      final dados = construirDanfeLayoutData(doc);

      expect(dados.autorizacao.chaveAcesso, doc.chaveAcesso);
      expect(dados.autorizacao.protocolo, doc.protocolo);
      expect(dados.identificacao.numero, isNotNull);
      expect(dados.identificacao.serie, isNotNull);
    });

    test('monta URL do QR Code a partir do cUF (2 primeiros digitos da chave)', () {
      // cUF=22 (Piauí), chave real de exemplo.
      final doc = _documento(chaveAcesso: '22260741108590000158650010000036961145483370');

      final dados = construirDanfeLayoutData(doc);

      expect(
        dados.qrCodePayload,
        'https://webas.sefaz.pi.gov.br/nfce/22260741108590000158650010000036961145483370',
      );
    });

    test('cUF nao mapeado -> qrCodePayload nulo', () {
      final doc = _documento(chaveAcesso: '99260741108590000158650010000036961145483370');

      final dados = construirDanfeLayoutData(doc);

      expect(dados.qrCodePayload, isNull);
    });

    test('chave de acesso ausente -> qrCodePayload nulo', () {
      final doc = DocumentoFiscalDto.fromJson({
        'id': 1,
        'empresaId': 1,
        'romaneioId': 10,
        'acao': 'emitir',
        'tipoDocumento': 'nfce',
        'status': 'pendente',
        'provider': 'webmania',
        'tentativas': 0,
        'maxTentativas': 5,
      });

      final dados = construirDanfeLayoutData(doc);

      expect(dados.qrCodePayload, isNull);
    });

    test('troco vem de Romaneio.troco quando presente', () {
      final doc = _documento();
      final romaneio = Romaneio.create(troco: 5.50);

      final dados = construirDanfeLayoutData(doc, romaneio: romaneio);

      expect(dados.troco, 5.50);
    });

    test('sem romaneio ou sem troco -> troco nulo', () {
      final doc = _documento();

      expect(construirDanfeLayoutData(doc).troco, isNull);
      expect(
        construirDanfeLayoutData(doc, romaneio: Romaneio.create()).troco,
        isNull,
      );
    });

    test('forma_pagamento em lista (split) gera multiplos pagamentos', () {
      final doc = _documento(
        pedido: {
          'forma_pagamento': ['01', '17'],
          'valor_pagamento': ['10.00', '10.00'],
          'desconto': 0,
          'total': 20.0,
        },
      );

      final dados = construirDanfeLayoutData(doc);

      expect(dados.pagamentos, hasLength(2));
      expect(dados.pagamentos[0].forma, 'Dinheiro');
      expect(dados.pagamentos[1].forma, 'PIX');
    });
  });
}
