import 'package:core/injecoes.dart';
import 'package:notificacoes/data/notificacoes_remote_data_source.dart';
import 'package:notificacoes/domain/notificacoes_gateway.dart';
import 'package:notificacoes/domain/use_cases.dart';

/// O `NotificacoesBloc` é registrado no app (precisa do evento de logout,
/// que vem do package de autenticação).
void resolverNotificacoesInjection() {
  sl.registerFactory<NotificacoesGateway>(
    () => NotificacoesRemoteDataSource(informacoesParaRequest: sl()),
  );
  sl.registerFactory(() => ListarNotificacoesNaoLidas(sl()));
  sl.registerFactory(() => ContarNotificacoesNaoLidas(sl()));
  sl.registerFactory(() => MarcarNotificacaoLida(sl()));
  sl.registerFactory(() => MarcarTodasNotificacoesLidas(sl()));
}
