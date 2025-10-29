import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
part 'vinculos_grupo_de_acesso_usuario_event.dart';
part 'vinculos_grupo_de_acesso_usuario_state.dart';

class VinculosGrupoDeAcessoUsuarioBloc extends Bloc<
    VinculosGrupoDeAcessoUsuarioEvent, VinculosGrupoDeAcessoUsuarioState> {
  final RecuperarVinculosGrupoDeAcessoDoUsuario
      _recuperarVinculosGrupoDeAcessoDoUsuario;
  final VincularUsuarioAoGrupoDeAcesso _vincularGrupoDeAcessoAoUsuario;

  final RecuperarEmpresas _recuperarEmpresas;

  VinculosGrupoDeAcessoUsuarioBloc(
      this._recuperarVinculosGrupoDeAcessoDoUsuario,
      this._recuperarEmpresas,
      this._vincularGrupoDeAcessoAoUsuario)
      : super(VinculosGrupoDeAcessoUsuarioInitial()) {
    on<VinculosGrupoDeAcessoIniciou>(_onVinculosGrupoDeAcessoIniciou);
    on<VinculosGrupoDeAcessoVinculou>(_onVinculosGrupoDeAcessoVinculou);
  }

  FutureOr<void> _onVinculosGrupoDeAcessoIniciou(
    VinculosGrupoDeAcessoIniciou event,
    Emitter<VinculosGrupoDeAcessoUsuarioState> emit,
  ) async {
    try {
      emit(
        VinculosGrupoDeAcessoUsuarioCarregarEmProgresso(
          idUsuario: event.idUsuario,
        ),
      );
      var vinculosDoUsuario =
          await _recuperarVinculosGrupoDeAcessoDoUsuario.call(
        idUsuario: event.idUsuario,
      );
      var empresas = await _recuperarEmpresas.call();

      emit(
        VinculosGrupoDeAcessoUsuarioCarregarSucesso(
          vinculos: vinculosDoUsuario,
          idUsuario: event.idUsuario,
          empresas: empresas,
        ),
      );
    } catch (e, s) {
      emit(
        VinculosGrupoDeAcessoUsuarioCarregarFalha(
          idUsuario: event.idUsuario,
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onVinculosGrupoDeAcessoVinculou(
    VinculosGrupoDeAcessoVinculou event,
    Emitter<VinculosGrupoDeAcessoUsuarioState> emit,
  ) async {
    try {
      emit(
        VinculosGrupoDeAcessoUsuarioVincularEmProgresso(
          idUsuario: state.idUsuario,
        ),
      );

      await _vincularGrupoDeAcessoAoUsuario.call(
        idUsuario: state.idUsuario!,
        idGrupoDeAcesso: event.idGrupoDeAcesso,
        idEmpresa: event.idEmpresa,
      );
      var vinculosDoUsuario =
          await _recuperarVinculosGrupoDeAcessoDoUsuario.call(
        idUsuario: state.idUsuario!,
      );
      emit(
        VinculosGrupoDeAcessoUsuarioVincularSucesso(
          vinculos: vinculosDoUsuario,
          idUsuario: state.idUsuario!,
        ),
      );
    } catch (e, s) {
      emit(VinculosGrupoDeAcessoUsuarioVincularFalha(
        idUsuario: state.idUsuario,
      ));
      addError(e, s);
    }
  }
}
