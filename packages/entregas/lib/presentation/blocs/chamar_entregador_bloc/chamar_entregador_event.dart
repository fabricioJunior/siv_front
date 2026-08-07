part of 'chamar_entregador_bloc.dart';

abstract class ChamarEntregadorEvent {}

class ChamarEntregadorIniciou extends ChamarEntregadorEvent {}

class ChamarEntregadorEstimou extends ChamarEntregadorEvent {
  final EnderecoEntrega partida;
  final EnderecoEntrega destino;
  final ParadaEntrega parada;

  ChamarEntregadorEstimou({
    required this.partida,
    required this.destino,
    required this.parada,
  });
}

class ChamarEntregadorChamou extends ChamarEntregadorEvent {}

class ChamarEntregadorObterRastreio extends ChamarEntregadorEvent {}

class ChamarEntregadorCancelou extends ChamarEntregadorEvent {
  final int? motivoId;

  ChamarEntregadorCancelou({this.motivoId});
}
