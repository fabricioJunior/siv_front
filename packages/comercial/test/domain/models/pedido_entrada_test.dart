import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lê o resumo do backend (decimais como texto, status e totais)', () {
    final resumo = EntradaResumo.fromJson(const {
      'pedidoId': 9,
      'origemEntrada': 'NFE',
      'nfe': null,
      'linhas': [
        {
          'id': 1,
          'sequencia': 1,
          'descricao': 'X',
          'quantidadeNfe': '10.0000',
          'valorUnitario': '45.500000',
          'valorTotal': '455.00',
          'status': 'referencia_vinculada',
          'referenciaId': '7',
          'quantidadeContada': 6,
          'diferenca': -4,
          'divergente': true,
          'divergenciaResolvidaEm': '2026-10-03T10:00:00.000Z',
        },
      ],
      'contagens': [
        {'produtoId': 5, 'linhaId': 1, 'quantidade': '6.0000', 'corId': 2},
      ],
      'totais': {'nfe': 10, 'contado': 6},
      'pendencias': [],
    });

    final linha = resumo.linhas.single;
    expect(linha.status, StatusLinhaEntrada.referenciaVinculada);
    expect(linha.quantidadeNfe, 10);
    expect(linha.valorUnitario, 45.5);
    expect(linha.referenciaId, 7);
    expect(linha.divergente, isTrue);
    expect(linha.divergenciaResolvida, isTrue);
    expect(resumo.contagensDaLinha(1).single.quantidade, 6);
    expect(resumo.totalContado, 6);
  });

  test('ItemContagem só manda os campos informados', () {
    expect(
      const ItemContagem(produtoId: 3, quantidade: 2).toJson(),
      {'produtoId': 3, 'quantidade': 2.0},
    );
  });
}
