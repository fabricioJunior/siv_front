part of 'documentos_fiscais_bloc.dart';

class DocumentosFiscaisState extends Equatable {
  final List<DocumentoFiscal> items;
  final int total;
  final int page;
  final String? erro;
  final DocumentosFiscaisStep step;
  final Set<int> reprocessando;

  const DocumentosFiscaisState({
    required this.items,
    required this.total,
    required this.page,
    this.erro,
    required this.step,
    required this.reprocessando,
  });

  const DocumentosFiscaisState.initial()
      : items = const [],
        total = 0,
        page = 1,
        erro = null,
        step = DocumentosFiscaisStep.inicial,
        reprocessando = const {};

  DocumentosFiscaisState copyWith({
    List<DocumentoFiscal>? items,
    int? total,
    int? page,
    String? erro,
    DocumentosFiscaisStep? step,
    Set<int>? reprocessando,
  }) {
    return DocumentosFiscaisState(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      erro: erro,
      step: step ?? this.step,
      reprocessando: reprocessando ?? this.reprocessando,
    );
  }

  @override
  List<Object?> get props => [items, total, page, erro, step, reprocessando];
}

enum DocumentosFiscaisStep { inicial, carregando, sucesso, falha }
