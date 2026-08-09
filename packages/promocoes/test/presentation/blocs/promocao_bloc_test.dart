import 'package:core/bloc_test.dart';
import 'package:financeiro/domain/data/repositories/i_formas_de_pagamento_repository.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/domain/data/repositories/i_promocoes_repository.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';
import 'package:promocoes/use_cases.dart';

class StubPromocoesRepository implements IPromocoesRepository {
  final Future<Promocao?> Function(int id)? onRecuperarPromocao;
  final Future<Promocao> Function(Promocao promocao)? onCriar;
  final Future<Promocao> Function(Promocao promocao)? onAtualizar;
  Promocao? ultimaPromocaoEnviada;

  StubPromocoesRepository({this.onRecuperarPromocao, this.onCriar, this.onAtualizar});

  @override
  Future<List<Promocao>> recuperarPromocoes({
    String? nome,
    bool? ativa,
    bool? vigente,
  }) async =>
      const [];

  @override
  Future<Promocao?> recuperarPromocao(int id) =>
      onRecuperarPromocao?.call(id) ?? Future.value(null);

  @override
  Future<Promocao> criarPromocao(Promocao promocao) {
    ultimaPromocaoEnviada = promocao;
    return onCriar?.call(promocao) ?? Future.value(promocao);
  }

  @override
  Future<Promocao> atualizarPromocao(Promocao promocao) {
    ultimaPromocaoEnviada = promocao;
    return onAtualizar?.call(promocao) ?? Future.value(promocao);
  }
}

class StubFormasDePagamentoRepository implements IFormasDePagamentoRepository {
  final List<FormaDePagamento> formas;

  StubFormasDePagamentoRepository({this.formas = const []});

  @override
  Future<List<FormaDePagamento>> recuperarFormasDePagamento({
    String? filtro,
  }) async =>
      formas;

  @override
  Future<FormaDePagamento?> recuperarFormaDePagamento(int id) async => null;

  @override
  Future<FormaDePagamento> criarFormaDePagamento(FormaDePagamento forma) =>
      throw UnimplementedError();

  @override
  Future<FormaDePagamento> atualizarFormaDePagamento(FormaDePagamento forma) =>
      throw UnimplementedError();
}

void main() {
  final formaPix = FormaDePagamento.create(
    id: 1,
    descricao: 'Pix',
    inicio: 0,
    parcelas: 1,
    tipo: 'a_vista',
    inativa: false,
  );

  PromocaoBloc criarBloc({
    StubPromocoesRepository? promocoesRepository,
    StubFormasDePagamentoRepository? formasDePagamentoRepository,
  }) {
    final promocoesRepo = promocoesRepository ?? StubPromocoesRepository();
    final formasRepo =
        formasDePagamentoRepository ?? StubFormasDePagamentoRepository();

    return PromocaoBloc(
      RecuperarPromocao(repository: promocoesRepo),
      CriarPromocao(repository: promocoesRepo),
      AtualizarPromocao(repository: promocoesRepo),
      RecuperarFormasDePagamento(repository: formasRepo),
    );
  }

  blocTest<PromocaoBloc, PromocaoState>(
    'carrega as formas de pagamento disponíveis ao iniciar',
    build: () => criarBloc(
      formasDePagamentoRepository:
          StubFormasDePagamentoRepository(formas: [formaPix]),
    ),
    act: (bloc) => bloc.add(PromocaoIniciou()),
    expect: () => [
      isA<PromocaoState>().having(
        (s) => s.step,
        'step',
        PromocaoStep.carregando,
      ),
      isA<PromocaoState>()
          .having((s) => s.step, 'step', PromocaoStep.editando)
          .having(
            (s) => s.formasDePagamentoDisponiveis,
            'formasDePagamentoDisponiveis',
            [formaPix],
          ),
    ],
  );

  blocTest<PromocaoBloc, PromocaoState>(
    'bloqueia salvar quando restringirFormasPagamento=true sem nenhuma forma selecionada',
    build: () => criarBloc(),
    act: (bloc) async {
      bloc.add(PromocaoIniciou());
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        PromocaoCampoAlterado(
          nome: 'Promo pix',
          dataInicio: DateTime(2026, 1, 1),
          dataFim: DateTime(2026, 1, 31),
          tipoDesconto: TipoDesconto.percentual,
          valorPercentual: 10,
          restringirFormasPagamento: true,
        ),
      );
      bloc.add(PromocaoSalvou());
    },
    skip: 3,
    expect: () => [
      isA<PromocaoState>().having(
        (s) => s.step,
        'step',
        PromocaoStep.validacaoInvalida,
      ),
    ],
  );

  blocTest<PromocaoBloc, PromocaoState>(
    'bloqueia salvar quando limiteUsosPorCliente é informado sem periodoLimiteCliente',
    build: () => criarBloc(),
    act: (bloc) async {
      bloc.add(PromocaoIniciou());
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        PromocaoCampoAlterado(
          nome: 'Promo aniversário',
          dataInicio: DateTime(2026, 1, 1),
          dataFim: DateTime(2026, 1, 31),
          tipoDesconto: TipoDesconto.percentual,
          valorPercentual: 10,
          limiteUsosPorCliente: 1,
        ),
      );
      bloc.add(PromocaoSalvou());
    },
    skip: 3,
    expect: () => [
      isA<PromocaoState>().having(
        (s) => s.step,
        'step',
        PromocaoStep.validacaoInvalida,
      ),
    ],
  );

  blocTest<PromocaoBloc, PromocaoState>(
    'envia restringirFormasPagamento e formasPagamento no payload de criação',
    build: () => criarBloc(
      promocoesRepository: StubPromocoesRepository(),
    ),
    act: (bloc) async {
      bloc.add(PromocaoIniciou());
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        PromocaoCampoAlterado(
          nome: 'Promo pix',
          dataInicio: DateTime(2026, 1, 1),
          dataFim: DateTime(2026, 1, 31),
          tipoDesconto: TipoDesconto.percentual,
          valorPercentual: 10,
          restringirFormasPagamento: true,
          formasPagamento: const [
            PromocaoFormaPagamento(formaDePagamentoId: 1, valorPercentual: 15),
          ],
        ),
      );
      bloc.add(PromocaoSalvou());
    },
    verify: (bloc) {
      expect(bloc.state.step, PromocaoStep.criado);
      expect(bloc.state.restringirFormasPagamento, isTrue);
      expect(
        bloc.state.formasPagamento,
        const [PromocaoFormaPagamento(formaDePagamentoId: 1, valorPercentual: 15)],
      );
    },
  );
}
