part of 'configuracao_frete_bloc.dart';

abstract class ConfiguracaoFreteEvent {}

class ConfiguracaoFreteIniciou extends ConfiguracaoFreteEvent {}

class ConfiguracaoFreteSalvar extends ConfiguracaoFreteEvent {
  final List<String> transportadoras;

  ConfiguracaoFreteSalvar(this.transportadoras);
}

class ConfiguracaoFreteSalvarIntegracao extends ConfiguracaoFreteEvent {
  final bool ativo;
  final bool sandbox;
  final String clientId;

  /// Vazio/null = não alterar.
  final String? clientSecret;

  ConfiguracaoFreteSalvarIntegracao({
    required this.ativo,
    required this.sandbox,
    required this.clientId,
    this.clientSecret,
  });
}

class ConfiguracaoFreteAutorizar extends ConfiguracaoFreteEvent {}
