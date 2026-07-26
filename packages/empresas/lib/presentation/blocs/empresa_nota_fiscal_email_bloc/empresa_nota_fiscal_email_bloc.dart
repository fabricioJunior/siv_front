import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:empresas/domain/entities/empresa_nota_fiscal_email.dart';
import 'package:empresas/use_cases.dart';

part 'empresa_nota_fiscal_email_event.dart';
part 'empresa_nota_fiscal_email_state.dart';

class EmpresaNotaFiscalEmailBloc
    extends Bloc<EmpresaNotaFiscalEmailEvent, EmpresaNotaFiscalEmailState> {
  final RecuperarConfiguracaoNotaFiscalEmail recuperarConfiguracaoNotaFiscalEmail;
  final AtualizarConfiguracaoNotaFiscalEmail atualizarConfiguracaoNotaFiscalEmail;

  EmpresaNotaFiscalEmailBloc(
    this.recuperarConfiguracaoNotaFiscalEmail,
    this.atualizarConfiguracaoNotaFiscalEmail,
  ) : super(const EmpresaNotaFiscalEmailState()) {
    on<EmpresaNotaFiscalEmailIniciou>(_onIniciou);
    on<EmpresaNotaFiscalEmailAtivoAlterado>(_onAtivoAlterado);
    on<EmpresaNotaFiscalEmailAssuntoAlterado>(_onAssuntoAlterado);
    on<EmpresaNotaFiscalEmailTemplateHtmlAlterado>(_onTemplateHtmlAlterado);
    on<EmpresaNotaFiscalEmailSalvar>(_onSalvar);
  }

  FutureOr<void> _onIniciou(
    EmpresaNotaFiscalEmailIniciou event,
    Emitter<EmpresaNotaFiscalEmailState> emit,
  ) async {
    emit(state.copyWith(carregando: true, erro: null));
    try {
      final configuracao = await recuperarConfiguracaoNotaFiscalEmail.call(
        event.empresaId,
      );
      emit(
        state.copyWith(
          empresaId: event.empresaId,
          ativo: configuracao.ativo,
          assunto: configuracao.assunto ?? '',
          templateHtml: configuracao.templateHtml ?? '',
          carregando: false,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          carregando: false,
          erro: 'Falha ao carregar configuração de nota fiscal por e-mail.',
        ),
      );
    }
  }

  FutureOr<void> _onAtivoAlterado(
    EmpresaNotaFiscalEmailAtivoAlterado event,
    Emitter<EmpresaNotaFiscalEmailState> emit,
  ) {
    emit(state.copyWith(ativo: event.ativo));
  }

  FutureOr<void> _onAssuntoAlterado(
    EmpresaNotaFiscalEmailAssuntoAlterado event,
    Emitter<EmpresaNotaFiscalEmailState> emit,
  ) {
    emit(state.copyWith(assunto: event.assunto));
  }

  FutureOr<void> _onTemplateHtmlAlterado(
    EmpresaNotaFiscalEmailTemplateHtmlAlterado event,
    Emitter<EmpresaNotaFiscalEmailState> emit,
  ) {
    emit(state.copyWith(templateHtml: event.templateHtml));
  }

  FutureOr<void> _onSalvar(
    EmpresaNotaFiscalEmailSalvar event,
    Emitter<EmpresaNotaFiscalEmailState> emit,
  ) async {
    if (state.empresaId == null) {
      return;
    }

    emit(state.copyWith(salvando: true, erro: null, salvou: false));
    try {
      final configuracao = EmpresaNotaFiscalEmail.create(
        empresaId: state.empresaId!,
        ativo: state.ativo,
        assunto: state.assunto,
        templateHtml: state.templateHtml,
      );

      final salvo = await atualizarConfiguracaoNotaFiscalEmail.call(
        configuracao,
      );

      emit(
        state.copyWith(
          ativo: salvo.ativo,
          assunto: salvo.assunto ?? '',
          templateHtml: salvo.templateHtml ?? '',
          salvando: false,
          salvou: true,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          salvando: false,
          erro: 'Falha ao salvar configuração de nota fiscal por e-mail.',
        ),
      );
    }
  }
}
