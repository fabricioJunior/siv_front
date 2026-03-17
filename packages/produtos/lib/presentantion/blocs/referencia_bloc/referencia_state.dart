part of 'referencia_bloc.dart';

abstract class ReferenciaState extends Equatable {
  Referencia? get referencia => null;

  const ReferenciaState();

  @override
  List<Object?> get props => [referencia];
}

class ReferenciaInitial extends ReferenciaState {
  const ReferenciaInitial();
}

class ReferenciaCarregarEmProgresso extends ReferenciaState {
  const ReferenciaCarregarEmProgresso();
}

class ReferenciaCarregarSucesso extends ReferenciaState {
  @override
  final Referencia referencia;

  const ReferenciaCarregarSucesso({required this.referencia});
}

class ReferenciaCarregarFalha extends ReferenciaState {
  const ReferenciaCarregarFalha();
}
