part of 'integracao_infinity_pay_bloc.dart';

abstract class IntegracaoInfinityPayEvent {}

class IntegracaoInfinityPayIniciou extends IntegracaoInfinityPayEvent {
  final int empresaId;
  IntegracaoInfinityPayIniciou(this.empresaId);
}

class IntegracaoInfinityPayAlterou extends IntegracaoInfinityPayEvent {
  final CampoInfinityPay campo;
  final String valor;
  IntegracaoInfinityPayAlterou(this.campo, this.valor);
}

class IntegracaoInfinityPayUsouWebhookPadrao
    extends IntegracaoInfinityPayEvent {}

class IntegracaoInfinityPayUsouSiteEmpresa extends IntegracaoInfinityPayEvent {}

class IntegracaoInfinityPayDescartou extends IntegracaoInfinityPayEvent {}

class IntegracaoInfinityPaySalvou extends IntegracaoInfinityPayEvent {}
