part of 'cupons_bloc.dart';

abstract class CuponsEvent {}

class CuponsIniciou extends CuponsEvent {
  final String? busca;

  CuponsIniciou({this.busca});
}
