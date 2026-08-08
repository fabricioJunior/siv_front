part of 'cupons_bloc.dart';

abstract class CuponsState extends Equatable {
  final List<Cupom> cupons;

  const CuponsState({this.cupons = const []});

  @override
  List<Object?> get props => [cupons];
}

class CuponsInitial extends CuponsState {
  const CuponsInitial();
}

class CuponsCarregarEmProgresso extends CuponsState {
  const CuponsCarregarEmProgresso({required super.cupons});
}

class CuponsCarregarSucesso extends CuponsState {
  const CuponsCarregarSucesso({required super.cupons});
}

class CuponsCarregarFalha extends CuponsState {
  const CuponsCarregarFalha({required super.cupons});
}
