import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/variacoes_fakes.dart';

void main() {
  test('cores: ordena A-Z sem acento/caixa e a 2ª chamada usa o cache', () async {
    final g = VariacoesGatewayFake(coresLista: const [
      VariacaoOpcao(id: 1, nome: 'vinho'),
      VariacaoOpcao(id: 2, nome: 'Água'),
      VariacaoOpcao(id: 3, nome: 'Azul'),
    ]);
    final uc = RecuperarCoresDeProdutos(g);

    expect((await uc()).map((c) => c.nome), ['Água', 'Azul', 'vinho']);
    await uc();
    expect(g.chamadasCores, 1);
  });

  test('chamadas simultâneas compartilham a mesma leitura', () async {
    final g = VariacoesGatewayFake();
    final uc = RecuperarEstampasDeProdutos(g);
    await Future.wait([uc(), uc()]);
    expect(g.chamadasEstampas, 1);
  });

  test('erro não é cacheado: a chamada seguinte vai ao gateway de novo', () async {
    final g = VariacoesGatewayFake(
        tamanhosLista: const [TamanhoOpcao(id: 1, nome: 'P')])
      ..falha = true;
    final uc = RecuperarTamanhosDeProdutos(g);

    await expectLater(uc(), throwsException);
    g.falha = false;
    expect((await uc()).single.nome, 'P');
    await uc();
    expect(g.chamadasTamanhos, 2);
  });

  test('CriarCor adiciona à lista em cache (ordenada) sem reler o gateway', () async {
    final g = VariacoesGatewayFake(coresLista: const [
      VariacaoOpcao(id: 1, nome: 'Azul'),
      VariacaoOpcao(id: 2, nome: 'Verde'),
    ]);
    final lista = RecuperarCoresDeProdutos(g);
    final criar = CriarCorDeProdutos(g, lista);
    await lista();

    final nova = await criar('Rosa');

    expect(nova.nome, 'Rosa');
    expect((await lista()).map((c) => c.nome), ['Azul', 'Rosa', 'Verde']);
    expect(g.chamadasCores, 1);
  });

  test('CriarEstampa adiciona à lista em cache', () async {
    final g = VariacoesGatewayFake(
        estampasLista: const [VariacaoOpcao(id: 1, nome: 'Floral')]);
    final lista = RecuperarEstampasDeProdutos(g);
    await CriarEstampaDeProdutos(g, lista)('Listrada');
    expect((await lista()).map((e) => e.nome), ['Floral', 'Listrada']);
    expect(g.chamadasEstampas, 1);
  });
}
