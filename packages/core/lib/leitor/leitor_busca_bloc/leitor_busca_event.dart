part of 'leitor_busca_bloc.dart';

sealed class LeitorBuscaEvent {
  const LeitorBuscaEvent();
}

class LeitorBuscaTextoBuscado extends LeitorBuscaEvent {
  final String texto;

  const LeitorBuscaTextoBuscado(this.texto);
}

class LeitorBuscaTamanhoFiltrado extends LeitorBuscaEvent {
  final String? tamanho;

  const LeitorBuscaTamanhoFiltrado(this.tamanho);
}

class LeitorBuscaCorFiltrada extends LeitorBuscaEvent {
  final String? cor;

  const LeitorBuscaCorFiltrada(this.cor);
}
