import 'package:comercial/domain/models/relatorio_movimentacoes.dart';
import 'package:comercial/domain/use_cases/get_relatorio_movimentacoes.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';

part 'relatorio_movimentacoes_event.dart';
part 'relatorio_movimentacoes_state.dart';

const relatorioMovimentacoesMaxDias = 93;

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class RelatorioMovimentacoesBloc
    extends Bloc<RelatorioMovimentacoesEvent, RelatorioMovimentacoesState> {
  final GetRelatorioMovimentacoes _useCase;
  final int? Function() _empresaId;

  RelatorioMovimentacoesBloc(
    this._useCase, {
    int? Function()? empresaId,
    DateTime? hoje,
  })  : _empresaId = empresaId ?? (() => sl<IAcessoGlobalSessao>().empresaIdDaSessao),
        super(_inicial(hoje ?? DateTime.now())) {
    on<RelatorioMovimentacoesIniciou>((_, emit) => _carregar(emit));
    on<RelatorioMovimentacoesRecarregou>((_, emit) => _carregar(emit));
    on<RelatorioMovimentacoesPeriodoAlterou>(
      (e, emit) => _carregar(emit, inicio: e.inicio, fim: e.fim),
    );
    on<RelatorioMovimentacoesTipoAlternou>((e, emit) {
      final t = e.tipo;
      final tipos = t == null
          ? <String>{}
          : (state.tipos.contains(t)
              ? ({...state.tipos}..remove(t))
              : {...state.tipos, t});
      return _carregar(emit, tipos: tipos);
    });
    on<RelatorioMovimentacoesBuscou>(
      (e, emit) => _carregar(emit, busca: e.busca.trim()),
    );
    on<RelatorioMovimentacoesMaisCarregou>(_onMais);
  }

  static RelatorioMovimentacoesState _inicial(DateTime hoje) {
    final fim = DateTime(hoje.year, hoje.month, hoje.day);
    return RelatorioMovimentacoesState(
      step: RelatorioMovimentacoesStep.inicial,
      inicio: fim.subtract(const Duration(days: 29)),
      fim: fim,
    );
  }

  Future<RelatorioMovimentacoes> _buscar(
    RelatorioMovimentacoesState s,
    int empresaId,
    int page,
  ) =>
      _useCase.call(
        empresaIds: [empresaId],
        dataInicial: _iso(s.inicio),
        dataFinal: _iso(s.fim),
        tipos: s.tipos.isEmpty ? null : s.tipos.toList(),
        busca: s.busca.isEmpty ? null : s.busca,
        page: page,
      );

  Future<void> _carregar(
    Emitter<RelatorioMovimentacoesState> emit, {
    DateTime? inicio,
    DateTime? fim,
    Set<String>? tipos,
    String? busca,
  }) async {
    final novo = state.copyWith(
      inicio: inicio,
      fim: fim,
      tipos: tipos,
      busca: busca,
    );
    if (novo.fim.difference(novo.inicio).inDays + 1 >
        relatorioMovimentacoesMaxDias) {
      emit(novo.copyWith(
        step: RelatorioMovimentacoesStep.falha,
        items: const [],
        erro: 'Período máximo: $relatorioMovimentacoesMaxDias dias.',
      ));
      return;
    }
    final empresaId = _empresaId();
    if (empresaId == null) return;
    emit(novo.copyWith(step: RelatorioMovimentacoesStep.carregando));
    try {
      final r = await _buscar(novo, empresaId, 1);
      emit(novo.copyWith(
        step: RelatorioMovimentacoesStep.sucesso,
        items: r.items,
        contagemPorTipo: r.contagemPorTipo,
        page: 1,
        totalPages: r.meta.totalPages,
      ));
    } catch (e, s) {
      emit(novo.copyWith(
        step: RelatorioMovimentacoesStep.falha,
        items: const [],
        erro: 'Falha ao carregar movimentações.',
      ));
      addError(e, s);
    }
  }

  Future<void> _onMais(
    RelatorioMovimentacoesMaisCarregou e,
    Emitter<RelatorioMovimentacoesState> emit,
  ) async {
    final empresaId = _empresaId();
    if (empresaId == null ||
        state.step != RelatorioMovimentacoesStep.sucesso ||
        state.carregandoMais ||
        !state.temMais) {
      return;
    }
    emit(state.copyWith(carregandoMais: true));
    try {
      final r = await _buscar(state, empresaId, state.page + 1);
      emit(state.copyWith(
        items: [...state.items, ...r.items],
        page: state.page + 1,
        totalPages: r.meta.totalPages,
        carregandoMais: false,
      ));
    } catch (err, s) {
      emit(state.copyWith(carregandoMais: false));
      addError(err, s);
    }
  }
}
