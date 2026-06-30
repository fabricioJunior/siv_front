import 'dart:async';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'configuracao_fiscal_event.dart';
part 'configuracao_fiscal_state.dart';

class ConfiguracaoFiscalBloc
    extends Bloc<ConfiguracaoFiscalEvent, ConfiguracaoFiscalState> {
  final GetConfiguracaoFiscal _getConfiguracao;
  final SalvarConfiguracaoFiscal _salvarConfiguracao;

  ConfiguracaoFiscalBloc(
    this._getConfiguracao,
    this._salvarConfiguracao,
  ) : super(const ConfiguracaoFiscalState.initial()) {
    on<ConfiguracaoFiscalIniciou>(_onIniciou);
    on<ConfiguracaoFiscalSalvar>(_onSalvar);
  }

  FutureOr<void> _onIniciou(
    ConfiguracaoFiscalIniciou event,
    Emitter<ConfiguracaoFiscalState> emit,
  ) async {
    try {
      emit(state.copyWith(step: ConfiguracaoFiscalStep.carregando));
      final result = await _getConfiguracao.call();
      emit(state.copyWith(
        providers: result.providers,
        config: result.config,
        step: ConfiguracaoFiscalStep.sucesso,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ConfiguracaoFiscalStep.falha,
        erro: 'Falha ao carregar configuração fiscal.',
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onSalvar(
    ConfiguracaoFiscalSalvar event,
    Emitter<ConfiguracaoFiscalState> emit,
  ) async {
    try {
      emit(state.copyWith(step: ConfiguracaoFiscalStep.salvando));
      final config = await _salvarConfiguracao.call(
        provider: event.provider,
        ativo: event.ativo,
        configuracao: event.configuracao,
      );
      emit(state.copyWith(
        config: config,
        step: ConfiguracaoFiscalStep.salvo,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ConfiguracaoFiscalStep.falha,
        erro: 'Falha ao salvar configuração fiscal.',
      ));
      addError(e, s);
    }
  }
}
