import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/domain/use_cases/get_relatorio_frequencia_clientes.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';

part 'relatorio_frequencia_clientes_event.dart';
part 'relatorio_frequencia_clientes_state.dart';

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _mesesAtras(DateTime d, int m) {
  final total = d.year * 12 + d.month - 1 - m;
  final ano = total ~/ 12;
  final mes = total % 12 + 1;
  final ultimo = DateTime(ano, mes + 1, 0).day;
  return DateTime(ano, mes, d.day > ultimo ? ultimo : d.day);
}

const _ascNoPrimeiroClique = {
  'rank',
  'nome',
  'classe',
  'ultimaCompra',
  'intervalo',
  'percentualAcumulado',
};

class RelatorioFrequenciaClientesBloc
    extends Bloc<RelatorioFrequenciaClientesEvent, RelatorioFrequenciaClientesState> {
  static const maxMesesPersonalizado = 24;

  final GetRelatorioFrequenciaClientes _useCase;
  final int? Function() _empresaId;
  final DateTime Function() _hoje;
  int _seq = 0;

  RelatorioFrequenciaClientesBloc(
    this._useCase, {
    int? Function()? empresaId,
    DateTime Function()? hoje,
  })  : _empresaId = empresaId ?? (() => sl<IAcessoGlobalSessao>().empresaIdDaSessao),
        _hoje = hoje ?? DateTime.now,
        super(_inicial((hoje ?? DateTime.now)())) {
    on<FrequenciaIniciou>(
      (e, emit) => _carregar(emit, state.copyWith(acumulando: e.acumulando)),
    );
    on<FrequenciaMudouModo>((e, emit) async {
      if (e.acumulando == state.acumulando) return;
      final novo = state.copyWith(acumulando: e.acumulando, page: 1);
      if (state.status == FrequenciaStatus.inicial) return emit(novo);
      await _carregar(emit, novo);
    });
    on<FrequenciaMudouPeriodo>(_onPeriodo);
    on<FrequenciaMudouFiltrosBase>(
      (e, emit) => _carregar(
        emit,
        state.copyWith(
          empresaIds: e.empresaIds,
          funcionarioIds: e.funcionarioIds,
          categoriaIds: e.categoriaIds,
          page: 1,
          linhasAbertas: const {},
        ),
      ),
    );
    on<FrequenciaMudouClasse>(
      (e, emit) => _carregar(
        emit,
        state.copyWith(classe: state.classe == e.classe ? null : e.classe, page: 1),
      ),
    );
    on<FrequenciaAlternouAtrasados>(
      (_, emit) =>
          _carregar(emit, state.copyWith(atrasados: !state.atrasados, page: 1)),
    );
    on<FrequenciaMudouBusca>((e, emit) {
      final b = e.busca.trim();
      if (b == state.busca) return Future.value();
      return _carregar(emit, state.copyWith(busca: b, page: 1));
    });
    on<FrequenciaMudouOrdenacao>((e, emit) {
      final mesma = e.coluna == state.ordenarPor;
      final ordem = mesma
          ? (state.ordem == 'asc' ? 'desc' : 'asc')
          : (_ascNoPrimeiroClique.contains(e.coluna) ? 'asc' : 'desc');
      return _carregar(
        emit,
        state.copyWith(ordenarPor: e.coluna, ordem: ordem, page: 1),
      );
    });
    on<FrequenciaMudouPagina>((e, emit) {
      if (e.page < 1 || e.page == state.page) return Future.value();
      return _carregar(emit, state.copyWith(page: e.page));
    });
    on<FrequenciaCarregouMais>(_onMais);
    on<FrequenciaAlternouLinha>((e, emit) {
      final a = {...state.linhasAbertas};
      if (!a.remove(e.clienteId)) a.add(e.clienteId);
      emit(state.copyWith(linhasAbertas: a));
    });
    on<FrequenciaLimpouFiltros>(
      (_, emit) => _carregar(
        emit,
        state.copyWith(
          classe: null,
          atrasados: false,
          busca: '',
          empresaIds: const [],
          funcionarioIds: const [],
          categoriaIds: const [],
          page: 1,
          linhasAbertas: const {},
        ),
      ),
    );
    on<FrequenciaTentouDeNovo>((_, emit) => _carregar(emit, state));
  }

  static RelatorioFrequenciaClientesState _inicial(DateTime hoje) {
    final fim = DateTime(hoje.year, hoje.month, hoje.day);
    return RelatorioFrequenciaClientesState(inicio: _mesesAtras(fim, 12), fim: fim);
  }

  /// Personalizado: no máximo 24 meses e início <= fim.
  static bool periodoValido(DateTime inicio, DateTime fim) =>
      !inicio.isAfter(fim) && !_mesesAtras(fim, maxMesesPersonalizado).isAfter(inicio);

  Future<void> _onPeriodo(
    FrequenciaMudouPeriodo e,
    Emitter<RelatorioFrequenciaClientesState> emit,
  ) {
    final h = _hoje();
    final fimHoje = DateTime(h.year, h.month, h.day);
    final DateTime inicio;
    final DateTime fim;
    switch (e.periodo) {
      case FrequenciaPeriodo.dias90:
        fim = fimHoje;
        inicio = fim.subtract(const Duration(days: 90));
      case FrequenciaPeriodo.meses6:
        fim = fimHoje;
        inicio = _mesesAtras(fim, 6);
      case FrequenciaPeriodo.meses12:
        fim = fimHoje;
        inicio = _mesesAtras(fim, 12);
      case FrequenciaPeriodo.personalizado:
        if (e.inicio == null || e.fim == null || !periodoValido(e.inicio!, e.fim!)) {
          return Future.value();
        }
        inicio = DateTime(e.inicio!.year, e.inicio!.month, e.inicio!.day);
        fim = DateTime(e.fim!.year, e.fim!.month, e.fim!.day);
    }
    return _carregar(
      emit,
      state.copyWith(
        periodo: e.periodo,
        inicio: inicio,
        fim: fim,
        page: 1,
        linhasAbertas: const {},
      ),
    );
  }

  Future<RelatorioFrequenciaClientes> _buscar(
    RelatorioFrequenciaClientesState s,
    List<int> empresas,
    int page,
  ) =>
      _useCase.call(
        empresaIds: empresas,
        dataInicial: _iso(s.inicio),
        dataFinal: _iso(s.fim),
        funcionarioIds: s.funcionarioIds.isEmpty ? null : s.funcionarioIds,
        categoriaIds: s.categoriaIds.isEmpty ? null : s.categoriaIds,
        classe: s.classe,
        atrasados: s.atrasados,
        busca: s.busca.isEmpty ? null : s.busca,
        ordenarPor: s.ordenarPor,
        ordem: s.ordem,
        page: page,
        limit: s.limit,
      );

  List<int>? _empresas(RelatorioFrequenciaClientesState s) {
    if (s.empresaIds.isNotEmpty) return s.empresaIds;
    final id = _empresaId();
    return id == null ? null : [id];
  }

  /// Carrega a página [novo.page] com os filtros de [novo]. Com dados
  /// anteriores, mantém a tela e só marca [carregandoLista].
  Future<void> _carregar(
    Emitter<RelatorioFrequenciaClientesState> emit,
    RelatorioFrequenciaClientesState novo,
  ) async {
    final empresas = _empresas(novo);
    if (empresas == null) {
      emit(novo.copyWith(status: FrequenciaStatus.erro, erro: 'Empresa não definida.'));
      return;
    }
    final seq = ++_seq;
    final tinha = state.status == FrequenciaStatus.sucesso ||
        state.status == FrequenciaStatus.vazio;
    emit(
      tinha
          ? novo.copyWith(carregandoLista: true, carregandoMais: false, erro: null)
          : novo.copyWith(status: FrequenciaStatus.carregando, erro: null),
    );
    try {
      final r = await _buscar(novo, empresas, novo.page);
      if (seq != _seq) return;
      emit(
        novo.copyWith(
          status: r.resumo.clientes == 0 ? FrequenciaStatus.vazio : FrequenciaStatus.sucesso,
          dados: r,
          carregandoLista: false,
          carregandoMais: false,
          erro: null,
        ),
      );
    } catch (err, s) {
      if (seq != _seq) return;
      emit(
        novo.copyWith(
          status: FrequenciaStatus.erro,
          carregandoLista: false,
          erro: 'Falha ao carregar a frequência de clientes.',
        ),
      );
      addError(err, s);
    }
  }

  Future<void> _onMais(
    FrequenciaCarregouMais e,
    Emitter<RelatorioFrequenciaClientesState> emit,
  ) async {
    final empresas = _empresas(state);
    if (empresas == null ||
        !state.acumulando ||
        state.status != FrequenciaStatus.sucesso ||
        state.carregandoMais ||
        state.carregandoLista ||
        !state.temMais) {
      return;
    }
    final seq = ++_seq;
    final base = state;
    emit(base.copyWith(carregandoMais: true));
    try {
      final r = await _buscar(base, empresas, base.page + 1);
      if (seq != _seq) return;
      emit(
        base.copyWith(
          page: base.page + 1,
          carregandoMais: false,
          dados: RelatorioFrequenciaClientes(
            resumo: r.resumo,
            items: [...base.items, ...r.items],
            meta: r.meta,
          ),
        ),
      );
    } catch (err, s) {
      if (seq != _seq) return;
      emit(base.copyWith(carregandoMais: false));
      addError(err, s);
    }
  }
}
