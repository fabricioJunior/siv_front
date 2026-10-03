part of 'integracao_meta_bloc.dart';

abstract class IntegracaoMetaEvent {}

class IntegracaoMetaIniciou extends IntegracaoMetaEvent {
  final int empresaId;

  IntegracaoMetaIniciou(this.empresaId);
}

class IntegracaoMetaSalvar extends IntegracaoMetaEvent {
  final IntegracaoMetaAlteracoes alteracoes;
  final bool testarDepois;

  IntegracaoMetaSalvar(this.alteracoes, {this.testarDepois = false});
}

class IntegracaoMetaTestar extends IntegracaoMetaEvent {}
