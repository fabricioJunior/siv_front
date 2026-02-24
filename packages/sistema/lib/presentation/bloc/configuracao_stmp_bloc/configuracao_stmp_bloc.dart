import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:sistema/models.dart';
import 'package:sistema/uses_cases.dart';

part 'configuracao_stmp_event.dart';
part 'configuracao_stmp_state.dart';

class ConfiguracaoSTMPBloc
    extends Bloc<ConfiguracaoSTMPEvent, ConfiguracaoSTMPState> {
  final RecuperarConfiguracaoSTMP recuperarConfiguracao;
  final CriarConfiguracaoSTMP criarConfiguracao;
  final AtualizarConfiguracaoSTMP atualizarConfiguracao;
  final VerificarConexaoSTMP verificarConexao;

  ConfiguracaoSTMPBloc(
    this.recuperarConfiguracao,
    this.criarConfiguracao,
    this.atualizarConfiguracao,
    this.verificarConexao,
  ) : super(const ConfiguracaoSTMPState(step: ConfiguracaoSTMPStep.inicial)) {
    on<ConfiguracaoSTMPIniciou>(_onIniciou);
    on<ConfiguracaoSTMPEditou>(_onEditou);
    on<ConfiguracaoSTMPSalvou>(_onSalvou);
    on<ConfiguracaoSTMPConexaoVerificada>(_onConexaoVerificada);
  }

  FutureOr<void> _onIniciou(
    ConfiguracaoSTMPIniciou event,
    Emitter<ConfiguracaoSTMPState> emit,
  ) async {
    emit(state.copyWith(step: ConfiguracaoSTMPStep.carregando));
    try {
      final configuracao = await recuperarConfiguracao.call();
      if (configuracao == null) {
        emit(
          state.copyWith(
            step: ConfiguracaoSTMPStep.editando,
            id: 0,
          ),
        );
        return;
      }

      emit(ConfiguracaoSTMPState.fromModel(configuracao));
    } catch (e, s) {
      addError(e, s);
      emit(state.copyWith(step: ConfiguracaoSTMPStep.falha));
    }
  }

  FutureOr<void> _onEditou(
    ConfiguracaoSTMPEditou event,
    Emitter<ConfiguracaoSTMPState> emit,
  ) {
    emit(
      state.copyWith(
        step: ConfiguracaoSTMPStep.editando,
        id: event.id,
        servidor: event.servidor,
        porta: event.porta,
        usuario: event.usuario,
        senha: event.senha,
        assuntoRedefinicaoSenha: event.assuntoRedefinicaoSenha,
        corpoRedefinicaoSenha: event.corpoRedefinicaoSenha,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    ConfiguracaoSTMPSalvou event,
    Emitter<ConfiguracaoSTMPState> emit,
  ) async {
    try {
      emit(state.copyWith(step: ConfiguracaoSTMPStep.salvando));

      final configuracaoAtual = state.configuracao;
      ConfiguracaoSTMP configuracaoSalva;

      if (configuracaoAtual == null) {
        configuracaoSalva = await criarConfiguracao.call(
          id: state.id ?? 0,
          servidor: state.servidor ?? '',
          porta: state.porta ?? 0,
          usuario: state.usuario ?? '',
          senha: state.senha ?? '',
          assuntoRedefinicaoSenha: state.assuntoRedefinicaoSenha ?? '',
          corpoRedefinicaoSenha: state.corpoRedefinicaoSenha ?? '',
        );
      } else {
        configuracaoSalva = await atualizarConfiguracao.call(
          configuracao: configuracaoAtual,
          servidor: state.servidor,
          porta: state.porta,
          usuario: state.usuario,
          senha: state.senha,
          assuntoRedefinicaoSenha: state.assuntoRedefinicaoSenha,
          corpoRedefinicaoSenha: state.corpoRedefinicaoSenha,
        );
      }

      emit(
        ConfiguracaoSTMPState.fromModel(
          configuracaoSalva,
          step: ConfiguracaoSTMPStep.salva,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(state.copyWith(step: ConfiguracaoSTMPStep.falha));
    }
  }

  FutureOr<void> _onConexaoVerificada(
    ConfiguracaoSTMPConexaoVerificada event,
    Emitter<ConfiguracaoSTMPState> emit,
  ) async {
    try {
      if (state.configuracao == null) {
        emit(state.copyWith(step: ConfiguracaoSTMPStep.configuracaoNaoSalva));
        return;
      }

      emit(state.copyWith(step: ConfiguracaoSTMPStep.verificandoConexao));

      final conexaoValida = await verificarConexao.call();

      emit(
        state.copyWith(
          step: conexaoValida
              ? ConfiguracaoSTMPStep.conexaoValida
              : ConfiguracaoSTMPStep.conexaoInvalida,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(state.copyWith(step: ConfiguracaoSTMPStep.conexaoInvalida));
    }
  }
}
