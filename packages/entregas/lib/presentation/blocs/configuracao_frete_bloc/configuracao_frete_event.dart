part of 'configuracao_frete_bloc.dart';

abstract class ConfiguracaoFreteEvent {}

class ConfiguracaoFreteIniciou extends ConfiguracaoFreteEvent {}

class ConfiguracaoFreteSalvar extends ConfiguracaoFreteEvent {
  final List<String> transportadoras;

  ConfiguracaoFreteSalvar(this.transportadoras);
}
