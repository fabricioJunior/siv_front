import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/models/relatorio_posicao_estoque.dart';
import 'package:estoque/domain/usecases/get_relatorio_posicao_estoque.dart';

part 'relatorio_posicao_estoque_event.dart';
part 'relatorio_posicao_estoque_state.dart';

class RelatorioPosicaoEstoqueBloc
    extends Bloc<RelatorioPosicaoEstoqueEvent, RelatorioPosicaoEstoqueState> {
  final GetRelatorioPosicaoEstoque _useCase;

  RelatorioPosicaoEstoqueBloc(this._useCase)
      : super(const RelatorioPosicaoEstoqueState()) {
    on<PosicaoEstoqueIniciou>((e, emit) => _carregar(emit, state),
        transformer: restartable());
    on<PosicaoEstoqueFiltrosAlterados>(
      (e, emit) => _carregar(
        emit,
        state.copyWith(
          categoriaIds: e.categoriaIds,
          corIds: e.corIds,
          tamanhoIds: e.tamanhoIds,
          alteraSituacao: true,
          situacao: e.situacao,
        ),
      ),
      transformer: restartable(),
    );
    on<PosicaoEstoqueRupturaAlternada>(
      (e, emit) => _carregar(
        emit,
        state.copyWith(
          alteraSituacao: true,
          situacao: state.ruptura ? null : 'ruptura',
        ),
      ),
      transformer: restartable(),
    );
    on<PosicaoEstoqueOrdenou>(_onOrdenou, transformer: restartable());
  }

  Future<void> _onOrdenou(
    PosicaoEstoqueOrdenou e,
    Emitter<RelatorioPosicaoEstoqueState> emit,
  ) {
    final mesma = state.ordenarPor == e.coluna;
    final ordem = mesma
        ? (state.ordem == 'asc' ? 'desc' : 'asc')
        : (e.coluna == 'categoria' ? 'asc' : 'desc');
    return _carregar(emit, state.copyWith(ordenarPor: e.coluna, ordem: ordem));
  }

  Future<void> _carregar(
    Emitter<RelatorioPosicaoEstoqueState> emit,
    RelatorioPosicaoEstoqueState base,
  ) async {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) return;
    emit(base.copyWith(step: PosicaoEstoqueStep.carregando));
    try {
      final dados = await _useCase(
        empresaIds: [empresaId],
        categoriaIds: base.categoriaIds.isEmpty ? null : base.categoriaIds,
        corIds: base.corIds.isEmpty ? null : base.corIds,
        tamanhoIds: base.tamanhoIds.isEmpty ? null : base.tamanhoIds,
        situacao: base.situacao,
        ordenarPor: base.ordenarPor,
        ordem: base.ordem,
      );
      emit(base.copyWith(step: PosicaoEstoqueStep.sucesso, dados: dados));
    } catch (e, s) {
      emit(base.copyWith(
        step: PosicaoEstoqueStep.falha,
        erro: 'Falha ao carregar posição de estoque.',
      ));
      addError(e, s);
    }
  }
}
