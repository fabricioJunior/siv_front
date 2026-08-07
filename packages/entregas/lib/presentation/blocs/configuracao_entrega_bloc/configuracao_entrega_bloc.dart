import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:entregas/domain/models/entrega.dart';
import 'package:entregas/use_cases.dart';

part 'configuracao_entrega_event.dart';
part 'configuracao_entrega_state.dart';

/// Providers de entrega avulsa suportados hoje. Backend ainda não expõe
/// endpoint de listagem (só "machine" implementado); dropdown já preparado
/// para múltiplos providers futuros sem mudar a tela.
const providersEntregaDisponiveis = ['machine'];

class ConfiguracaoEntregaBloc
    extends Bloc<ConfiguracaoEntregaEvent, ConfiguracaoEntregaState> {
  final RecuperarConfiguracaoEntrega _recuperarConfiguracao;
  final SalvarConfiguracaoEntrega _salvarConfiguracao;

  ConfiguracaoEntregaBloc(
    this._recuperarConfiguracao,
    this._salvarConfiguracao,
  ) : super(const ConfiguracaoEntregaState.initial()) {
    on<ConfiguracaoEntregaIniciou>(_onIniciou);
    on<ConfiguracaoEntregaSalvar>(_onSalvar);
  }

  FutureOr<void> _onIniciou(
    ConfiguracaoEntregaIniciou event,
    Emitter<ConfiguracaoEntregaState> emit,
  ) async {
    try {
      emit(state.copyWith(step: ConfiguracaoEntregaStep.carregando));
      final config = await _recuperarConfiguracao.call();
      emit(state.copyWith(
        config: config,
        step: ConfiguracaoEntregaStep.sucesso,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ConfiguracaoEntregaStep.falha,
        erro: 'Falha ao carregar configuração de entrega.',
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onSalvar(
    ConfiguracaoEntregaSalvar event,
    Emitter<ConfiguracaoEntregaState> emit,
  ) async {
    try {
      emit(state.copyWith(step: ConfiguracaoEntregaStep.salvando));
      final config = await _salvarConfiguracao.call(
        provider: event.provider,
        ativo: event.ativo,
        configuracao: event.configuracao,
      );
      emit(state.copyWith(
        config: config,
        step: ConfiguracaoEntregaStep.salvo,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: ConfiguracaoEntregaStep.falha,
        erro: mensagemDeErroApi(e, 'Falha ao salvar configuração de entrega.'),
      ));
      addError(e, s);
    }
  }
}
