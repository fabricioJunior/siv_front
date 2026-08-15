part of 'ecommerces_bloc.dart';

enum EcommercesStatus { inicial, carregando, carregado, erro }

class EcommercesState extends Equatable {
  final EcommercesStatus status;
  final List<Ecommerce> ecommerces;
  final bool incluirApagados;
  final String? erro;

  const EcommercesState({
    this.status = EcommercesStatus.inicial,
    this.ecommerces = const [],
    this.incluirApagados = false,
    this.erro,
  });

  EcommercesState copyWith({
    EcommercesStatus? status,
    List<Ecommerce>? ecommerces,
    bool? incluirApagados,
    Object? erro = _sentinela,
  }) {
    return EcommercesState(
      status: status ?? this.status,
      ecommerces: ecommerces ?? this.ecommerces,
      incluirApagados: incluirApagados ?? this.incluirApagados,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
    );
  }

  @override
  List<Object?> get props => [status, ecommerces, incluirApagados, erro];
}

const Object _sentinela = Object();
