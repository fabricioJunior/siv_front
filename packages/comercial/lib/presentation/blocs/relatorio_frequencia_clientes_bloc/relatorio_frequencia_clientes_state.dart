part of 'relatorio_frequencia_clientes_bloc.dart';

enum FrequenciaStatus { inicial, carregando, sucesso, vazio, erro }

enum FrequenciaPeriodo { dias90, meses6, meses12, personalizado }

const _sem = Object();

class RelatorioFrequenciaClientesState {
  final FrequenciaStatus status;
  final FrequenciaPeriodo periodo;
  final DateTime inicio;
  final DateTime fim;

  /// 'A' | 'B' | 'C' | null.
  final String? classe;
  final bool atrasados;
  final String busca;

  /// Vazio em [empresaIds] = empresa da sessão.
  final List<int> empresaIds;
  final List<int> funcionarioIds;
  final List<int> categoriaIds;
  final String ordenarPor;

  /// 'asc' | 'desc'.
  final String ordem;
  final int page;
  final int limit;

  /// clienteId das linhas/cartões expandidos.
  final Set<int> linhasAbertas;
  final RelatorioFrequenciaClientes dados;

  /// true = mobile: [items] acumula as páginas carregadas.
  final bool acumulando;

  /// Carregando a próxima página (só em [acumulando]); [status] segue sucesso.
  final bool carregandoMais;

  /// Recarregando a lista (troca de página/ordenação/filtro) com dados anteriores visíveis.
  final bool carregandoLista;
  final String? erro;

  const RelatorioFrequenciaClientesState({
    required this.inicio,
    required this.fim,
    this.status = FrequenciaStatus.inicial,
    this.periodo = FrequenciaPeriodo.meses12,
    this.classe,
    this.atrasados = false,
    this.busca = '',
    this.empresaIds = const [],
    this.funcionarioIds = const [],
    this.categoriaIds = const [],
    this.ordenarPor = 'rank',
    this.ordem = 'asc',
    this.page = 1,
    this.limit = 20,
    this.linhasAbertas = const {},
    this.dados = const RelatorioFrequenciaClientes(),
    this.acumulando = false,
    this.carregandoMais = false,
    this.carregandoLista = false,
    this.erro,
  });

  FrequenciaClientesResumo get resumo => dados.resumo;
  List<FrequenciaClienteItem> get items => dados.items;
  FrequenciaClientesMeta get meta => dados.meta;
  int get totalPages => dados.meta.totalPages;
  bool get temMais => page < totalPages;
  bool get temFiltroDeLista => classe != null || atrasados || busca.isNotEmpty;
  bool get temFiltroBase =>
      empresaIds.isNotEmpty || funcionarioIds.isNotEmpty || categoriaIds.isNotEmpty;

  RelatorioFrequenciaClientesState copyWith({
    FrequenciaStatus? status,
    FrequenciaPeriodo? periodo,
    DateTime? inicio,
    DateTime? fim,
    Object? classe = _sem,
    bool? atrasados,
    String? busca,
    List<int>? empresaIds,
    List<int>? funcionarioIds,
    List<int>? categoriaIds,
    String? ordenarPor,
    String? ordem,
    int? page,
    Set<int>? linhasAbertas,
    RelatorioFrequenciaClientes? dados,
    bool? acumulando,
    bool? carregandoMais,
    bool? carregandoLista,
    Object? erro = _sem,
  }) =>
      RelatorioFrequenciaClientesState(
        status: status ?? this.status,
        periodo: periodo ?? this.periodo,
        inicio: inicio ?? this.inicio,
        fim: fim ?? this.fim,
        classe: identical(classe, _sem) ? this.classe : classe as String?,
        atrasados: atrasados ?? this.atrasados,
        busca: busca ?? this.busca,
        empresaIds: empresaIds ?? this.empresaIds,
        funcionarioIds: funcionarioIds ?? this.funcionarioIds,
        categoriaIds: categoriaIds ?? this.categoriaIds,
        ordenarPor: ordenarPor ?? this.ordenarPor,
        ordem: ordem ?? this.ordem,
        page: page ?? this.page,
        limit: limit,
        linhasAbertas: linhasAbertas ?? this.linhasAbertas,
        dados: dados ?? this.dados,
        acumulando: acumulando ?? this.acumulando,
        carregandoMais: carregandoMais ?? this.carregandoMais,
        carregandoLista: carregandoLista ?? this.carregandoLista,
        erro: identical(erro, _sem) ? this.erro : erro as String?,
      );
}
