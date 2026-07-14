import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:estoque/domain/models/filtro_historico_estoque.dart';
import 'package:estoque/domain/models/historico_estoque.dart';
import 'package:estoque/domain/usecases/recuperar_historico_de_estoque.dart';

part 'historico_estoque_event.dart';
part 'historico_estoque_state.dart';

class HistoricoEstoqueBloc
    extends Bloc<HistoricoEstoqueEvent, HistoricoEstoqueState> {
  final RecuperarHistoricoDeEstoque _recuperarHistoricoDeEstoque;

  HistoricoEstoqueBloc(this._recuperarHistoricoDeEstoque)
    : super(const HistoricoEstoqueState()) {
    on<HistoricoEstoqueIniciou>(_onIniciou);
    on<HistoricoEstoqueCarregarMaisSolicitado>(_onCarregarMaisSolicitado);
  }

  Future<void> _onIniciou(
    HistoricoEstoqueIniciou event,
    Emitter<HistoricoEstoqueState> emit,
  ) async {
    final filtro = event.filtro.copyWith(page: 1);

    emit(
      state.copyWith(
        step: HistoricoEstoqueStep.carregando,
        itens: const [],
        filtro: filtro,
        erro: null,
      ),
    );

    try {
      final pagina = await _recuperarHistoricoDeEstoque.call(filtro: filtro);
      emit(
        state.copyWith(
          step: HistoricoEstoqueStep.carregado,
          itens: pagina.items,
          filtro: filtro,
          totalPages: pagina.meta.totalPages,
          totalItems: pagina.meta.totalItems,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: HistoricoEstoqueStep.falha,
          erro: mensagemDeErroApi(e, 'Erro ao carregar histórico de estoque.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onCarregarMaisSolicitado(
    HistoricoEstoqueCarregarMaisSolicitado event,
    Emitter<HistoricoEstoqueState> emit,
  ) async {
    if (state.step == HistoricoEstoqueStep.carregandoMais) return;
    if (!state.temMaisPaginas) return;

    final proximaPagina = state.filtro.page + 1;
    final filtro = state.filtro.copyWith(page: proximaPagina);

    emit(state.copyWith(step: HistoricoEstoqueStep.carregandoMais, erro: null));

    try {
      final pagina = await _recuperarHistoricoDeEstoque.call(filtro: filtro);
      emit(
        state.copyWith(
          step: HistoricoEstoqueStep.carregado,
          itens: [...state.itens, ...pagina.items],
          filtro: filtro,
          totalPages: pagina.meta.totalPages,
          totalItems: pagina.meta.totalItems,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: HistoricoEstoqueStep.carregado,
          erro: mensagemDeErroApi(
            e,
            'Erro ao carregar próxima página do histórico.',
          ),
        ),
      );
      addError(e, s);
    }
  }
}
