import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';

part 'pontos_event.dart';
part 'pontos_state.dart';

class PontosBloc extends Bloc<PontosEvent, PontosState> {
  final RecuperarPontosDaPessoa _recuperarPontosDaPessoa;
  final CriarPontos _criarPontos;
  final RecuperarPessoa _recuperarPessoa;

  PontosBloc(
    this._recuperarPontosDaPessoa,
    this._criarPontos,
    this._recuperarPessoa,
  ) : super(PontosInicial()) {
    on<PontosIniciou>(_onPontosIniciou);
    on<PontosCriouNovoPonto>(_onPontosCriouNovoPonto);
  }

  FutureOr<void> _onPontosIniciou(
    PontosIniciou event,
    Emitter<PontosState> emit,
  ) async {
    try {
      emit(
        PontosCarregarEmProgresso(
          idPessoa: event.idPessoa,
        ),
      );
      var pontos = await _recuperarPontosDaPessoa.call(
        idPessoa: state.idPessoa!,
      );
      var pessoa = await _recuperarPessoa.call(idPessoa: event.idPessoa);
      emit(
        PontosCarregarSucesso.fromLastState(
          state,
          pontos: pontos,
          pessoa: pessoa,
        ),
      );
    } catch (e, s) {
      emit(PontosCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onPontosCriouNovoPonto(
    PontosCriouNovoPonto event,
    Emitter<PontosState> emit,
  ) async {
    try {
      emit(PontosCriarPontoEmProgresso.fromLastState(state));
      var novoPonto = await _criarPontos.call(
        idPessoa: state.idPessoa!,
        valor: event.valor,
        descricao: event.descricao,
      );
      var pontosAtualizados = List<Ponto>.from(state.pontos!);
      pontosAtualizados.add(novoPonto);
      emit(PontosCriarPontoSucesso.fromLastState(state,
          pontos: pontosAtualizados));
    } catch (e, s) {
      emit(PontosCriarPontoFalha.fromLastState(state));
      addError(e, s);
    }
  }
}
