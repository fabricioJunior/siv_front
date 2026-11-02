
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/variacoes_fakes.dart';

VariacoesGatewayFake _gateway() => VariacoesGatewayFake(
      coresLista: const [VariacaoOpcao(id: 1, nome: 'Azul')],
      estampasLista: const [VariacaoOpcao(id: 7, nome: 'Floral')],
      tamanhosLista: const [TamanhoOpcao(id: 1, nome: '36')],
    );

void main() {
  test('estado inicial: as três listas carregando', () {
    final b = criarVariacoesBloc(_gateway());
    expect(b.state.cores.status, VariacaoStatus.carregando);
    expect(b.state.tamanhos.status, VariacaoStatus.carregando);
    b.close();
  });

  test('VariacoesCarregadas: carrega cores, estampas e tamanhos', () async {
    final b = criarVariacoesBloc(_gateway())..add(const VariacoesCarregadas());
    final s = await b.stream.firstWhere((s) =>
        s.cores.status == VariacaoStatus.sucesso &&
        s.estampas.status == VariacaoStatus.sucesso &&
        s.tamanhos.status == VariacaoStatus.sucesso);
    expect(s.cores.itens.single.nome, 'Azul');
    expect(s.estampas.itens.single.nome, 'Floral');
    expect(s.tamanhos.itens.single.nome, '36');
    await b.close();
  });

  test('falha vira status falha e reenviar o evento recupera', () async {
    final g = _gateway()..falha = true;
    final b = criarVariacoesBloc(g)..add(const VariacoesCarregadas());
    var s = await b.stream.firstWhere((s) =>
        s.cores.status == VariacaoStatus.falha &&
        s.estampas.status == VariacaoStatus.falha &&
        s.tamanhos.status == VariacaoStatus.falha);
    expect(s.cores.erro, isNotNull);

    g.falha = false;
    b.add(const VariacoesCarregadas());
    s = await b.stream.firstWhere((s) =>
        s.cores.status == VariacaoStatus.sucesso &&
        s.estampas.status == VariacaoStatus.sucesso &&
        s.tamanhos.status == VariacaoStatus.sucesso);
    expect(s.cores.itens, hasLength(1));
    await b.close();
  });

  test('só relê o que não carregou (reenvio com tudo pronto não vai à rede)', () async {
    final g = _gateway();
    final b = criarVariacoesBloc(g)..add(const VariacoesCarregadas());
    await b.stream.firstWhere((s) =>
        s.cores.status == VariacaoStatus.sucesso &&
        s.estampas.status == VariacaoStatus.sucesso &&
        s.tamanhos.status == VariacaoStatus.sucesso);
    b.add(const VariacoesCarregadas());
    await Future<void>.delayed(Duration.zero);
    expect(g.chamadasCores + g.chamadasEstampas + g.chamadasTamanhos, 3);
    await b.close();
  });

  test('VariacoesCorCadastrada: cor nova entra na lista e vira ultimoCadastrado', () async {
    final b = criarVariacoesBloc(_gateway())..add(const VariacoesCarregadas());
    await b.stream.firstWhere((s) => s.cores.status == VariacaoStatus.sucesso);

    b.add(const VariacoesCorCadastrada('Rosa'));
    final s = await b.stream.firstWhere((s) => s.cores.ultimoCadastrado != null);

    expect(s.cores.ultimoCadastrado!.nome, 'Rosa');
    expect(s.cores.itens.map((c) => c.nome), ['Azul', 'Rosa']);
    await b.close();
  });

  test('VariacoesEstampaCadastrada: estampa nova entra na lista', () async {
    final b = criarVariacoesBloc(_gateway())..add(const VariacoesCarregadas());
    await b.stream
        .firstWhere((s) => s.estampas.status == VariacaoStatus.sucesso);

    b.add(const VariacoesEstampaCadastrada('Listrada'));
    final s =
        await b.stream.firstWhere((s) => s.estampas.ultimoCadastrado != null);

    expect(s.estampas.itens.map((e) => e.nome), ['Floral', 'Listrada']);
    await b.close();
  });
}
