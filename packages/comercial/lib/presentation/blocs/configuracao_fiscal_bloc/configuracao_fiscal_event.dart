part of 'configuracao_fiscal_bloc.dart';

abstract class ConfiguracaoFiscalEvent {}

class ConfiguracaoFiscalIniciou extends ConfiguracaoFiscalEvent {}

class ConfiguracaoFiscalSalvar extends ConfiguracaoFiscalEvent {
  final String provider;
  final bool ativo;
  final Map<String, dynamic>? configuracao;

  ConfiguracaoFiscalSalvar({
    required this.provider,
    required this.ativo,
    this.configuracao,
  });
}

class ConfiguracaoFiscalEnviarCertificado extends ConfiguracaoFiscalEvent {
  final String filePath;
  final String senha;

  ConfiguracaoFiscalEnviarCertificado({
    required this.filePath,
    required this.senha,
  });
}

class ConfiguracaoFiscalExcluirCertificado extends ConfiguracaoFiscalEvent {}
