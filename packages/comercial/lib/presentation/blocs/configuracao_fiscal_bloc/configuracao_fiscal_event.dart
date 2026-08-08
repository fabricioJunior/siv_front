part of 'configuracao_fiscal_bloc.dart';

abstract class ConfiguracaoFiscalEvent {}

class ConfiguracaoFiscalIniciou extends ConfiguracaoFiscalEvent {
  /// Informado quando aberta a partir do cadastro de empresa (rota
  /// administrativa) -- omitido usa a empresa da sessão logada.
  final int? empresaId;

  ConfiguracaoFiscalIniciou({this.empresaId});
}

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
