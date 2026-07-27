part of 'relatorio_clientes_aniversariantes_bloc.dart';

enum RelatorioClientesAniversariantesStep { inicial, carregando, sucesso, falha }

class RelatorioClientesAniversariantesState {
  final RelatorioClientesAniversariantesStep step;
  final RelatorioClientesAniversariantes? dados;
  final String? erro;
  final int mes;
  final String? dataUltimaCompraInicial;
  final String? dataUltimaCompraFinal;
  final int page;
  final int totalPages;

  const RelatorioClientesAniversariantesState({
    required this.step,
    this.dados,
    this.erro,
    required this.mes,
    this.dataUltimaCompraInicial,
    this.dataUltimaCompraFinal,
    required this.page,
    required this.totalPages,
  });

  RelatorioClientesAniversariantesState.initial({int? mes})
      : step = RelatorioClientesAniversariantesStep.inicial,
        dados = null,
        erro = null,
        mes = mes ?? DateTime.now().month,
        dataUltimaCompraInicial = null,
        dataUltimaCompraFinal = null,
        page = 1,
        totalPages = 1;

}
