import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';
import 'package:empresas/use_cases.dart';

part 'integracao_meta_event.dart';
part 'integracao_meta_state.dart';

class IntegracaoMetaBloc
    extends Bloc<IntegracaoMetaEvent, IntegracaoMetaState> {
  final RecuperarIntegracaoMeta recuperarIntegracaoMeta;
  final SalvarIntegracaoMeta salvarIntegracaoMeta;
  final TestarIntegracaoMeta testarIntegracaoMeta;

  IntegracaoMetaBloc(
    this.recuperarIntegracaoMeta,
    this.salvarIntegracaoMeta,
    this.testarIntegracaoMeta,
  ) : super(const IntegracaoMetaState()) {
    on<IntegracaoMetaIniciou>(_onIniciou);
    on<IntegracaoMetaSalvar>(_onSalvar);
    on<IntegracaoMetaTestar>(_onTestar);
  }

  FutureOr<void> _onIniciou(
    IntegracaoMetaIniciou event,
    Emitter<IntegracaoMetaState> emit,
  ) async {
    emit(state.copyWith(empresaId: event.empresaId, carregando: true, erro: null));
    try {
      final configuracao = await recuperarIntegracaoMeta.call(event.empresaId);
      emit(state.copyWith(configuracao: configuracao, carregando: false));
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          carregando: false,
          erro: 'Falha ao carregar integração Meta.',
        ),
      );
    }
  }

  FutureOr<void> _onSalvar(
    IntegracaoMetaSalvar event,
    Emitter<IntegracaoMetaState> emit,
  ) async {
    final empresaId = state.empresaId;
    if (empresaId == null) return;

    emit(state.copyWith(salvando: true, erro: null, salvou: false));
    try {
      final salvo = await salvarIntegracaoMeta.call(empresaId, event.alteracoes);
      emit(
        state.copyWith(configuracao: salvo, salvando: false, salvou: true),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          salvando: false,
          erro: 'Falha ao salvar integração Meta.',
        ),
      );
      return;
    }
    if (event.testarDepois) await _onTestar(IntegracaoMetaTestar(), emit);
  }

  FutureOr<void> _onTestar(
    IntegracaoMetaTestar event,
    Emitter<IntegracaoMetaState> emit,
  ) async {
    final empresaId = state.empresaId;
    if (empresaId == null) return;

    emit(state.copyWith(testando: true, erro: null, salvou: false));
    try {
      final teste = await testarIntegracaoMeta.call(empresaId);
      emit(state.copyWith(teste: teste, testando: false));
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          testando: false,
          erro: 'Falha ao testar conexão com a Meta.',
        ),
      );
    }
  }
}
