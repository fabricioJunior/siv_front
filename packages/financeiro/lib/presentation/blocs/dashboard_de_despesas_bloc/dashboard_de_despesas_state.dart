part of 'dashboard_de_despesas_bloc.dart';

class ParcelamentoAgrupado extends Equatable {
  final String descricao;
  final String origemNome;
  final double valorParcela;
  final int parcelasPagas;
  final int totalParcelas;
  final DateTime? terminaEm;

  const ParcelamentoAgrupado({
    required this.descricao,
    required this.origemNome,
    required this.valorParcela,
    required this.parcelasPagas,
    required this.totalParcelas,
    this.terminaEm,
  });

  @override
  List<Object?> get props => [
        descricao,
        origemNome,
        valorParcela,
        parcelasPagas,
        totalParcelas,
        terminaEm,
      ];
}

abstract class DashboardDeDespesasState extends Equatable {
  final int ano;
  final int mes;
  final DespesaDashboard? dashboard;

  const DashboardDeDespesasState({
    required this.ano,
    required this.mes,
    this.dashboard,
  });

  @override
  List<Object?> get props => [ano, mes, dashboard];
}

class DashboardDeDespesasInitial extends DashboardDeDespesasState {
  const DashboardDeDespesasInitial() : super(ano: 0, mes: 0);
}

class DashboardDeDespesasCarregarEmProgresso extends DashboardDeDespesasState {
  const DashboardDeDespesasCarregarEmProgresso({
    required super.ano,
    required super.mes,
  });
}

class DashboardDeDespesasCarregarSucesso extends DashboardDeDespesasState {
  final List<DespesaOcorrenciaCalendario> proximosVencimentos;
  final List<ParcelamentoAgrupado> parcelamentosAbertos;
  final Map<int, String> categoriaPorId;
  final Map<int, String> origemPorId;
  final int pagamentosNoMesCount;
  final int pendentesNoMesCount;
  final int previstasRecorrentesCount;
  final DateTime? pagamentosFuturosAPartirDe;

  const DashboardDeDespesasCarregarSucesso({
    required super.ano,
    required super.mes,
    required DespesaDashboard super.dashboard,
    this.proximosVencimentos = const [],
    this.parcelamentosAbertos = const [],
    this.categoriaPorId = const {},
    this.origemPorId = const {},
    this.pagamentosNoMesCount = 0,
    this.pendentesNoMesCount = 0,
    this.previstasRecorrentesCount = 0,
    this.pagamentosFuturosAPartirDe,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        proximosVencimentos,
        parcelamentosAbertos,
        categoriaPorId,
        origemPorId,
        pagamentosNoMesCount,
        pendentesNoMesCount,
        previstasRecorrentesCount,
        pagamentosFuturosAPartirDe,
      ];
}

class DashboardDeDespesasCarregarFalha extends DashboardDeDespesasState {
  const DashboardDeDespesasCarregarFalha({
    required super.ano,
    required super.mes,
  });
}
