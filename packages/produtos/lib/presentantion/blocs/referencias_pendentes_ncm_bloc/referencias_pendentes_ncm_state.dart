part of 'referencias_pendentes_ncm_bloc.dart';

enum ReferenciasPendentesNcmStep {
  inicial,
  carregando,
  carregandoMais,
  carregado,
  atualizando,
  atualizado,
  falha,
}

class ReferenciasPendentesNcmState extends Equatable {
  final ReferenciasPendentesNcmStep step;
  final List<Referencia> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final String? search;
  final String orderBy;
  final String orderDir;
  final int? atualizadas;
  final int? ignoradas;

  const ReferenciasPendentesNcmState({
    this.step = ReferenciasPendentesNcmStep.inicial,
    this.items = const [],
    this.totalItems = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.search,
    this.orderBy = 'nome',
    this.orderDir = 'ASC',
    this.atualizadas,
    this.ignoradas,
  });

  ReferenciasPendentesNcmState copyWith({
    ReferenciasPendentesNcmStep? step,
    List<Referencia>? items,
    int? totalItems,
    int? totalPages,
    int? currentPage,
    Object? search = _sentinel,
    String? orderBy,
    String? orderDir,
    Object? atualizadas = _sentinel,
    Object? ignoradas = _sentinel,
  }) {
    return ReferenciasPendentesNcmState(
      step: step ?? this.step,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      search: search == _sentinel ? this.search : search as String?,
      orderBy: orderBy ?? this.orderBy,
      orderDir: orderDir ?? this.orderDir,
      atualizadas: atualizadas == _sentinel
          ? this.atualizadas
          : atualizadas as int?,
      ignoradas:
          ignoradas == _sentinel ? this.ignoradas : ignoradas as int?,
    );
  }

  @override
  List<Object?> get props => [
    step,
    items,
    totalItems,
    totalPages,
    currentPage,
    search,
    orderBy,
    orderDir,
    atualizadas,
    ignoradas,
  ];
}

const _sentinel = Object();
