import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/use_cases.dart';

part 'abrir_consignacao_event.dart';
part 'abrir_consignacao_state.dart';

class AbrirConsignacaoBloc
    extends Bloc<AbrirConsignacaoEvent, AbrirConsignacaoState> {
  final AbrirConsignacao _abrirConsignacao;
  final RecuperarCaixaAberto _recuperarCaixaAberto;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  AbrirConsignacaoBloc(
    this._abrirConsignacao,
    this._recuperarCaixaAberto,
    this._acessoGlobalSessao,
  ) : super(const AbrirConsignacaoState()) {
    on<AbrirConsignacaoPessoaSelecionada>(_onPessoaSelecionada);
    on<AbrirConsignacaoFuncionarioSelecionado>(_onFuncionarioSelecionado);
    on<AbrirConsignacaoTabelaSelecionada>(_onTabelaSelecionada);
    on<AbrirConsignacaoObservacaoAlterada>(_onObservacaoAlterada);
    on<AbrirConsignacaoConfirmarSolicitado>(_onConfirmarSolicitado);
  }

  void _onPessoaSelecionada(
    AbrirConsignacaoPessoaSelecionada event,
    Emitter<AbrirConsignacaoState> emit,
  ) {
    emit(
      state.copyWith(
        pessoaSelecionada: event.pessoaSelecionada,
        limparPessoa: event.pessoaSelecionada == null,
        erro: null,
      ),
    );
  }

  void _onFuncionarioSelecionado(
    AbrirConsignacaoFuncionarioSelecionado event,
    Emitter<AbrirConsignacaoState> emit,
  ) {
    emit(
      state.copyWith(
        funcionarioSelecionado: event.funcionarioSelecionado,
        limparFuncionario: event.funcionarioSelecionado == null,
        erro: null,
      ),
    );
  }

  void _onTabelaSelecionada(
    AbrirConsignacaoTabelaSelecionada event,
    Emitter<AbrirConsignacaoState> emit,
  ) {
    emit(
      state.copyWith(
        tabelaSelecionada: event.tabelaSelecionada,
        limparTabela: event.tabelaSelecionada == null,
        erro: null,
      ),
    );
  }

  void _onObservacaoAlterada(
    AbrirConsignacaoObservacaoAlterada event,
    Emitter<AbrirConsignacaoState> emit,
  ) {
    emit(state.copyWith(observacao: event.observacao, erro: null));
  }

  FutureOr<void> _onConfirmarSolicitado(
    AbrirConsignacaoConfirmarSolicitado event,
    Emitter<AbrirConsignacaoState> emit,
  ) async {
    if (!state.podeConfirmar) {
      emit(
        state.copyWith(
          erro: 'Selecione cliente, vendedor e tabela de preço.',
        ),
      );
      return;
    }

    final empresaId = _acessoGlobalSessao.empresaIdDaSessao;
    final terminalId = _acessoGlobalSessao.terminalIdDaSessao;
    if (empresaId == null || terminalId == null) {
      emit(
        state.copyWith(
          erro: 'Sessão sem empresa/terminal definidos. Faça login novamente.',
        ),
      );
      return;
    }

    emit(state.copyWith(step: AbrirConsignacaoStep.salvando, erro: null));

    try {
      final caixa = await _recuperarCaixaAberto.call(
        idEmpresa: empresaId,
        idTerminal: terminalId,
      );

      if (caixa == null) {
        emit(
          state.copyWith(
            step: AbrirConsignacaoStep.editando,
            erro:
                'Nenhum caixa aberto para este terminal. Abra um caixa antes de continuar.',
          ),
        );
        return;
      }

      final consignacao = await _abrirConsignacao.call(
        pessoaId: state.pessoaSelecionada!.id,
        funcionarioId: state.funcionarioSelecionado!.id,
        tabelaPrecoId: state.tabelaSelecionada!.id,
        caixaAbertura: caixa.id,
        observacao: state.observacao.trim().isEmpty
            ? null
            : state.observacao.trim(),
      );

      emit(
        state.copyWith(
          step: AbrirConsignacaoStep.sucesso,
          consignacaoCriada: consignacao,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: AbrirConsignacaoStep.editando,
          erro: mensagemDeErroApi(e, 'Falha ao abrir a consignação.'),
        ),
      );
      addError(e, s);
    }
  }
}
