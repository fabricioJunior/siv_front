part of 'relatorio_frequencia_clientes_bloc.dart';

/// Eventos do bloc da Frequência de clientes. Toda mudança que altera a
/// consulta recarrega a página 1 (exceto [FrequenciaMudouPagina]).
sealed class RelatorioFrequenciaClientesEvent {
  const RelatorioFrequenciaClientesEvent();
}

/// Primeira carga. [acumulando]=true no mobile (paginação infinita).
class FrequenciaIniciou extends RelatorioFrequenciaClientesEvent {
  final bool acumulando;
  const FrequenciaIniciou({this.acumulando = false});
}

/// Troca o modo (desktop paginado x mobile acumulado); recarrega a página 1 se mudou.
class FrequenciaMudouModo extends RelatorioFrequenciaClientesEvent {
  final bool acumulando;
  const FrequenciaMudouModo(this.acumulando);
}

/// [inicio]/[fim] só valem em [FrequenciaPeriodo.personalizado] (máx. 24 meses; senão ignora).
/// Reseta página e fecha linhas.
class FrequenciaMudouPeriodo extends RelatorioFrequenciaClientesEvent {
  final FrequenciaPeriodo periodo;
  final DateTime? inicio;
  final DateTime? fim;
  const FrequenciaMudouPeriodo(this.periodo, {this.inicio, this.fim});
}

/// Loja/vendedor/categoria. null mantém o valor atual. Reseta página e fecha linhas.
class FrequenciaMudouFiltrosBase extends RelatorioFrequenciaClientesEvent {
  final List<int>? empresaIds;
  final List<int>? funcionarioIds;
  final List<int>? categoriaIds;
  const FrequenciaMudouFiltrosBase({
    this.empresaIds,
    this.funcionarioIds,
    this.categoriaIds,
  });
}

/// Toggle: mesma classe de novo limpa. Combina com atrasados.
class FrequenciaMudouClasse extends RelatorioFrequenciaClientesEvent {
  final String classe;
  const FrequenciaMudouClasse(this.classe);
}

class FrequenciaAlternouAtrasados extends RelatorioFrequenciaClientesEvent {
  const FrequenciaAlternouAtrasados();
}

/// O debounce de 400ms fica na UI.
class FrequenciaMudouBusca extends RelatorioFrequenciaClientesEvent {
  final String busca;
  const FrequenciaMudouBusca(this.busca);
}

/// [coluna] = valor de `ordenarPor` (rank, nome, classe, visitas, ultimaCompra,
/// intervalo, valor, ticketMedio, percentualAcumulado). 1º clique asc em
/// rank/nome/classe/ultimaCompra/intervalo/percentualAcumulado e desc nas demais; 2º inverte.
class FrequenciaMudouOrdenacao extends RelatorioFrequenciaClientesEvent {
  final String coluna;
  const FrequenciaMudouOrdenacao(this.coluna);
}

/// Modo paginado (desktop): substitui os itens.
class FrequenciaMudouPagina extends RelatorioFrequenciaClientesEvent {
  final int page;
  const FrequenciaMudouPagina(this.page);
}

/// Modo acumulado (mobile): anexa a próxima página.
class FrequenciaCarregouMais extends RelatorioFrequenciaClientesEvent {
  const FrequenciaCarregouMais();
}

class FrequenciaAlternouLinha extends RelatorioFrequenciaClientesEvent {
  final int clienteId;
  const FrequenciaAlternouLinha(this.clienteId);
}

/// Limpa classe, atrasados, busca e filtros de base (empresa volta à da sessão).
class FrequenciaLimpouFiltros extends RelatorioFrequenciaClientesEvent {
  const FrequenciaLimpouFiltros();
}

class FrequenciaTentouDeNovo extends RelatorioFrequenciaClientesEvent {
  const FrequenciaTentouDeNovo();
}
