import 'package:core/bloc_test.dart';
import 'package:financeiro/domain/data/repositories/i_categorias_despesa_repository.dart';
import 'package:financeiro/domain/data/repositories/i_despesas_calendario_repository.dart';
import 'package:financeiro/domain/data/repositories/i_despesas_repository.dart';
import 'package:financeiro/domain/data/repositories/i_origens_pagamento_despesa_repository.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/domain/models/pagamento_de_fatura.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

// Ocorrência virtual (recorrente ainda não materializada nesse mês) só existe
// com id do template -- editar/pagar/cancelar precisa passar pelo endpoint de
// ocorrências (materializa). Ocorrência concreta (despesa avulsa/parcela/já
// materializada) tem que ir por PUT /despesas/{id} -- o endpoint de
// ocorrências rejeita qualquer id que não seja de um template recorrente.
class _FakeCalendarioRepository implements IDespesasCalendarioRepository {
  ({int id, double? valor, DateTime? dataPagamento, StatusDespesa? status})? chamadaOcorrencia;

  @override
  Future<List<DespesaOcorrenciaCalendario>> recuperarCalendario({
    required int empresaId,
    required int ano,
    required int mes,
  }) async =>
      [];

  @override
  Future<void> registrarOcorrencia(
    int id, {
    required int ano,
    required int mes,
    double? valor,
    DateTime? dataPagamento,
    StatusDespesa? status,
  }) async {
    chamadaOcorrencia = (id: id, valor: valor, dataPagamento: dataPagamento, status: status);
  }
}

class _FakeDespesasRepository implements IDespesasRepository {
  ({int id, double? valor, int? categoriaId, int? origemPagamentoId, StatusDespesa? status})? chamadaAtualizar;

  @override
  Future<Despesa> criarDespesa(Despesa despesa) async => despesa;

  @override
  Future<PagamentoDeFatura> pagarFatura({required int origemPagamentoId, required int ano, required int mes}) async =>
      const PagamentoDeFatura(atualizadas: 0, valorTotal: 0);

  @override
  Future<Despesa> atualizarDespesa(
    int id, {
    double? valor,
    int? categoriaId,
    int? origemPagamentoId,
    DateTime? dataPagamento,
    StatusDespesa? status,
  }) async {
    chamadaAtualizar = (id: id, valor: valor, categoriaId: categoriaId, origemPagamentoId: origemPagamentoId, status: status);
    return Despesa(descricao: '', valor: valor ?? 0, categoriaId: categoriaId ?? 0, origemPagamentoId: origemPagamentoId ?? 0);
  }

  @override
  Future<List<Despesa>> recuperarDespesas({
    required int empresaId,
    int? categoriaId,
    StatusDespesa? status,
    DateTime? dataInicial,
    DateTime? dataFinal,
    bool? recorrente,
    String? grupoParcelamentoId,
  }) async =>
      [];
}

class _FakeCategoriasRepository implements ICategoriasDespesaRepository {
  @override
  Future<List<CategoriaDespesa>> recuperarCategorias({required int empresaId, String? filtro}) async => [];
  @override
  Future<CategoriaDespesa?> recuperarCategoria(int id) async => null;
  @override
  Future<CategoriaDespesa> criarCategoria(CategoriaDespesa categoria) async => categoria;
  @override
  Future<CategoriaDespesa> atualizarCategoria(CategoriaDespesa categoria) async => categoria;
}

class _FakeOrigensRepository implements IOrigensPagamentoDespesaRepository {
  @override
  Future<List<OrigemPagamentoDespesa>> recuperarOrigens({required int empresaId, String? filtro}) async => [];
  @override
  Future<OrigemPagamentoDespesa?> recuperarOrigem(int id) async => null;
  @override
  Future<OrigemPagamentoDespesa> criarOrigem(OrigemPagamentoDespesa origem) async => origem;
  @override
  Future<OrigemPagamentoDespesa> atualizarOrigem(OrigemPagamentoDespesa origem) async => origem;
}

void main() {
  late _FakeCalendarioRepository calendarioRepo;
  late _FakeDespesasRepository despesasRepo;

  CalendarioDeDespesasBloc build() {
    calendarioRepo = _FakeCalendarioRepository();
    despesasRepo = _FakeDespesasRepository();
    return CalendarioDeDespesasBloc(
      RecuperarCalendarioDeDespesas(repository: calendarioRepo),
      RegistrarOcorrenciaDeDespesa(repository: calendarioRepo),
      AtualizarDespesa(repository: despesasRepo),
      RecuperarCategoriasDespesa(repository: _FakeCategoriasRepository()),
      RecuperarOrigensPagamentoDespesa(repository: _FakeOrigensRepository()),
    );
  }

  blocTest<CalendarioDeDespesasBloc, CalendarioDeDespesasState>(
    'ocorrência virtual (recorrente não materializada) usa o endpoint de ocorrências',
    build: build,
    act: (bloc) async {
      bloc.add(CalendarioDeDespesasIniciou(empresaId: 1));
      await Future<void>.delayed(Duration.zero);
      bloc.add(CalendarioDeDespesasOcorrenciaRegistrada(id: 10, virtual: true, status: StatusDespesa.pago));
    },
    wait: const Duration(milliseconds: 10),
    verify: (_) {
      expect(calendarioRepo.chamadaOcorrencia?.id, 10);
      expect(despesasRepo.chamadaAtualizar, isNull);
    },
  );

  blocTest<CalendarioDeDespesasBloc, CalendarioDeDespesasState>(
    'ocorrência concreta (avulsa/parcela/já materializada) usa PUT /despesas/{id}, não o endpoint de ocorrências',
    build: build,
    act: (bloc) async {
      bloc.add(CalendarioDeDespesasIniciou(empresaId: 1));
      await Future<void>.delayed(Duration.zero);
      bloc.add(CalendarioDeDespesasOcorrenciaRegistrada(
        id: 20,
        virtual: false,
        categoriaId: 3,
        origemPagamentoId: 4,
        status: StatusDespesa.pago,
      ));
    },
    wait: const Duration(milliseconds: 10),
    verify: (_) {
      expect(despesasRepo.chamadaAtualizar?.id, 20);
      expect(despesasRepo.chamadaAtualizar?.categoriaId, 3);
      expect(despesasRepo.chamadaAtualizar?.origemPagamentoId, 4);
      expect(calendarioRepo.chamadaOcorrencia, isNull);
    },
  );
}
