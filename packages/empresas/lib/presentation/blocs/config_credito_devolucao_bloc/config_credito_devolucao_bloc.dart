import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/domain/entities/config_credito_devolucao.dart';
import 'package:empresas/use_cases.dart';

sealed class ConfigCreditoDevolucaoEvent {}

class ConfigCreditoDevolucaoCarregou extends ConfigCreditoDevolucaoEvent {
  final int empresaId;
  ConfigCreditoDevolucaoCarregou(this.empresaId);
}

class ConfigCreditoDevolucaoSalvou extends ConfigCreditoDevolucaoEvent {
  final ConfigCreditoDevolucao config;
  ConfigCreditoDevolucaoSalvou(this.config);
}

enum ConfigCreditoDevolucaoStatus { carregando, pronto, salvando, salvo, erro }

class ConfigCreditoDevolucaoState extends Equatable {
  final ConfigCreditoDevolucaoStatus status;
  final ConfigCreditoDevolucao? config;
  final String? erro;

  const ConfigCreditoDevolucaoState({
    this.status = ConfigCreditoDevolucaoStatus.carregando,
    this.config,
    this.erro,
  });

  @override
  List<Object?> get props => [status, config, erro];
}

class ConfigCreditoDevolucaoBloc
    extends Bloc<ConfigCreditoDevolucaoEvent, ConfigCreditoDevolucaoState> {
  final RecuperarConfigCreditoDevolucao _recuperar;
  final SalvarConfigCreditoDevolucao _salvar;
  int _empresaId = 0;

  ConfigCreditoDevolucaoBloc(this._recuperar, this._salvar)
      : super(const ConfigCreditoDevolucaoState()) {
    on<ConfigCreditoDevolucaoCarregou>((e, emit) async {
      _empresaId = e.empresaId;
      try {
        emit(ConfigCreditoDevolucaoState(
          status: ConfigCreditoDevolucaoStatus.pronto,
          config: await _recuperar(e.empresaId),
        ));
      } catch (err) {
        emit(ConfigCreditoDevolucaoState(
          status: ConfigCreditoDevolucaoStatus.erro,
          erro: mensagemDeErroApi(err, 'Falha ao carregar a configuração.'),
        ));
      }
    });
    on<ConfigCreditoDevolucaoSalvou>((e, emit) async {
      emit(ConfigCreditoDevolucaoState(
        status: ConfigCreditoDevolucaoStatus.salvando,
        config: state.config,
      ));
      try {
        emit(ConfigCreditoDevolucaoState(
          status: ConfigCreditoDevolucaoStatus.salvo,
          config: await _salvar(_empresaId, e.config),
        ));
      } catch (err) {
        emit(ConfigCreditoDevolucaoState(
          status: ConfigCreditoDevolucaoStatus.erro,
          config: state.config,
          erro: mensagemDeErroApi(err, 'Falha ao salvar a configuração.'),
        ));
      }
    });
  }
}
