part of 'cancelamento_romaneio_bloc.dart';

abstract class CancelamentoRomaneioEvent extends Equatable {
  const CancelamentoRomaneioEvent();

  @override
  List<Object?> get props => [];
}

class CancelamentoRomaneioIniciou extends CancelamentoRomaneioEvent {
  final int? idRomaneio;

  const CancelamentoRomaneioIniciou({required this.idRomaneio});

  @override
  List<Object?> get props => [idRomaneio];
}

class CancelamentoRomaneioMotivoAlterado extends CancelamentoRomaneioEvent {
  final String motivo;

  const CancelamentoRomaneioMotivoAlterado(this.motivo);

  @override
  List<Object?> get props => [motivo];
}

class CancelamentoRomaneioConfirmado extends CancelamentoRomaneioEvent {
  const CancelamentoRomaneioConfirmado();
}