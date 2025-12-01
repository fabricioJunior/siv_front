part of 'pontos_bloc.dart';

abstract class PontosEvent {}

class PontosIniciou extends PontosEvent {
  final int idPessoa;

  PontosIniciou({required this.idPessoa});
}

class PontosCriouNovoPonto extends PontosEvent {
  final int valor;
  final String descricao;

  PontosCriouNovoPonto({
    required this.valor,
    required this.descricao,
  });
}

class PontosCancelouPonto extends PontosEvent {
  final int idPonto;

  PontosCancelouPonto({
    required this.idPonto,
  });
}

class PontosResgatou extends PontosEvent {
  final int valor;
  final String descricao;

  PontosResgatou({required this.valor, required this.descricao});
}
