part of 'indicadores_home_bloc.dart';

class IndicadoresHomeState extends Equatable {
  final RelatorioFaturamento? faturamento;
  final ContagemPedidosPorSituacao? contagemPedidos;
  final bool carregando;

  const IndicadoresHomeState({
    this.faturamento,
    this.contagemPedidos,
    this.carregando = true,
  });

  int? get pedidosAbertos {
    final contagem = contagemPedidos;
    if (contagem == null) return null;
    return contagem.total - contagem.contar('encerrado') - contagem.contar('cancelado');
  }

  IndicadoresHomeState copyWith({
    RelatorioFaturamento? faturamento,
    ContagemPedidosPorSituacao? contagemPedidos,
    bool? carregando,
  }) {
    return IndicadoresHomeState(
      faturamento: faturamento ?? this.faturamento,
      contagemPedidos: contagemPedidos ?? this.contagemPedidos,
      carregando: carregando ?? this.carregando,
    );
  }

  @override
  List<Object?> get props => [faturamento, contagemPedidos, carregando];
}
