part of 'consignacao_bipagem_bloc.dart';

abstract class ConsignacaoBipagemEvent extends Equatable {
  const ConsignacaoBipagemEvent();

  @override
  List<Object?> get props => [];
}

class ConsignacaoBipagemSalvarSolicitado extends ConsignacaoBipagemEvent {
  final List<Map<String, dynamic>> itens;

  const ConsignacaoBipagemSalvarSolicitado({required this.itens});

  @override
  List<Object?> get props => [itens];
}
