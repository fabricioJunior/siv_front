import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';

part 'pessoa_state.dart';
part 'pessoa_event.dart';

class PessoaBloc extends Bloc<PessoaEvent, PessoaState> {
  final RecuperarPessoa recuperarPessoa;
  final SalvarPessoa salvarPessoa;
  final CriarPessoa criarPessoa;
  final CriarFuncionario criarFuncionario;

  PessoaBloc(
    this.recuperarPessoa,
    this.salvarPessoa,
    this.criarPessoa,
    this.criarFuncionario,
  ) : super(PessoaState(pessoaStep: PessoaStep.inicial)) {
    on<PessoaIniciou>(_onPessoaInicou);
    on<PessoaEditou>(_onPessoaEditou);
    on<PessoaSalvou>(_onPessoaSalvou);
  }

  FutureOr<void> _onPessoaInicou(
    PessoaIniciou event,
    Emitter<PessoaState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          pessoaStep: PessoaStep.carregando,
          tipoPessoa: event.tipoPessoa,
          tipoContato: TipoContato.celular,
          eCliente: true,
        ),
      );
      if (event.idPessoa != null) {
        var pessoa = await recuperarPessoa.call(idPessoa: event.idPessoa!);
        emit(PessoaState.fromModel(pessoa!));
      } else {
        emit(
          PessoaState(
            pessoaStep: PessoaStep.editando,
            tipoPessoa: event.tipoPessoa,
            tipoContato: TipoContato.celular,
            eCliente: true,
          ),
        );
      }
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onPessoaEditou(
    PessoaEditou event,
    Emitter<PessoaState> emit,
  ) async {
    emit(
      state.copyWith(
        pessoaStep: PessoaStep.editando,
        bloqueado: event.bloqueado,
        contato: event.contato,
        documento: event.documento,
        eCliente: event.eCliente,
        eFornecedor: event.eFornecedor,
        email: event.email,
        inscricaoEstadual: event.inscricaoEstadual,
        nome: event.nome,
        tipoContato: event.tipoContato ?? TipoContato.celular,
        tipoPessoa: event.tipoPessoa,
        uf: event.uf,
        dataDeNascimento: event.dataDeNascimento,
        eFuncionario: event.eFuncionario,
        tipoFuncionario: event.tipoFuncionario,
        funcionarioEmpresaId: event.funcionarioEmpresaId,
        funcionarioInativo: event.funcionarioInativo,
      ),
    );
  }

  FutureOr<void> _onPessoaSalvou(
    PessoaSalvou event,
    Emitter<PessoaState> emit,
  ) async {
    try {
      emit(state.copyWith(
        pessoaStep: PessoaStep.carregando,
      ));
      if (state.pessoa != null) {
        var pessoa = await salvarPessoa.call(
            pessoa: state.pessoa!.copyWith(
          bloqueado: state.bloqueado,
          contato: state.contato,
          documento: state.documento,
          eCliente: state.eCliente,
          eFornecedor: state.eFornecedor,
          email: state.email,
          nome: state.nome,
          tipoContato: state.tipoContato,
          tipoPessoa: state.tipoPessoa,
          uf: state.uf,
          dataDeNascimento: state.dataDeNascimento,
        ));
        emit(PessoaState.fromModel(
          pessoa,
          step: PessoaStep.salva,
        ));
      } else {
        var pessoa = await criarPessoa.call(
          bloqueado: false,
          contato: state.contato!,
          documento: state.documento!,
          eCliente: state.eCliente ?? true,
          eFornecedor: state.eFornecedor ?? false,
          eFuncionario: state.eFuncionario ?? false,
          email: state.email,
          nome: state.nome!,
          tipoContato: state.tipoContato!,
          tipoPessoa: state.tipoPessoa!,
          uf: state.uf,
          dataDeNascimento: state.dataDeNascimento!,
        );

        if ((state.eFuncionario ?? false) && pessoa.id != null) {
          await criarFuncionario.call(
            funcionario: Funcionario(
              criadoEm: null,
              atualizadoEm: null,
              empresaId: state.funcionarioEmpresaId ?? 0,
              id: 0,
              nome: state.nome ?? '',
              pessoaId: pessoa.id!,
              tipo: state.tipoFuncionario ?? TipoFuncionario.comprador,
              inativo: state.funcionarioInativo,
            ),
          );
        }

        emit(PessoaState.fromModel(
          pessoa,
          step: PessoaStep.criada,
        ));
      }
    } catch (e, s) {
      addError(e, s);
    }
  }
}
