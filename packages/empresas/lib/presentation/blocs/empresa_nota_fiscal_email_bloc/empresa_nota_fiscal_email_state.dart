part of 'empresa_nota_fiscal_email_bloc.dart';

const Object _sentinela = Object();

class EmpresaNotaFiscalEmailState extends Equatable {
  final int? empresaId;
  final bool ativo;
  final String assunto;
  final String templateHtml;
  final bool carregando;
  final bool salvando;
  final bool salvou;
  final String? erro;

  const EmpresaNotaFiscalEmailState({
    this.empresaId,
    this.ativo = false,
    this.assunto = '',
    this.templateHtml = '',
    this.carregando = false,
    this.salvando = false,
    this.salvou = false,
    this.erro,
  });

  EmpresaNotaFiscalEmailState copyWith({
    int? empresaId,
    bool? ativo,
    String? assunto,
    String? templateHtml,
    bool? carregando,
    bool? salvando,
    bool? salvou,
    Object? erro = _sentinela,
  }) {
    return EmpresaNotaFiscalEmailState(
      empresaId: empresaId ?? this.empresaId,
      ativo: ativo ?? this.ativo,
      assunto: assunto ?? this.assunto,
      templateHtml: templateHtml ?? this.templateHtml,
      carregando: carregando ?? this.carregando,
      salvando: salvando ?? this.salvando,
      salvou: salvou ?? this.salvou,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
    );
  }

  @override
  List<Object?> get props => [
        empresaId,
        ativo,
        assunto,
        templateHtml,
        carregando,
        salvando,
        salvou,
        erro,
      ];
}
