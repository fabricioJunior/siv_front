part of 'adicionar_variacoes_bloc.dart';

abstract class AdicionarVariacoesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdicionarVariacoesIniciou extends AdicionarVariacoesEvent {
  final int referenciaId;
  final Set<int> corIdsNaGrade;
  final Set<int> tamanhoIdsNaGrade;
  final Set<int> estampaIdsNaGrade;

  /// Chaves exatas ('$corId|$tamanhoId|$estampaId') já existentes na
  /// grade -- usadas pra calcular o diff de combinações novas.
  final Set<String> chavesNaGrade;

  AdicionarVariacoesIniciou({
    required this.referenciaId,
    this.corIdsNaGrade = const {},
    this.tamanhoIdsNaGrade = const {},
    this.estampaIdsNaGrade = const {},
    this.chavesNaGrade = const {},
  });

  @override
  List<Object?> get props => [
    referenciaId,
    corIdsNaGrade,
    tamanhoIdsNaGrade,
    estampaIdsNaGrade,
    chavesNaGrade,
  ];
}

class AdicionarVariacoesCorAlternou extends AdicionarVariacoesEvent {
  final int corId;
  AdicionarVariacoesCorAlternou({required this.corId});
  @override
  List<Object?> get props => [corId];
}

class AdicionarVariacoesTamanhoAlternou extends AdicionarVariacoesEvent {
  final int tamanhoId;
  AdicionarVariacoesTamanhoAlternou({required this.tamanhoId});
  @override
  List<Object?> get props => [tamanhoId];
}

class AdicionarVariacoesEstampaAlternou extends AdicionarVariacoesEvent {
  final int estampaId;
  AdicionarVariacoesEstampaAlternou({required this.estampaId});
  @override
  List<Object?> get props => [estampaId];
}

class AdicionarVariacoesEstampasAtivouAlternou extends AdicionarVariacoesEvent {
  final bool ativo;
  AdicionarVariacoesEstampasAtivouAlternou({required this.ativo});
  @override
  List<Object?> get props => [ativo];
}

enum CampoBuscaVariacoes { cor, tamanho, estampa }

class AdicionarVariacoesBuscaAlterou extends AdicionarVariacoesEvent {
  final CampoBuscaVariacoes campo;
  final String texto;
  AdicionarVariacoesBuscaAlterou({required this.campo, required this.texto});
  @override
  List<Object?> get props => [campo, texto];
}

class AdicionarVariacoesConfirmou extends AdicionarVariacoesEvent {}
