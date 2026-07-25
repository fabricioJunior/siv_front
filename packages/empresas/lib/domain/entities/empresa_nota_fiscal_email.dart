import 'package:core/equals.dart';

abstract class EmpresaNotaFiscalEmail implements Equatable {
  int get empresaId;
  bool get ativo;
  String? get assunto;
  String? get templateHtml;

  factory EmpresaNotaFiscalEmail.create({
    required int empresaId,
    required bool ativo,
    String? assunto,
    String? templateHtml,
  }) = _EmpresaNotaFiscalEmailImpl;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [empresaId, ativo, assunto, templateHtml];
}

class _EmpresaNotaFiscalEmailImpl implements EmpresaNotaFiscalEmail {
  @override
  final int empresaId;

  @override
  final bool ativo;

  @override
  final String? assunto;

  @override
  final String? templateHtml;

  const _EmpresaNotaFiscalEmailImpl({
    required this.empresaId,
    required this.ativo,
    this.assunto,
    this.templateHtml,
  });

  _EmpresaNotaFiscalEmailImpl copyWith({
    int? empresaId,
    bool? ativo,
    String? assunto,
    String? templateHtml,
  }) {
    return _EmpresaNotaFiscalEmailImpl(
      empresaId: empresaId ?? this.empresaId,
      ativo: ativo ?? this.ativo,
      assunto: assunto ?? this.assunto,
      templateHtml: templateHtml ?? this.templateHtml,
    );
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [empresaId, ativo, assunto, templateHtml];
}

extension EmpresaNotaFiscalEmailCopyWith on EmpresaNotaFiscalEmail {
  EmpresaNotaFiscalEmail copyWith({
    int? empresaId,
    bool? ativo,
    String? assunto,
    String? templateHtml,
  }) {
    if (this is _EmpresaNotaFiscalEmailImpl) {
      return (this as _EmpresaNotaFiscalEmailImpl).copyWith(
        empresaId: empresaId,
        ativo: ativo,
        assunto: assunto,
        templateHtml: templateHtml,
      );
    }

    return EmpresaNotaFiscalEmail.create(
      empresaId: empresaId ?? this.empresaId,
      ativo: ativo ?? this.ativo,
      assunto: assunto ?? this.assunto,
      templateHtml: templateHtml ?? this.templateHtml,
    );
  }
}
