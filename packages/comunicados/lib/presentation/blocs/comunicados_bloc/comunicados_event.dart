part of 'comunicados_bloc.dart';

abstract class ComunicadosEvent {}

class ComunicadosCarregar extends ComunicadosEvent {
  final String? status;
  final int pagina;

  ComunicadosCarregar({this.status, this.pagina = 1});
}
