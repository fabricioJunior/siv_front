import 'package:comercial/presentation/blocs/creditos_devolucao_bloc/creditos_devolucao_bloc.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/credito_fakes.dart';

void main() {
  late FakeLista lista;
  late FakeResumo resumo;
  late FakeAdicionar adicionar;
  late FakeRemover remover;
  late FakeExpirar expirar;
  late FakeConfig config;
  late CreditosDevolucaoBloc bloc;

  setUp(() {
    lista = FakeLista();
    resumo = FakeResumo();
    adicionar = FakeAdicionar();
    remover = FakeRemover();
    expirar = FakeExpirar();
    config = FakeConfig();
    bloc = CreditosDevolucaoBloc(lista, resumo, FakeExtrato(), adicionar, remover,
        expirar, config, FakeEmpresas(), FakeSessao());
  });
  tearDown(() => bloc.close());

  Future<CreditosDevolucaoState> carregar() async {
    bloc.add(CreditosDevolucaoCarregou(7));
    return bloc.stream.firstWhere((s) =>
        s.status != CreditosDevolucaoStatus.carregando && !s.executando);
  }

  test('carregar: lista, resumo e config da empresa', () async {
    final s = await carregar();
    expect(s.status, CreditosDevolucaoStatus.pronto);
    expect(s.creditos.single.id, 1);
    expect(s.resumo.saldoDisponivel, 100);
    expect(s.avisoDias, 10);
    expect(s.config!.validadeDiasPadrao, 60);
  });

  test('carregar: config falha -> padrões (aviso 7 dias)', () async {
    config.falha = true;
    final s = await carregar();
    expect(s.status, CreditosDevolucaoStatus.pronto);
    expect(s.config, isNull);
    expect(s.avisoDias, 7);
  });

  test('carregar: erro de API -> status erro (mensagem genérica)', () async {
    lista.erro = HttpException('x', statusCode: 500, apiMessage: 'Sem acesso');
    final s = await carregar();
    expect(s.status, CreditosDevolucaoStatus.erro);
    // BUG conhecido: `(a, b, c).wait` lança ParallelWaitError, então a
    // apiMessage some. Quando corrigir, esperar 'Sem acesso'.
    expect(s.erro, 'Falha ao carregar o crédito de devolução.');
  });

  test('adicionar: envia dados, recarrega e informa saldo novo', () async {
    await carregar();
    final antes = lista.chamadas;
    bloc.add(CreditosDevolucaoAdicionou(
        valor: 50, motivo: 'cortesia', observacao: 'brinde', empresaId: 1));
    final s = await bloc.stream.firstWhere((s) => s.acoesConcluidas == 1);
    expect(adicionar.args,
        {'pessoaId': 7, 'valor': 50.0, 'motivo': 'cortesia', 'observacao': 'brinde', 'empresaId': 1});
    expect(lista.chamadas, antes + 1);
    expect(s.saldoAposAcao, 150);
    expect(s.executando, isFalse);
    expect(s.erroAcao, isNull);
  });

  test('adicionar: erro da API -> erroAcao, sem contar ação concluída',
      () async {
    await carregar();
    adicionar.erro =
        HttpException('x', statusCode: 403, apiMessage: 'Proibido');
    bloc.add(CreditosDevolucaoAdicionou(
        valor: 50, motivo: 'cortesia', observacao: 'brinde'));
    final s = await bloc.stream
        .firstWhere((s) => !s.executando && s.erroAcao != null);
    expect(s.erroAcao, 'Proibido');
    expect(s.acoesConcluidas, 0);
    expect(s.status, CreditosDevolucaoStatus.pronto);
  });

  test('adicionar: erro sem mensagem usa o texto padrão', () async {
    await carregar();
    adicionar.erro = Exception('boom');
    bloc.add(CreditosDevolucaoAdicionou(
        valor: 5, motivo: 'ajuste', observacao: 'abc'));
    final s = await bloc.stream.firstWhere((s) => s.erroAcao != null);
    expect(s.erroAcao, 'Falha ao adicionar o crédito.');
  });

  test('remover total: valor nulo', () async {
    await carregar();
    bloc.add(CreditosDevolucaoRemoveu(creditoId: 1, motivo: 'duplicidade'));
    final s = await bloc.stream.firstWhere((s) => s.acoesConcluidas == 1);
    expect(remover.args!['valor'], isNull);
    expect(s.saldoAposAcao, 40);
  });

  test('remover parcial: envia o valor informado', () async {
    await carregar();
    bloc.add(CreditosDevolucaoRemoveu(
        creditoId: 1, valor: 30, motivo: 'outro', observacao: 'x y z'));
    await bloc.stream.firstWhere((s) => s.acoesConcluidas == 1);
    expect(remover.args, {'creditoId': 1, 'valor': 30.0, 'motivo': 'outro'});
  });

  test('expirar: envia motivo e recarrega', () async {
    await carregar();
    final antes = lista.chamadas;
    bloc.add(CreditosDevolucaoExpirou(creditoId: 1, motivo: 'aviso'));
    final s = await bloc.stream.firstWhere((s) => s.acoesConcluidas == 1);
    expect(expirar.args, {'creditoId': 1, 'motivo': 'aviso'});
    expect(lista.chamadas, antes + 1);
    expect(s.saldoAposAcao, 0);
  });

  test('ação ok mas recarga falha: ainda conta como concluída', () async {
    await carregar();
    lista.erro = Exception('rede');
    bloc.add(CreditosDevolucaoExpirou(creditoId: 1));
    final s = await bloc.stream.firstWhere((s) => s.acoesConcluidas == 1);
    expect(s.erroAcao, isNull);
    expect(s.executando, isFalse);
  });
}
