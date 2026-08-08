import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';

part 'funcionario_vinculos_state.dart';
part 'funcionario_vinculos_event.dart';

class FuncionarioVinculosBloc
    extends Bloc<FuncionarioVinculosEvent, FuncionarioVinculosState> {
  final RecuperarVinculosFuncionario recuperarVinculosFuncionario;
  final VincularEmpresaFuncionario vincularEmpresaFuncionario;
  final DesativarVinculoFuncionario desativarVinculoFuncionario;
  final ReativarVinculoFuncionario reativarVinculoFuncionario;

  FuncionarioVinculosBloc(
    this.recuperarVinculosFuncionario,
    this.vincularEmpresaFuncionario,
    this.desativarVinculoFuncionario,
    this.reativarVinculoFuncionario,
  ) : super(
          const FuncionarioVinculosState(
            step: FuncionarioVinculosStep.inicial,
          ),
        ) {
    on<FuncionarioVinculosIniciou>(_onIniciou);
    on<FuncionarioVinculosEmpresaAdicionada>(_onEmpresaAdicionada);
    on<FuncionarioVinculosDesativarSolicitado>(_onDesativarSolicitado);
    on<FuncionarioVinculosReativarSolicitado>(_onReativarSolicitado);
  }

  FutureOr<void> _onIniciou(
    FuncionarioVinculosIniciou event,
    Emitter<FuncionarioVinculosState> emit,
  ) async {
    emit(state.copyWith(
      step: FuncionarioVinculosStep.carregando,
      idFuncionario: event.idFuncionario,
    ));

    try {
      final vinculos = await recuperarVinculosFuncionario.call(
        idFuncionario: event.idFuncionario,
      );
      emit(state.copyWith(
        step: FuncionarioVinculosStep.carregado,
        vinculos: vinculos,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: FuncionarioVinculosStep.falha,
        erro: 'Não foi possível carregar os vínculos do funcionário.',
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onEmpresaAdicionada(
    FuncionarioVinculosEmpresaAdicionada event,
    Emitter<FuncionarioVinculosState> emit,
  ) async {
    final idFuncionario = state.idFuncionario;
    if (idFuncionario == null) return;

    emit(state.copyWith(
      processandoEmpresaId: event.idEmpresa,
      limparErro: true,
    ));

    try {
      final vinculo = await vincularEmpresaFuncionario.call(
        idFuncionario: idFuncionario,
        idEmpresa: event.idEmpresa,
      );

      final vinculos = [
        ...state.vinculos.where((v) => v.empresaId != vinculo.empresaId),
        vinculo,
      ];

      emit(state.copyWith(
        vinculos: vinculos,
        limparProcessandoEmpresaId: true,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        erro: mensagemDeErroApi(
          e,
          'Não foi possível vincular a empresa ao funcionário.',
        ),
        limparProcessandoEmpresaId: true,
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onDesativarSolicitado(
    FuncionarioVinculosDesativarSolicitado event,
    Emitter<FuncionarioVinculosState> emit,
  ) async {
    final idFuncionario = state.idFuncionario;
    if (idFuncionario == null) return;

    emit(state.copyWith(
      processandoEmpresaId: event.idEmpresa,
      limparErro: true,
    ));

    try {
      await desativarVinculoFuncionario.call(
        idFuncionario: idFuncionario,
        idEmpresa: event.idEmpresa,
      );

      emit(state.copyWith(
        vinculos: _atualizarAtivo(state.vinculos, event.idEmpresa, false),
        limparProcessandoEmpresaId: true,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        erro: mensagemDeErroApi(
          e,
          'Não foi possível desativar o vínculo com a empresa.',
        ),
        limparProcessandoEmpresaId: true,
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onReativarSolicitado(
    FuncionarioVinculosReativarSolicitado event,
    Emitter<FuncionarioVinculosState> emit,
  ) async {
    final idFuncionario = state.idFuncionario;
    if (idFuncionario == null) return;

    emit(state.copyWith(
      processandoEmpresaId: event.idEmpresa,
      limparErro: true,
    ));

    try {
      await reativarVinculoFuncionario.call(
        idFuncionario: idFuncionario,
        idEmpresa: event.idEmpresa,
      );

      emit(state.copyWith(
        vinculos: _atualizarAtivo(state.vinculos, event.idEmpresa, true),
        limparProcessandoEmpresaId: true,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        erro: mensagemDeErroApi(
          e,
          'Não foi possível reativar o vínculo com a empresa.',
        ),
        limparProcessandoEmpresaId: true,
      ));
      addError(e, s);
    }
  }

  List<FuncionarioEmpresaVinculo> _atualizarAtivo(
    List<FuncionarioEmpresaVinculo> vinculos,
    int idEmpresa,
    bool ativo,
  ) {
    return vinculos
        .map((v) => v.empresaId == idEmpresa ? v.copyWith(ativo: ativo) : v)
        .toList();
  }
}
