import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagamentos/models.dart';
import 'package:pagamentos/presentation.dart';
import 'package:pagamentos/use_cases.dart';

class FakeCriarPagamentoAvulso extends Fake implements CriarPagamentoAvulso {
  Future<PagamentoAvulso> Function(
    PagamentoAvulso pagamento, {
    int? expiracaoHoras,
  })?
  handler;

  int? ultimaExpiracaoHoras;

  @override
  Future<PagamentoAvulso> call(
    PagamentoAvulso pagamento, {
    int? expiracaoHoras,
  }) {
    ultimaExpiracaoHoras = expiracaoHoras;
    return handler!(pagamento, expiracaoHoras: expiracaoHoras);
  }
}

late PagamentoAvulsoBloc bloc;
late FakeCriarPagamentoAvulso criarPagamentoAvulso;
late CriarIdempotencyKey criarIdempotencyKey;

void main() {
  setUp(() {
    criarPagamentoAvulso = FakeCriarPagamentoAvulso();
    criarIdempotencyKey = CriarIdempotencyKey();

    bloc = PagamentoAvulsoBloc(criarPagamentoAvulso, criarIdempotencyKey);
  });

  final pagamentoCriado = _fakePagamento(id: 1);

  blocTest<PagamentoAvulsoBloc, PagamentoAvulsoState>(
    'PagamentoAvulsoIniciou define expiracaoHoras padrao como 48',
    build: () => bloc,
    act: (bloc) => bloc.add(PagamentoAvulsoIniciou()),
    verify: (bloc) {
      expect(bloc.state.expiracaoHoras, 48);
    },
  );

  blocTest<PagamentoAvulsoBloc, PagamentoAvulsoState>(
    'PagamentoAvulsoCampoAlterado atualiza expiracaoHoras customizado',
    build: () => bloc,
    seed: () => const PagamentoAvulsoState(
      step: PagamentoAvulsoStep.editando,
      expiracaoHoras: 48,
    ),
    act: (bloc) => bloc.add(
      PagamentoAvulsoCampoAlterado(expiracaoHoras: 72),
    ),
    verify: (bloc) {
      expect(bloc.state.expiracaoHoras, 72);
    },
  );

  blocTest<PagamentoAvulsoBloc, PagamentoAvulsoState>(
    'PagamentoAvulsoSalvou envia expiracaoHoras customizado para o use case '
    'e emite o pagamento criado ao final',
    setUp: () {
      criarPagamentoAvulso.handler =
          (pagamento, {expiracaoHoras}) async => pagamentoCriado;
    },
    build: () => bloc,
    seed: () => PagamentoAvulsoState(
      step: PagamentoAvulsoStep.editando,
      provider: 'infinitypay',
      amount: 1000,
      description: 'Pagamento teste',
      idempotencyKey: 'idempotency-1',
      customerNome: 'Cliente Teste',
      customerDocumento: '12345678900',
      customerEmail: 'cliente@teste.com',
      customerTelefone: '11999999999',
      expiracaoHoras: 72,
    ),
    act: (bloc) => bloc.add(PagamentoAvulsoSalvou()),
    verify: (bloc) {
      expect(criarPagamentoAvulso.ultimaExpiracaoHoras, 72);
      expect(bloc.state.step, PagamentoAvulsoStep.salvo);
      expect(bloc.state.pagamento, pagamentoCriado);
    },
  );
}

PagamentoAvulso _fakePagamento({required int id}) {
  return PagamentoAvulso.create(
    id: id,
    provider: 'infinitypay',
    amount: 1000,
    description: 'Pagamento teste',
    idempotencyKey: 'idempotency-$id',
    customer: PagamentoAvulsoCustomer.create(
      nome: 'Cliente Teste',
      documento: '12345678900',
      email: 'cliente@teste.com',
      telefone: '11999999999',
    ),
  );
}
