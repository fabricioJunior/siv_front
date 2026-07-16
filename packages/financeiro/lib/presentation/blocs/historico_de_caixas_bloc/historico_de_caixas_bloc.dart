import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/domain/models/caixa_do_historico.dart';
import 'package:financeiro/domain/models/filtro_historico_de_caixas.dart';
import 'package:financeiro/domain/use_cases/recuperar_historico_de_caixas.dart';

part 'historico_de_caixas_event.dart';
part 'historico_de_caixas_state.dart';

class HistoricoDeCaixasBloc
    extends Bloc<HistoricoDeCaixasEvent, HistoricoDeCaixasState> {
  final RecuperarHistoricoDeCaixas _recuperarHistoricoDeCaixas;

  HistoricoDeCaixasBloc(this._recuperarHistoricoDeCaixas)
    : super(const HistoricoDeCaixasState()) {
    on<HistoricoDeCaixasIniciou>(_onIniciou);
    on<HistoricoDeCaixasCarregarMaisSolicitado>(_onCarregarMaisSolicitado);
  }

  Future<void> _onIniciou(
    HistoricoDeCaixasIniciou event,
    Emitter<HistoricoDeCaixasState> emit,
  ) async {
    final filtro = event.filtro.copyWith(page: 1);

    emit(
      state.copyWith(
        step: HistoricoDeCaixasStep.carregando,
        itens: const [],
        filtro: filtro,
        erro: null,
      ),
    );

    try {
      final pagina = await _recuperarHistoricoDeCaixas.call(filtro: filtro);
      emit(
        state.copyWith(
          step: HistoricoDeCaixasStep.carregado,
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
          step: HistoricoDeCaixasStep.falha,
          erro: mensagemDeErroApi(e, 'Erro ao carregar histórico de caixas.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onCarregarMaisSolicitado(
    HistoricoDeCaixasCarregarMaisSolicitado event,
    Emitter<HistoricoDeCaixasState> emit,
  ) async {
    if (state.step == HistoricoDeCaixasStep.carregandoMais) return;
    if (!state.temMaisPaginas) return;

    final proximaPagina = state.filtro.page + 1;
    final filtro = state.filtro.copyWith(page: proximaPagina);

    emit(
      state.copyWith(step: HistoricoDeCaixasStep.carregandoMais, erro: null),
    );

    try {
      final pagina = await _recuperarHistoricoDeCaixas.call(filtro: filtro);
      emit(
        state.copyWith(
          step: HistoricoDeCaixasStep.carregado,
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
          step: HistoricoDeCaixasStep.carregado,
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
