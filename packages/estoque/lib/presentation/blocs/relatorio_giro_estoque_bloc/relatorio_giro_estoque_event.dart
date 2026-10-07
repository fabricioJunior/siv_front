part of 'relatorio_giro_estoque_bloc.dart';

abstract class RelatorioGiroEstoqueEvent {}

class GiroEstoqueIniciou extends RelatorioGiroEstoqueEvent {}

class GiroPeriodoAlterado extends RelatorioGiroEstoqueEvent {
  final PeriodoGiro periodo;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  GiroPeriodoAlterado(this.periodo, {this.dataInicio, this.dataFim});
}

/// Substitui o filtro inteiro (busca, categoria, fornecedor, preço...).
class GiroFiltroAlterado extends RelatorioGiroEstoqueEvent {
  final FiltroGiroEstoque filtro;
  GiroFiltroAlterado(this.filtro);
}

/// Faixa tocada no painel; tocar de novo na mesma faixa limpa.
class GiroClassificacaoSelecionada extends RelatorioGiroEstoqueEvent {
  final ClassificacaoGiro classificacao;
  GiroClassificacaoSelecionada(this.classificacao);
}

/// Remove o filtro de classificação (chip).
class GiroClassificacaoLimpa extends RelatorioGiroEstoqueEvent {}

class GiroAbaAlterada extends RelatorioGiroEstoqueEvent {
  final AbaGiro aba;
  GiroAbaAlterada(this.aba);
}

class GiroVisaoAlterada extends RelatorioGiroEstoqueEvent {
  final String visualizacao;
  GiroVisaoAlterada(this.visualizacao);
}

/// Clique no cabeçalho: [coluna] é o valor de `ordenarPor`.
class GiroOrdenacaoAlterada extends RelatorioGiroEstoqueEvent {
  final String coluna;
  GiroOrdenacaoAlterada(this.coluna);
}

class GiroPaginaAlterada extends RelatorioGiroEstoqueEvent {
  final int page;
  GiroPaginaAlterada(this.page);
}

class GiroLinhaExpandida extends RelatorioGiroEstoqueEvent {
  final int referenciaId;
  GiroLinhaExpandida(this.referenciaId);
}

class GiroCriteriosAlternados extends RelatorioGiroEstoqueEvent {}

enum FormatoExportacaoGiro { csv, pdf }

class GiroExportarSolicitado extends RelatorioGiroEstoqueEvent {
  final FormatoExportacaoGiro formato;
  GiroExportarSolicitado(this.formato);
}
