part of 'codigos_de_barras_da_referencia_bloc.dart';

sealed class CodigosDeBarrasDaReferenciaEvent {
  const CodigosDeBarrasDaReferenciaEvent();
}

class CodigosDeBarrasDaReferenciaIniciou
    extends CodigosDeBarrasDaReferenciaEvent {
  final int referenciaId;

  const CodigosDeBarrasDaReferenciaIniciou({required this.referenciaId});
}

class CodigosDeBarrasDaReferenciaCarregarMaisSolicitado
    extends CodigosDeBarrasDaReferenciaEvent {
  const CodigosDeBarrasDaReferenciaCarregarMaisSolicitado();
}
