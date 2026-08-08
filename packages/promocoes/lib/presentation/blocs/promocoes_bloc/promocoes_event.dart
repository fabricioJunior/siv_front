part of 'promocoes_bloc.dart';

abstract class PromocoesEvent {}

class PromocoesIniciou extends PromocoesEvent {
  final String? busca;

  PromocoesIniciou({this.busca});
}
