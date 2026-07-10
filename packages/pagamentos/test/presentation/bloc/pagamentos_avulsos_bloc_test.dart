import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagamentos/models.dart';
import 'package:pagamentos/presentation.dart';
import 'package:pagamentos/use_cases.dart';

class FakeRecuperarPagamentosAvulsos extends Fake
    implements RecuperarPagamentosAvulsos {
  Future<List<PagamentoAvulso>> Function({
    String? orderBy,
    String? orderDir,
    String? descricao,
    String? provider,
  })?
  handler;

  final List<Map<String, String?>> chamadas = [];

  @override
  Future<List<PagamentoAvulso>> call({
    String? orderBy,
    String? orderDir,
    String? descricao,
    String? provider,
  }) {
    chamadas.add({
      'orderBy': orderBy,
      'orderDir': orderDir,
      'descricao': descricao,
      'provider': provider,
    });
    return handler!(
      orderBy: orderBy,
      orderDir: orderDir,
      descricao: descricao,
      provider: provider,
    );
  }
}

class FakeRecuperarProvidersPagamentosAvulsos extends Fake
    implements RecuperarProvidersPagamentosAvulsos {
  Future<List<String>> Function()? handler;

  @override
  Future<List<String>> call() {
    return handler!();
  }
}

late PagamentosAvulsosBloc bloc;
late FakeRecuperarPagamentosAvulsos recuperarPagamentosAvulsos;
late FakeRecuperarProvidersPagamentosAvulsos recuperarProvidersPagamentosAvulsos;

void main() {
  setUp(() {
    recuperarPagamentosAvulsos = FakeRecuperarPagamentosAvulsos();
    recuperarProvidersPagamentosAvulsos =
        FakeRecuperarProvidersPagamentosAvulsos();

    bloc = PagamentosAvulsosBloc(
      recuperarPagamentosAvulsos,
      recuperarProvidersPagamentosAvulsos,
    );
  });

  final pagamento = _fakePagamento(id: 1);

  group('PagamentosAvulsosIniciou -', () {
    blocTest<PagamentosAvulsosBloc, PagamentosAvulsosState>(
      'deve carregar pagamentos com filtros padrao',
      setUp: () {
        recuperarPagamentosAvulsos.handler = ({
          orderBy,
          orderDir,
          descricao,
          provider,
        }) async =>
            [pagamento];
      },
      build: () => bloc,
      act: (bloc) => bloc.add(PagamentosAvulsosIniciou()),
      expect: () => [
        const PagamentosAvulsosState(
          step: PagamentosAvulsosStep.carregando,
        ),
        PagamentosAvulsosState(
          step: PagamentosAvulsosStep.carregado,
          pagamentos: [pagamento],
        ),
      ],
      verify: (_) {
        expect(recuperarPagamentosAvulsos.chamadas.single, {
          'orderBy': 'criadoEm',
          'orderDir': 'DESC',
          'descricao': null,
          'provider': null,
        });
      },
    );

    blocTest<PagamentosAvulsosBloc, PagamentosAvulsosState>(
      'deve repassar orderDir, descricao e provider para o use case',
      setUp: () {
        recuperarPagamentosAvulsos.handler = ({
          orderBy,
          orderDir,
          descricao,
          provider,
        }) async =>
            [pagamento];
      },
      build: () => bloc,
      act: (bloc) => bloc.add(
        PagamentosAvulsosIniciou(
          orderDir: 'ASC',
          descricao: 'venda',
          provider: 'openpix',
        ),
      ),
      expect: () => [
        const PagamentosAvulsosState(
          step: PagamentosAvulsosStep.carregando,
          orderDir: 'ASC',
          descricao: 'venda',
          provider: 'openpix',
        ),
        PagamentosAvulsosState(
          step: PagamentosAvulsosStep.carregado,
          orderDir: 'ASC',
          descricao: 'venda',
          provider: 'openpix',
          pagamentos: [pagamento],
        ),
      ],
      verify: (_) {
        expect(recuperarPagamentosAvulsos.chamadas.single, {
          'orderBy': 'criadoEm',
          'orderDir': 'ASC',
          'descricao': 'venda',
          'provider': 'openpix',
        });
      },
    );

    blocTest<PagamentosAvulsosBloc, PagamentosAvulsosState>(
      'deve emitir falha quando ocorrer erro ao carregar',
      setUp: () {
        recuperarPagamentosAvulsos.handler = ({
          orderBy,
          orderDir,
          descricao,
          provider,
        }) =>
            Future<List<PagamentoAvulso>>.error(Exception('erro'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(PagamentosAvulsosIniciou()),
      expect: () => [
        const PagamentosAvulsosState(
          step: PagamentosAvulsosStep.carregando,
        ),
        const PagamentosAvulsosState(
          step: PagamentosAvulsosStep.falha,
          erro: 'Falha ao carregar pagamentos avulsos.',
        ),
      ],
    );
  });

  group('PagamentosAvulsosProvidersCarregar -', () {
    blocTest<PagamentosAvulsosBloc, PagamentosAvulsosState>(
      'deve carregar providers disponiveis',
      setUp: () {
        recuperarProvidersPagamentosAvulsos.handler =
            () async => ['infinitypay', 'openpix'];
      },
      build: () => bloc,
      act: (bloc) => bloc.add(PagamentosAvulsosProvidersCarregar()),
      expect: () => [
        const PagamentosAvulsosState(
          step: PagamentosAvulsosStep.inicial,
          providers: ['infinitypay', 'openpix'],
        ),
      ],
    );
  });
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
