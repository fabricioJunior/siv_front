part of 'estoque_saldo_bloc.dart';

sealed class EstoqueSaldoEvent {
  const EstoqueSaldoEvent();
}

class EstoqueSaldoIniciou extends EstoqueSaldoEvent {
  final String termoBusca;
  final List<int> corIds;
  final List<int> tamanhoIds;
  final int limit;

  const EstoqueSaldoIniciou({
    this.termoBusca = '',
    this.corIds = const [],
    this.tamanhoIds = const [],
    this.limit = 20,
  });
}

class EstoqueSaldoCarregarMaisSolicitado extends EstoqueSaldoEvent {
  const EstoqueSaldoCarregarMaisSolicitado();
}
