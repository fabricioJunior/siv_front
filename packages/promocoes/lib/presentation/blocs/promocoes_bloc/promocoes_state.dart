part of 'promocoes_bloc.dart';

abstract class PromocoesState extends Equatable {
  final List<Promocao> promocoes;

  const PromocoesState({this.promocoes = const []});

  @override
  List<Object?> get props => [promocoes];
}

class PromocoesInitial extends PromocoesState {
  const PromocoesInitial();
}

class PromocoesCarregarEmProgresso extends PromocoesState {
  const PromocoesCarregarEmProgresso({required super.promocoes});
}

class PromocoesCarregarSucesso extends PromocoesState {
  const PromocoesCarregarSucesso({required super.promocoes});
}

class PromocoesCarregarFalha extends PromocoesState {
  const PromocoesCarregarFalha({required super.promocoes});
}
