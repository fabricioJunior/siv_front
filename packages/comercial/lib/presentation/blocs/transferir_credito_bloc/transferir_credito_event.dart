part of 'transferir_credito_bloc.dart';

abstract class TransferirCreditoEvent {}

class TransferirCreditoCarregou extends TransferirCreditoEvent {
  final int pessoaId;
  TransferirCreditoCarregou(this.pessoaId);
}

class TransferirCreditoAlternou extends TransferirCreditoEvent {
  final int romaneioId;
  TransferirCreditoAlternou(this.romaneioId);
}

class TransferirCreditoConfirmou extends TransferirCreditoEvent {}
