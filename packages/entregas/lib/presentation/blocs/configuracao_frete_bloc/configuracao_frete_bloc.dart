import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:entregas/domain/models/frete.dart';
import 'package:entregas/use_cases.dart';

part 'configuracao_frete_event.dart';
part 'configuracao_frete_state.dart';

class ConfiguracaoFreteBloc
    extends Bloc<ConfiguracaoFreteEvent, ConfiguracaoFreteState> {
  final RecuperarConfiguracaoFrete _recuperarConfiguracao;
  final ListarTransportadorasFrete _listarTransportadoras;
  final SalvarTransportadorasFrete _salvarTransportadoras;

  ConfiguracaoFreteBloc(
    this._recuperarConfiguracao,
    this._listarTransportadoras,
    this._salvarTransportadoras,
  ) : super(const ConfiguracaoFreteState.initial()) {
    on<ConfiguracaoFreteIniciou>(_onIniciou);
    on<ConfiguracaoFreteSalvar>(_onSalvar);
  }

  FutureOr<void> _onIniciou(
    ConfiguracaoFreteIniciou event,
    Emitter<ConfiguracaoFreteState> emit,
  ) async {
    try {
      emit(state.copyWith(step: ConfiguracaoFreteStep.carregando));
      final config = await _recuperarConfiguracao.call();
      final transportadoras = config.provider != null && config.ativo
          ? await _listarTransportadoras.call()
          : <String>[];
      emit(state.copyWith(
        config: config,
        transportadoras: transportadoras,
        step: ConfiguracaoFreteStep.sucesso,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ConfiguracaoFreteStep.falha,
        erro: mensagemDeErroApi(e, 'Falha ao carregar configuração de frete.'),
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onSalvar(
    ConfiguracaoFreteSalvar event,
    Emitter<ConfiguracaoFreteState> emit,
  ) async {
    try {
      emit(state.copyWith(step: ConfiguracaoFreteStep.salvando));
      await _salvarTransportadoras.call(
        ativo: state.config?.ativo ?? false,
        transportadoras: event.transportadoras,
      );
      emit(state.copyWith(step: ConfiguracaoFreteStep.salvo));
    } catch (e, s) {
      emit(state.copyWith(
        step: ConfiguracaoFreteStep.falha,
        erro: mensagemDeErroApi(e, 'Falha ao salvar configuração de frete.'),
      ));
      addError(e, s);
    }
  }
}
