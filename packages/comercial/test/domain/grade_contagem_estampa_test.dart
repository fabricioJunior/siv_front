import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _c(int produtoId, {int? estampaId, String? estampa, int ref = 1}) => {
      'produtoId': produtoId,
      'quantidade': 1,
      'referenciaId': ref,
      'corNome': 'MARROM',
      'tamanhoNome': 'M',
      'estampaId': estampaId,
      'estampaNome': estampa,
    };

void main() {
  test('liso e estampado da mesma referência se distinguem; sem estampa nada muda', () {
    final r = EntradaResumo.fromJson({
      'pedidoId': 1,
      'contagens': [
        _c(1),
        _c(2, estampaId: 5, estampa: 'LISTRADO'),
        _c(3, ref: 2),
      ],
    });
    final [liso, listrado, outra] = r.contagens;

    expect(r.gradeDe(liso), 'MARROM · Liso · M');
    expect(r.gradeDe(listrado), 'MARROM · LISTRADO · M');
    expect(r.gradeDe(outra), 'MARROM · M');
  });
}
