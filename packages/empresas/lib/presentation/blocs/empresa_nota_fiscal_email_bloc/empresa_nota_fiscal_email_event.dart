part of 'empresa_nota_fiscal_email_bloc.dart';

abstract class EmpresaNotaFiscalEmailEvent {}

class EmpresaNotaFiscalEmailIniciou extends EmpresaNotaFiscalEmailEvent {
  final int empresaId;

  EmpresaNotaFiscalEmailIniciou(this.empresaId);
}

class EmpresaNotaFiscalEmailAtivoAlterado extends EmpresaNotaFiscalEmailEvent {
  final bool ativo;

  EmpresaNotaFiscalEmailAtivoAlterado(this.ativo);
}

class EmpresaNotaFiscalEmailAssuntoAlterado
    extends EmpresaNotaFiscalEmailEvent {
  final String assunto;

  EmpresaNotaFiscalEmailAssuntoAlterado(this.assunto);
}

class EmpresaNotaFiscalEmailTemplateHtmlAlterado
    extends EmpresaNotaFiscalEmailEvent {
  final String templateHtml;

  EmpresaNotaFiscalEmailTemplateHtmlAlterado(this.templateHtml);
}

class EmpresaNotaFiscalEmailSalvar extends EmpresaNotaFiscalEmailEvent {}
