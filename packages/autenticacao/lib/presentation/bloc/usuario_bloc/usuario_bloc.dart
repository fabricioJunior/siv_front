import 'dart:async';

import 'package:autenticacao/domain/usecases/recuperar_usuario.dart';
import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'usuario_event.dart';
part 'usuario_state.dart';

class UsuarioBloc extends Bloc<UsuarioEvent, UsuarioState> {
  final RecuperarUsuario _recuperarUsuario;
  final SalvarUsuario _salvarUsuario;
  final RecuperarGrupoDeAcessoDoUsuario _recuperarGrupoDeAcessoDoUsuario;
  final VincularUsuarioAoGrupoDeAcesso _vincularUsuarioAoGrupoDeAcesso;

  UsuarioBloc(
    this._recuperarUsuario,
    this._salvarUsuario,
    this._recuperarGrupoDeAcessoDoUsuario,
    this._vincularUsuarioAoGrupoDeAcesso,
  ) : super(UsuarioNaoInicializado()) {
    on<UsuarioIniciou>(_onUsuarioIniciou);
    on<UsuarioEditou>(_onUsuarioEditou);
    on<UsuarioSalvou>(_onUsuarioSalvou);
  }

  FutureOr<void> _onUsuarioIniciou(
    UsuarioIniciou event,
    Emitter<UsuarioState> emit,
  ) async {
    if (event.idUsuario == null) {
      emit(UsuarioEditarEmProgresso.empty());
      return;
    }
    try {
      emit(UsuarioCarregarEmProgresso());
      var usuario = await _recuperarUsuario(event.idUsuario);

      if (usuario == null) {
        emit(UsuarioCarregarFalha());
        return;
      }
      GrupoDeAcesso? grupoDeAcesso =
          await _recuperarGrupoDeAcessoDoUsuario(idUsuario: event.idUsuario!);
      emit(
        UsuarioCarregarSucesso(
          usuario: usuario,
          grupoDeAcesso: grupoDeAcesso,
        ),
      );
    } catch (e, s) {
      emit(UsuarioCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onUsuarioEditou(
    UsuarioEditou event,
    Emitter<UsuarioState> emit,
  ) async {
    if (state is UsuarioCarregarSucesso || state is UsuarioSalvarSucesso) {
      emit(UsuarioEditarEmProgresso(state.usuario));
    }
    if (state is UsuarioEditarEmProgresso) {
      emit(
        UsuarioEditarEmProgresso.fromLastState(
          state as UsuarioEditarEmProgresso,
          login: event.login,
          nome: event.nome,
          senha: event.senha,
          tipo: event.tipo,
          grupoDeAcesso: event.grupoDeAcesso,
        ),
      );
    }
  }

  Future<void> _onUsuarioSalvou(
    UsuarioSalvou event,
    Emitter<UsuarioState> emit,
  ) async {
    try {
      var informacoesDoUsuario = state as UsuarioEditarEmProgresso;
      emit(UsuarioSalvarEmProgresso());
      if (informacoesDoUsuario.grupoDeAcesso != null) {
        _vincularUsuarioAoGrupoDeAcesso.call(
          idUsuario: informacoesDoUsuario.usuario!.id,
          idGrupoDeAcesso: informacoesDoUsuario.grupoDeAcesso!.id,
        );
      }
      var usuario = await _salvarUsuario.call(
        usuario: informacoesDoUsuario.usuario,
        login: informacoesDoUsuario.login,
        nome: informacoesDoUsuario.nome!,
        senha: informacoesDoUsuario.senha,
        tipo: informacoesDoUsuario.tipo ?? TipoUsuario.padrao,
      );

      emit(UsuarioSalvarSucesso(usuario: usuario));
    } catch (e, s) {
      emit(UsuarioSalvarFalha());
      addError(e, s);
    }
  }
}
