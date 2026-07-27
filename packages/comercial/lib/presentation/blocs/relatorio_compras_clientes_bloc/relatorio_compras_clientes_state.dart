part of 'relatorio_compras_clientes_bloc.dart';

enum RelatorioComprasClientesStep { inicial, carregando, sucesso, falha }

class RelatorioComprasClientesState {
  final RelatorioComprasClientesStep step;
  final RelatorioComprasClientes? dados;
  final String? erro;
  final String dataInicial;
  final String dataFinal;
  final String agruparPor;
  final int page;
  final int totalPages;

  const RelatorioComprasClientesState({
    required this.step,
    this.dados,
    this.erro,
    required this.dataInicial,
    required this.dataFinal,
    this.agruparPor = 'produto',
    required this.page,
    required this.totalPages,
  });

  factory RelatorioComprasClientesState.initial() {
    final (ini, fim) = _mesAtualCompras();
    return RelatorioComprasClientesState(
      step: RelatorioComprasClientesStep.inicial,
      dataInicial: ini,
      dataFinal: fim,
      page: 1,
      totalPages: 1,
    );
  }

  RelatorioComprasClientesState copyWith({
    RelatorioComprasClientesStep? step,
    RelatorioComprasClientes? dados,
    String? erro,
    String? dataInicial,
    String? dataFinal,
    String? agruparPor,
    int? page,
    int? totalPages,
  }) =>
      RelatorioComprasClientesState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        erro: erro,
        dataInicial: dataInicial ?? this.dataInicial,
        dataFinal: dataFinal ?? this.dataFinal,
        agruparPor: agruparPor ?? this.agruparPor,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
}

(String, String) _mesAtualCompras() {
  final now = DateTime.now();
  final ultimo = DateTime(now.year, now.month + 1, 0).day;
  final m = now.month.toString().padLeft(2, '0');
  return (
    '${now.year}-$m-01',
    '${now.year}-$m-${ultimo.toString().padLeft(2, '0')}',
  );
}
