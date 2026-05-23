part of 'devolucao_bloc.dart';

sealed class DevolucaoEvent extends Equatable {
  const DevolucaoEvent();

  @override
  List<Object?> get props => [];
}

class DevolucaoIniciou extends DevolucaoEvent {
  const DevolucaoIniciou();
}

class DevolucaoBuscaRomaneiosSolicitada extends DevolucaoEvent {
  final String? searchTerm;

  const DevolucaoBuscaRomaneiosSolicitada({this.searchTerm});

  @override
  List<Object?> get props => [searchTerm];
}

class DevolucaoRomaneioOriginalSelecionado extends DevolucaoEvent {
  final Romaneio romaneio;

  const DevolucaoRomaneioOriginalSelecionado({required this.romaneio});

  @override
  List<Object?> get props => [romaneio];
}

class DevolucaoLeituraSolicitada extends DevolucaoEvent {
  const DevolucaoLeituraSolicitada();
}

class DevolucaoEdicaoSolicitada extends DevolucaoEvent {
  const DevolucaoEdicaoSolicitada();
}

class DevolucaoConfirmacaoSolicitada extends DevolucaoEvent {
  final List<Map<String, dynamic>> itens;

  const DevolucaoConfirmacaoSolicitada({required this.itens});

  @override
  List<Object?> get props => [itens];
}

class DevolucaoResetSolicitado extends DevolucaoEvent {
  const DevolucaoResetSolicitado();
}
