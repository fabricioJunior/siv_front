part of 'leitor_bloc.dart';

sealed class LeitorEvent {
  const LeitorEvent();
}

class LeitorCodigoInformado extends LeitorEvent {
  final String codigo;
  final int quantidade;

  const LeitorCodigoInformado(this.codigo, {this.quantidade = 1});
}

class LeitorQuantidadeRemovida extends LeitorEvent {
  final String codigo;
  final int quantidade;

  const LeitorQuantidadeRemovida({
    required this.codigo,
    this.quantidade = 1,
  });
}

class LeitorItemExcluido extends LeitorEvent {
  final String codigo;

  const LeitorItemExcluido(this.codigo);
}

class LeitorReiniciado extends LeitorEvent {
  const LeitorReiniciado();
}
