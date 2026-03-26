part of 'referencia_midias_bloc.dart';

abstract class ReferenciaMidiasEvent {}

class ReferenciasIniciou extends ReferenciaMidiasEvent {
  final int referenciaId;
  ReferenciasIniciou(this.referenciaId);
}

class ReferenciasMidiaAdicinou extends ReferenciaMidiasEvent {
  final int referenciaId;
  final String? cor;
  final String? tamanho;
  final List<Imagem> midias;
  ReferenciasMidiaAdicinou(
    this.referenciaId,
    this.midias, {
    this.cor,
    this.tamanho,
  });
}

class ReferenciaMidiasRemoveu extends ReferenciaMidiasEvent {
  final int referenciaId;
  final int midiaId;
  ReferenciaMidiasRemoveu(this.referenciaId, this.midiaId);
}

class ReferenciaMidiasAtualizou extends ReferenciaMidiasEvent {
  final int referenciaId;
  final ReferenciaMidia midia;
  final bool ePrincipal;
  final bool ePublica;

  ReferenciaMidiasAtualizou({
    required this.referenciaId,
    required this.midia,
    required this.ePrincipal,
    required this.ePublica,
  });
}
