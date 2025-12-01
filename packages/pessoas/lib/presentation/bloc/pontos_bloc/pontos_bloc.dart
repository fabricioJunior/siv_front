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
  final CancelarPonto _cancelarPonto;
  final ResgatarPontos _resgatarPontos;

  PontosBloc(
    this._recuperarPontosDaPessoa,
    this._criarPontos,
    this._recuperarPessoa,
    this._cancelarPonto,
    this._resgatarPontos,
  ) : super(PontosInicial()) {
    on<PontosIniciou>(_onPontosIniciou);
    on<PontosCriouNovoPonto>(_onPontosCriouNovoPonto);
    on<PontosCancelouPonto>(_onPontosCancelouPonto);
    on<PontosResgatou>(_onPontosResgatou);
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

  FutureOr<void> _onPontosCancelouPonto(
    PontosCancelouPonto event,
    Emitter<PontosState> emit,
  ) async {
    try {
      emit(PontosExcluirPontoEmProgresso.fromLastState(state));
      await _cancelarPonto.call(
          idPonto: event.idPonto, idPessoa: state.idPessoa!);
      var pontosAtualizados = List<Ponto>.from(state.pontos!)
        ..removeWhere((ponto) => ponto.id == event.idPonto);
      emit(
        PontosExcluirPontoSucesso.fromLastState(
          state,
          pontos: pontosAtualizados,
        ),
      );
    } catch (e, s) {
      emit(PontosExcluirPontoFalha.fromLastState(state));
      addError(e, s);
    }
  }

  FutureOr<void> _onPontosResgatou(
    PontosResgatou event,
    Emitter<PontosState> emit,
  ) async {
    try {
      emit(PontosResgatarEmProgresso.fromLastState(state));
      await _resgatarPontos.call(
        idPessoa: state.idPessoa!,
        valor: event.valor,
        descricao: event.descricao,
      );
      var pontos = await _recuperarPontosDaPessoa.call(
        idPessoa: state.idPessoa!,
      );
      emit(
        PontosResgatarSucesso.fromLastState(
          state,
          pontos: pontos,
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }
}
