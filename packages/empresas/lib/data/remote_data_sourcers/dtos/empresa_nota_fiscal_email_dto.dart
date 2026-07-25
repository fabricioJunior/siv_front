import 'package:empresas/domain/entities/empresa_nota_fiscal_email.dart';

class EmpresaNotaFiscalEmailDto implements EmpresaNotaFiscalEmail {
  @override
  final int empresaId;

  @override
  final bool ativo;

  @override
  final String? assunto;

  @override
  final String? templateHtml;

  const EmpresaNotaFiscalEmailDto({
    required this.empresaId,
    required this.ativo,
    this.assunto,
    this.templateHtml,
  });

  factory EmpresaNotaFiscalEmailDto.fromJson(Map<String, dynamic> json) {
    return EmpresaNotaFiscalEmailDto(
      empresaId: (json['empresaId'] as num?)?.toInt() ?? 0,
      ativo: json['ativo'] as bool? ?? false,
      assunto: json['assunto'] as String?,
      templateHtml: json['templateHtml'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ativo': ativo,
      if (assunto != null) 'assunto': assunto,
      if (templateHtml != null) 'templateHtml': templateHtml,
    };
  }

  @override
  List<Object?> get props => [empresaId, ativo, assunto, templateHtml];

  @override
  bool? get stringify => true;
}

extension EmpresaNotaFiscalEmailToDto on EmpresaNotaFiscalEmail {
  EmpresaNotaFiscalEmailDto toDto() {
    return EmpresaNotaFiscalEmailDto(
      empresaId: empresaId,
      ativo: ativo,
      assunto: assunto,
      templateHtml: templateHtml,
    );
  }
}
