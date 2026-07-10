part of 'consignacao_bipagem_bloc.dart';

class ConsignacaoBipagemState extends Equatable {
  final bool salvando;
  final String? listaCompartilhadaHash;
  final String? erro;

  const ConsignacaoBipagemState({
    this.salvando = false,
    this.listaCompartilhadaHash,
    this.erro,
  });

  ConsignacaoBipagemState copyWith({
    bool? salvando,
    String? listaCompartilhadaHash,
    String? erro,
  }) {
    return ConsignacaoBipagemState(
      salvando: salvando ?? this.salvando,
      listaCompartilhadaHash: listaCompartilhadaHash,
      erro: erro,
    );
  }

  @override
  List<Object?> get props => [salvando, listaCompartilhadaHash, erro];
}
