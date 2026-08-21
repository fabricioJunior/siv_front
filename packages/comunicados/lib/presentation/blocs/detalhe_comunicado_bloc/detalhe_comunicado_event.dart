part of 'detalhe_comunicado_bloc.dart';

abstract class DetalheComunicadoEvent {}

class DetalheComunicadoCarregar extends DetalheComunicadoEvent {
  final int id;
  DetalheComunicadoCarregar(this.id);
}

class DetalheComunicadoCarregarDestinatarios extends DetalheComunicadoEvent {
  final String? status;
  final int pagina;
  DetalheComunicadoCarregarDestinatarios({this.status, this.pagina = 1});
}

class DetalheComunicadoReenviar extends DetalheComunicadoEvent {
  final int destinatarioId;
  DetalheComunicadoReenviar(this.destinatarioId);
}
