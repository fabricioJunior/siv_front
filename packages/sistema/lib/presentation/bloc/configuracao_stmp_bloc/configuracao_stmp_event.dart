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
  final String? urlVerificacaoEmail;
  final String? assuntoVerificacaoEmail;
  final String? corpoVerificacaoEmail;
  final String? assuntoPedidoConfirmado;
  final String? corpoPedidoConfirmado;
  final String? assuntoPedidoEmbalado;
  final String? corpoPedidoEmbalado;

  ConfiguracaoSTMPEditou({
    this.id,
    this.servidor,
    this.porta,
    this.usuario,
    this.senha,
    this.assuntoRedefinicaoSenha,
    this.corpoRedefinicaoSenha,
    this.urlVerificacaoEmail,
    this.assuntoVerificacaoEmail,
    this.corpoVerificacaoEmail,
    this.assuntoPedidoConfirmado,
    this.corpoPedidoConfirmado,
    this.assuntoPedidoEmbalado,
    this.corpoPedidoEmbalado,
  });
}

class ConfiguracaoSTMPSalvou extends ConfiguracaoSTMPEvent {}

class ConfiguracaoSTMPConexaoVerificada extends ConfiguracaoSTMPEvent {}
