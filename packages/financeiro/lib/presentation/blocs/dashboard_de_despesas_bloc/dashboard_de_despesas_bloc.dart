import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/domain/models/categoria_despesa.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_dashboard.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/use_cases.dart';

part 'dashboard_de_despesas_event.dart';
part 'dashboard_de_despesas_state.dart';

class DashboardDeDespesasBloc
    extends Bloc<DashboardDeDespesasEvent, DashboardDeDespesasState> {
  final RecuperarDashboardDeDespesas _recuperarDashboard;
  final RecuperarDespesas _recuperarDespesas;
  final RecuperarCategoriasDespesa _recuperarCategorias;
  final RecuperarOrigensPagamentoDespesa _recuperarOrigens;
  final RecuperarCalendarioDeDespesas _recuperarCalendario;

  DashboardDeDespesasBloc(
    this._recuperarDashboard,
    this._recuperarDespesas,
    this._recuperarCategorias,
    this._recuperarOrigens,
    this._recuperarCalendario,
  ) : super(const DashboardDeDespesasInitial()) {
    on<DashboardDeDespesasIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    DashboardDeDespesasIniciou event,
    Emitter<DashboardDeDespesasState> emit,
  ) async {
    try {
      emit(
        DashboardDeDespesasCarregarEmProgresso(
          ano: event.ano,
          mes: event.mes,
        ),
      );

      final mesSeguinte = event.mes == 12 ? 1 : event.mes + 1;
      final anoDoMesSeguinte = event.mes == 12 ? event.ano + 1 : event.ano;

      final resultados = await Future.wait([
        _recuperarDashboard.call(
          empresaId: event.empresaId,
          ano: event.ano,
          mes: event.mes,
        ),
        _recuperarDespesas.call(empresaId: event.empresaId),
        _recuperarCategorias.call(empresaId: event.empresaId),
        _recuperarOrigens.call(empresaId: event.empresaId),
        _recuperarCalendario.call(
          empresaId: event.empresaId,
          ano: event.ano,
          mes: event.mes,
        ),
        _recuperarCalendario.call(
          empresaId: event.empresaId,
          ano: anoDoMesSeguinte,
          mes: mesSeguinte,
        ),
      ]);

      final dashboard = resultados[0] as DespesaDashboard;
      final despesas = resultados[1] as List<Despesa>;
      final categoriaPorId = {
        for (final c in resultados[2] as List<CategoriaDespesa>)
          if (c.id != null) c.id!: c.nome,
      };
      final origemPorId = {
        for (final o in resultados[3] as List<OrigemPagamentoDespesa>)
          if (o.id != null) o.id!: o.nome,
      };
      final ocorrenciasDoMes = resultados[4] as List<DespesaOcorrenciaCalendario>;
      final ocorrenciasDoMesSeguinte =
          resultados[5] as List<DespesaOcorrenciaCalendario>;

      emit(
        DashboardDeDespesasCarregarSucesso(
          ano: event.ano,
          mes: event.mes,
          dashboard: dashboard,
          proximosVencimentos: _proximosVencimentos([
            ...ocorrenciasDoMes,
            ...ocorrenciasDoMesSeguinte,
          ]),
          pagamentosNoMesCount: ocorrenciasDoMes
              .where((o) => o.status == StatusDespesa.pago)
              .length,
          pendentesNoMesCount: ocorrenciasDoMes
              .where((o) => o.status == StatusDespesa.pendente && !o.virtual)
              .length,
          previstasRecorrentesCount: ocorrenciasDoMes
              .where((o) => o.status == StatusDespesa.pendente && o.virtual)
              .length,
          pagamentosFuturosAPartirDe: _pagamentosFuturosAPartirDe(
            despesas,
            event.ano,
            event.mes,
          ),
          parcelamentosAbertos: _parcelamentosAbertos(despesas, origemPorId),
          categoriaPorId: categoriaPorId,
          origemPorId: origemPorId,
        ),
      );
    } catch (e, s) {
      emit(DashboardDeDespesasCarregarFalha(ano: event.ano, mes: event.mes));
      addError(e, s);
    }
  }

  List<DespesaOcorrenciaCalendario> _proximosVencimentos(
    List<DespesaOcorrenciaCalendario> ocorrencias,
  ) {
    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final vencimentos = ocorrencias
        .where(
          (o) =>
              o.status == StatusDespesa.pendente &&
              !o.dataPagamento.isBefore(hojeSemHora),
        )
        .toList()
      ..sort((a, b) => a.dataPagamento.compareTo(b.dataPagamento));
    return vencimentos.take(8).toList();
  }

  // ponytail: RecuperarDespesas busca todas as despesas da empresa sem
  // paginação/janela de data -- suficiente pro volume atual, revisar se
  // ficar lento com histórico grande.
  DateTime? _pagamentosFuturosAPartirDe(
    List<Despesa> despesas,
    int ano,
    int mes,
  ) {
    final fimDoMesSelecionado = DateTime(ano, mes + 1);
    final futuros = despesas.where(
      (d) =>
          d.status == StatusDespesa.pendente &&
          d.dataPagamento != null &&
          !d.dataPagamento!.isBefore(fimDoMesSelecionado),
    );
    if (futuros.isEmpty) return null;
    return futuros
        .map((d) => d.dataPagamento!)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  List<ParcelamentoAgrupado> _parcelamentosAbertos(
    List<Despesa> despesas,
    Map<int, String> origemPorId,
  ) {
    final grupos = <String, List<Despesa>>{};
    for (final d in despesas) {
      final grupoId = d.grupoParcelamentoId;
      if (grupoId == null || d.totalParcelas == null) continue;
      grupos.putIfAbsent(grupoId, () => []).add(d);
    }

    return grupos.values
        .map((itens) {
          itens.sort(
            (a, b) => (a.numeroParcela ?? 0).compareTo(b.numeroParcela ?? 0),
          );
          final primeira = itens.first;
          final ultima = itens.last;
          final pagas = itens.where((d) => d.status == StatusDespesa.pago).length;
          return ParcelamentoAgrupado(
            descricao: primeira.descricao,
            origemNome: origemPorId[primeira.origemPagamentoId] ?? '-',
            valorParcela: primeira.valor,
            parcelasPagas: pagas,
            totalParcelas: primeira.totalParcelas!,
            terminaEm: ultima.dataPagamento,
          );
        })
        .where((p) => p.parcelasPagas < p.totalParcelas)
        .toList();
  }
}
