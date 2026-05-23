import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'fechamento_de_caixa_event.dart';
part 'fechamento_de_caixa_state.dart';

class FechamentoDeCaixaBloc
    extends Bloc<FechamentoDeCaixaEvent, FechamentoDeCaixaState> {
  final RecuperarItensPendentesParaContagemDoCaixaUseCase _recuperarPendentes;
  final RecuperarContagemDoCaixa _recuperarContagem;

  FechamentoDeCaixaBloc(
    this._recuperarPendentes,
    this._recuperarContagem,
  ) : super(const FechamentoDeCaixaState.initial()) {
    on<FechamentoDeCaixaIniciou>(_onIniciou);
    on<FechamentoDeCaixaRecarregarSolicitado>(_onRecarregarSolicitado);
  }

  FutureOr<void> _onIniciou(
    FechamentoDeCaixaIniciou event,
    Emitter<FechamentoDeCaixaState> emit,
  ) async {
    await _carregar(caixaId: event.caixaId, emit: emit);
  }

  FutureOr<void> _onRecarregarSolicitado(
    FechamentoDeCaixaRecarregarSolicitado event,
    Emitter<FechamentoDeCaixaState> emit,
  ) async {
    await _carregar(caixaId: event.caixaId, emit: emit);
  }

  Future<void> _carregar({
    required int caixaId,
    required Emitter<FechamentoDeCaixaState> emit,
  }) async {
    emit(
      state.copyWith(
        caixaId: caixaId,
        step: FechamentoDeCaixaStep.carregando,
        erro: null,
      ),
    );

    try {
      final pendentes = await _recuperarPendentes(caixaId: caixaId);
      final contagem = await _recuperarContagem(caixaId: caixaId);

      final contadosPorTipo = {
        for (final item in (contagem?.itens ?? const <ContagemDoCaixaItem>[]))
          item.tipoDocumento: item.valor,
      };

      final itens = pendentes
          .map(
            (item) => ConferenciaFechamentoItem(
              tipo: item.tipoDocumento,
              valorEsperado: item.valor,
              valorContado: contadosPorTipo[item.tipoDocumento] ?? 0,
            ),
          )
          .toList();

      emit(
        state.copyWith(
          caixaId: caixaId,
          itens: itens,
          step: FechamentoDeCaixaStep.carregado,
          erro: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          caixaId: caixaId,
          itens: const [],
          step: FechamentoDeCaixaStep.falha,
          erro: _mensagemFalhaConferencia(error),
        ),
      );
    }
  }
}

String _mensagemFalhaConferencia(Object error) {
  if (error is FormatException) {
    return 'Falha ao processar os dados de conferencia retornados pela API. Tente novamente ou contate o suporte.';
  }

  return 'Falha ao carregar os valores para conferencia do fechamento.';
}
