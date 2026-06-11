part of 'balanco_bloc.dart';

sealed class BalancoState extends Equatable {
  const BalancoState();

  @override
  List<Object?> get props => [];
}

class BalancoInitial extends BalancoState {
  const BalancoInitial();
}

class BalancoLoading extends BalancoState {
  const BalancoLoading();
}

class BalancoSuccess<T> extends BalancoState {
  final T data;
  final String? message;

  const BalancoSuccess({required this.data, this.message});

  @override
  List<Object?> get props => [data, message];
}

class BalancoError extends BalancoState {
  final String message;
  final dynamic error;

  const BalancoError({required this.message, this.error});

  @override
  List<Object?> get props => [message, error];
}

class BalancoCreated extends BalancoState {
  final Balanco balanco;

  const BalancoCreated({required this.balanco});

  @override
  List<Object?> get props => [balanco];
}

class BalancoListLoaded extends BalancoState {
  final List<Balanco> balancos;
  final int page;
  final int limit;
  final bool hasMore;

  const BalancoListLoaded({
    required this.balancos,
    required this.page,
    required this.limit,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [balancos, page, limit, hasMore];
}

class BalancoLoaded extends BalancoState {
  final Balanco balanco;

  const BalancoLoaded({required this.balanco});

  @override
  List<Object?> get props => [balanco];
}

class BalancoUpdated extends BalancoState {
  final Balanco balanco;

  const BalancoUpdated({required this.balanco});

  @override
  List<Object?> get props => [balanco];
}

class BalancoFinalized extends BalancoState {
  final Balanco balanco;

  const BalancoFinalized({required this.balanco});

  @override
  List<Object?> get props => [balanco];
}

class BalancoCanceled extends BalancoState {
  final Balanco balanco;

  const BalancoCanceled({required this.balanco});

  @override
  List<Object?> get props => [balanco];
}

class BalancoResumoLoaded extends BalancoState {
  final Map<String, dynamic> resumo;

  const BalancoResumoLoaded({required this.resumo});

  @override
  List<Object?> get props => [resumo];
}

// ===== ITENS DO BALANÇO =====

class BalancoItemAdded extends BalancoState {
  final BalancoItem item;

  const BalancoItemAdded({required this.item});

  @override
  List<Object?> get props => [item];
}

class BalancoItemsAdded extends BalancoState {
  const BalancoItemsAdded();
}

class BalancoItemsLoaded extends BalancoState {
  final List<BalancoItem> items;

  const BalancoItemsLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class BalancoItemRemoved extends BalancoState {
  final int produtoId;

  const BalancoItemRemoved({required this.produtoId});

  @override
  List<Object?> get props => [produtoId];
}
