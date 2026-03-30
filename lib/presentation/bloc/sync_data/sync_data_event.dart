part of 'sync_data_bloc.dart';

abstract class SyncDataEvent {
  const SyncDataEvent();
}

class SyncDataSolicitouSincronizacao extends SyncDataEvent {
  final SyncDataOrigem origem;

  const SyncDataSolicitouSincronizacao({required this.origem});
}

class SyncDataAtualizacaoRecebida extends SyncDataEvent {
  final SyncModulo modulo;
  final Paginacao paginacao;

  const SyncDataAtualizacaoRecebida({
    required this.modulo,
    required this.paginacao,
  });
}

class SyncDataModuloConcluido extends SyncDataEvent {
  final SyncModulo modulo;

  const SyncDataModuloConcluido({required this.modulo});
}

class SyncDataModuloFalhou extends SyncDataEvent {
  final SyncModulo modulo;
  final String erro;

  const SyncDataModuloFalhou({
    required this.modulo,
    required this.erro,
  });
}
