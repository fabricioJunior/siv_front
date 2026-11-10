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

  /// Tela de consulta: comprime a <=1MB e exige cor/estampa/tamanho no servidor.
  final bool validarAssociacao;
  ReferenciasMidiaAdicinou(
    this.referenciaId,
    this.midias, {
    this.cor,
    this.tamanho,
    this.validarAssociacao = false,
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
  final bool validarAssociacao;

  ReferenciaMidiasAtualizou({
    required this.referenciaId,
    required this.midia,
    required this.ePrincipal,
    required this.ePublica,
    this.validarAssociacao = false,
  });
}

class ReferenciaMidiasReordenou extends ReferenciaMidiasEvent {
  final int referenciaId;

  /// Ids na ordem final; a primeira vira capa.
  final List<int> ids;
  ReferenciaMidiasReordenou(this.referenciaId, this.ids);
}
