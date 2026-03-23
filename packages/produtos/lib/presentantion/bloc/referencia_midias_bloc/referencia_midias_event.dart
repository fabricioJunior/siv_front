part of 'referencia_midias_bloc.dart';

abstract class ReferenciaMidiasEvent {}

class CarregarMidiasReferencia extends ReferenciaMidiasEvent {
  final int referenciaId;
  CarregarMidiasReferencia(this.referenciaId);
}

class AdicionarMidiaReferencia extends ReferenciaMidiasEvent {
  final int referenciaId;
  final List<Imagem> midias;
  AdicionarMidiaReferencia(this.referenciaId, this.midias);
}

class RemoverMidiaReferencia extends ReferenciaMidiasEvent {
  final int referenciaId;
  final int midiaId;
  RemoverMidiaReferencia(this.referenciaId, this.midiaId);
}
