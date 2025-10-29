import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'grupo_de_acesso_event.dart';
part 'grupo_de_acesso_state.dart';

class GrupoDeAcessoBloc extends Bloc<GrupoDeAcessoEvent, GrupoDeAcessoState> {
  final CriarGrupoDeAcesso _criarGrupoDeAcesso;
  final AtualizarGrupoDeAcesso _atualizarGrupoDeAcesso;
  final RecuperarGrupoDeAcesso _recuperarGrupoDeAcesso;
  final RecuperarPermissoes _recuperarPermissoes;
  final ExcluirGrupoDeAcesso _excluirGrupoDeAcesso;
  GrupoDeAcessoBloc(
    this._atualizarGrupoDeAcesso,
    this._criarGrupoDeAcesso,
    this._recuperarGrupoDeAcesso,
    this._recuperarPermissoes,
    this._excluirGrupoDeAcesso,
  ) : super(GrupoDeAcessoInitial()) {
    on<GrupoDeAcessoIniciouEvent>(_onGrupoDeAcessoIniciou);
    on<GrupoDeAcessoAlterouNomeEvent>(_onGrupoDeAcessoAlterouNome);
    on<GrupoDeAcessoAdionouPermissao>(_onGrupoDeAcessoAdionouPermissao);
    on<GrupoDeAcessoRemoveuPermissao>(_onGrupoDeAcessoRemoveuPermissao);
    on<GrupoDeAcessoSalvou>(_onGrupoDeAcessoSalvou);
    on<GrupoExcluiu>(_onGrupoExcluiu);
  }

  Future<void> _onGrupoDeAcessoIniciou(
    GrupoDeAcessoIniciouEvent event,
    Emitter<GrupoDeAcessoState> emit,
  ) async {
    if (event.idGrupoDeAcesso == null) {
      var permissoes = await _recuperarPermissoes.call();
      emit(GrupoDeAcessoEdicaoEmProgresso(
        nome: '',
        id: null,
        permissoesNaoUtilizadasNoGrupo: permissoes.toList(),
      ));
    } else {
      emit(GrupoDeAcessoCarregarEmProgresso());

      var grupoDeAcesso =
          await _recuperarGrupoDeAcesso.call(event.idGrupoDeAcesso!);
      var permissoes = await _recuperarPermissoes.call();
      var permissoesDoGrupo = grupoDeAcesso?.permissoes;
      var permissoesNaoUtilizadasNoGrupo = permissoes
          .where(
              (permissao) => !(permissoesDoGrupo?.contains(permissao) ?? false))
          .toList();

      emit(GrupoDeAcessoCarregarSucesso());
      emit(
        GrupoDeAcessoEdicaoEmProgresso(
          nome: grupoDeAcesso?.nome ?? '',
          id: event.idGrupoDeAcesso,
          grupoDeAcesso: grupoDeAcesso,
          permissoesNaoUtilizadasNoGrupo: permissoesNaoUtilizadasNoGrupo,
          permissoesDoGrupo: permissoesDoGrupo,
        ),
      );
    }
  }

  void _onGrupoDeAcessoAlterouNome(
    GrupoDeAcessoAlterouNomeEvent event,
    Emitter<GrupoDeAcessoState> emit,
  ) {
    if (state is GrupoDeAcessoEdicaoEmProgresso) {
      final currentState = state as GrupoDeAcessoEdicaoEmProgresso;
      emit(currentState.copyWith(nome: event.nome));
    }
  }

  void _onGrupoDeAcessoAdionouPermissao(
    GrupoDeAcessoAdionouPermissao event,
    Emitter<GrupoDeAcessoState> emit,
  ) async {
    final currentState = state as GrupoDeAcessoEdicaoEmProgresso;
    var permissoesAtualizadas =
        List<Permissao>.from(currentState.permissoesDoGrupo ?? [])
          ..add(event.permissao);
    var permissoesNaoUtilizadasNoGrupo =
        List<Permissao>.from(currentState.permissoesNaoUtilizadasNoGrupo ?? [])
          ..remove(event.permissao);
    emit(
      GrupoDeAcessoEdicaoEmProgresso.fromLastState(
        state,
        permissoesDoGrupo: permissoesAtualizadas,
        permissoesNaoUtilizadasNoGrupo: permissoesNaoUtilizadasNoGrupo,
      ),
    );
  }

  void _onGrupoDeAcessoRemoveuPermissao(
    GrupoDeAcessoRemoveuPermissao event,
    Emitter<GrupoDeAcessoState> emit,
  ) async {
    final currentState = state;
    var permissoesAtualizadas =
        List<Permissao>.from(currentState.permissoesDoGrupo ?? [])
          ..remove(event.permissao);
    emit(
      GrupoDeAcessoEdicaoEmProgresso.fromLastState(
        state,
        permissoesDoGrupo: permissoesAtualizadas,
      ),
    );
  }

  Future<void> _onGrupoDeAcessoSalvou(
    GrupoDeAcessoSalvou event,
    Emitter<GrupoDeAcessoState> emit,
  ) async {
    if (state is GrupoDeAcessoEdicaoEmProgresso) {
      final currentState = state as GrupoDeAcessoEdicaoEmProgresso;
      emit(GrupoDeAcessoSalvarEmProgresso());
      try {
        GrupoDeAcesso? grupoDeAcesso;
        if (currentState.id == null) {
          grupoDeAcesso = await _criarGrupoDeAcesso(currentState.nome);
          grupoDeAcesso = await _atualizarGrupoDeAcesso(
            grupoDeAcesso: grupoDeAcesso,
            novoNome: currentState.nome,
            permissoesAtualizadas: currentState.permissoesDoGrupo ?? [],
          );
        } else {
          grupoDeAcesso = await _atualizarGrupoDeAcesso(
            grupoDeAcesso: currentState.grupoDeAcesso!,
            novoNome: currentState.nome,
            permissoesAtualizadas: currentState.permissoesDoGrupo ?? [],
          );
        }
        emit(
          GrupoDeAcessoSalvarSucesso(
            grupoDeAcesso: grupoDeAcesso,
            permissoesDoGrupo: currentState.permissoesDoGrupo,
            permissoesNaoUtilizadasNoGrupo:
                currentState.permissoesNaoUtilizadasNoGrupo,
          ),
        );
      } catch (e) {
        emit(const GrupoDeAcessoSalvarFalha(
            mensagem: 'Erro ao salvar o grupo de acesso.'));
      }
    }
  }

  FutureOr<void> _onGrupoExcluiu(
    GrupoExcluiu event,
    Emitter<GrupoDeAcessoState> emit,
  ) async {
    try {
      await _excluirGrupoDeAcesso.call(state.id ?? state.grupoDeAcesso!.id!);
      emit(GrupoDeAcessoExcluirGrupoSucesso());
    } catch (e, s) {
      emit(GrupoDeAcessoExcluirGrupoSucesso());
      addError(e, s);
    }
  }
}
