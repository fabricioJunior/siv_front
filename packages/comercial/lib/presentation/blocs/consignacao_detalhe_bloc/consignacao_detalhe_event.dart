part of 'consignacao_detalhe_bloc.dart';

abstract class ConsignacaoDetalheEvent extends Equatable {
  const ConsignacaoDetalheEvent();

  @override
  List<Object?> get props => [];
}

class ConsignacaoDetalheCarregarSolicitado extends ConsignacaoDetalheEvent {
  final int id;

  const ConsignacaoDetalheCarregarSolicitado({required this.id});

  @override
  List<Object?> get props => [id];
}

class ConsignacaoDetalheFecharSolicitado extends ConsignacaoDetalheEvent {
  const ConsignacaoDetalheFecharSolicitado();
}

class ConsignacaoDetalheCancelarSolicitado extends ConsignacaoDetalheEvent {
  final String motivoCancelamento;

  const ConsignacaoDetalheCancelarSolicitado({
    required this.motivoCancelamento,
  });

  @override
  List<Object?> get props => [motivoCancelamento];
}
