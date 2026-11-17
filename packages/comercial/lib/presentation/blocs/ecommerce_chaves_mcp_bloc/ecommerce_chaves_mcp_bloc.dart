import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;

part 'ecommerce_chaves_mcp_event.dart';
part 'ecommerce_chaves_mcp_state.dart';

class EcommerceChavesMcpBloc extends Bloc<EcommerceChavesMcpEvent, EcommerceChavesMcpState> {
  final RecuperarChavesMcp _recuperar;
  final CriarChaveMcp _criar;
  final RevogarChaveMcp _revogar;

  EcommerceChavesMcpBloc(this._recuperar, this._criar, this._revogar)
      : super(const EcommerceChavesMcpState()) {
    on<EcommerceChavesMcpIniciou>(_onIniciou);
    on<EcommerceChaveMcpCriou>(_onCriou);
    on<EcommerceChaveMcpRevogou>(_onRevogou);
  }

  EcommerceChavesMcpStep _stepDe(List<EcommerceChaveMcp> chaves) =>
      chaves.isEmpty ? EcommerceChavesMcpStep.vazio : EcommerceChavesMcpStep.carregado;

  Future<void> _onIniciou(
    EcommerceChavesMcpIniciou event,
    Emitter<EcommerceChavesMcpState> emit,
  ) async {
    emit(state.copyWith(step: EcommerceChavesMcpStep.carregando, ecommerceId: event.ecommerceId));
    try {
      final chaves = await _recuperar(event.ecommerceId);
      emit(state.copyWith(step: _stepDe(chaves), chaves: chaves));
    } catch (e, s) {
      emit(state.copyWith(step: EcommerceChavesMcpStep.erro));
      addError(e, s);
    }
  }

  Future<void> _onCriou(
    EcommerceChaveMcpCriou event,
    Emitter<EcommerceChavesMcpState> emit,
  ) async {
    final id = state.ecommerceId;
    if (id == null) return;
    try {
      final resultado = await _criar(
        id,
        nome: event.nome,
        escopos: event.escopos,
        expiraEm: event.expiraEm,
      );
      // Só o registro mascarado entra no state; a chave em claro vai direto ao modal.
      final chaves = [resultado.registro, ...state.chaves];
      emit(state.copyWith(step: _stepDe(chaves), chaves: chaves));
      event.resposta.complete(resultado);
    } catch (e) {
      event.resposta.completeError(mensagemDeErroApi(e, 'Falha ao criar a chave.'));
    }
  }

  Future<void> _onRevogou(
    EcommerceChaveMcpRevogou event,
    Emitter<EcommerceChavesMcpState> emit,
  ) async {
    final id = state.ecommerceId;
    if (id == null) return;
    try {
      final revogada = await _revogar(id, event.chaveId);
      emit(state.copyWith(
        chaves: [for (final c in state.chaves) if (c.id == event.chaveId) revogada else c],
      ));
      event.resposta.complete(revogada);
    } catch (e) {
      event.resposta.completeError(mensagemDeErroApi(e, 'Falha ao revogar a chave.'));
    }
  }
}
