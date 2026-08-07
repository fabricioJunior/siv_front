part of 'configuracao_entrega_bloc.dart';

abstract class ConfiguracaoEntregaEvent {}

class ConfiguracaoEntregaIniciou extends ConfiguracaoEntregaEvent {}

class ConfiguracaoEntregaSalvar extends ConfiguracaoEntregaEvent {
  final String provider;
  final bool ativo;
  final Map<String, dynamic>? configuracao;

  ConfiguracaoEntregaSalvar({
    required this.provider,
    required this.ativo,
    this.configuracao,
  });
}
