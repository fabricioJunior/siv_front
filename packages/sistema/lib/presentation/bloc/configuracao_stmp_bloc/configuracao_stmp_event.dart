part of 'configuracao_stmp_bloc.dart';

abstract class ConfiguracaoSTMPEvent {}

class ConfiguracaoSTMPIniciou extends ConfiguracaoSTMPEvent {}

class ConfiguracaoSTMPEditou extends ConfiguracaoSTMPEvent {
  final int? id;
  final String? servidor;
  final int? porta;
  final String? usuario;
  final String? senha;
  final String? assuntoRedefinicaoSenha;
  final String? corpoRedefinicaoSenha;

  ConfiguracaoSTMPEditou({
    this.id,
    this.servidor,
    this.porta,
    this.usuario,
    this.senha,
    this.assuntoRedefinicaoSenha,
    this.corpoRedefinicaoSenha,
  });
}

class ConfiguracaoSTMPSalvou extends ConfiguracaoSTMPEvent {}

class ConfiguracaoSTMPConexaoVerificada extends ConfiguracaoSTMPEvent {}
