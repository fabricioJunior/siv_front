import 'package:comercial/domain/models/danfe.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_layout.dart';
import 'package:flutter_test/flutter_test.dart';

DanfeLayoutData _dados({num? troco}) => DanfeLayoutData(
      empresa: const DanfeEmpresa(razaoSocial: 'Loja Teste'),
      identificacao: DanfeIdentificacao(tipoDocumento: 'NFC-e', dataEmissao: DateTime(2026)),
      itens: const [
        DanfeItem(descricao: 'Produto', quantidade: 1, unidade: 'UN', valorUnitario: 10, valorTotal: 10),
      ],
      totais: const DanfeTotais(subtotal: 10, total: 10),
      pagamentos: const [DanfePagamento(forma: 'Dinheiro', valor: 15)],
      troco: troco,
      consumidor: const DanfeConsumidor(),
      autorizacao: const DanfeAutorizacao(),
    );

bool _temLinhaTroco(List<DanfeNode> nodes) => nodes
    .whereType<DanfeLinhaDupla>()
    .any((n) => n.esquerda == DanfeTextos.trocoLabel);

void main() {
  group('construirDanfeNodes -- troco', () {
    test('imprime linha de troco quando presente e positivo', () {
      final nodes = construirDanfeNodes(_dados(troco: 5));
      expect(_temLinhaTroco(nodes), isTrue);
    });

    test('nao imprime linha de troco quando nulo', () {
      final nodes = construirDanfeNodes(_dados());
      expect(_temLinhaTroco(nodes), isFalse);
    });

    test('nao imprime linha de troco quando zero', () {
      final nodes = construirDanfeNodes(_dados(troco: 0));
      expect(_temLinhaTroco(nodes), isFalse);
    });
  });
}
