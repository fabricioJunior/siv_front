import 'package:autenticacao/domain/usecases/recuperar_grupo_de_acesso.dart';
import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

import '../../../domain/models/grupo_de_acesso.dart';

part 'grupo_de_acesso_event.dart';
part 'grupo_de_acesso_state.dart';

class GrupoDeAcessoBloc extends Bloc<GrupoDeAcessoEvent, GrupoDeAcessoState> {
  final CriarGrupoDeAcesso _criarGrupoDeAcesso;
  final AtualizarGrupoDeAcesso _atualizarGrupoDeAcesso;
  final RecuperarGrupoDeAcesso _recuperarGrupoDeAcesso;

  GrupoDeAcessoBloc(
    this._atualizarGrupoDeAcesso,
    this._criarGrupoDeAcesso,
    this._recuperarGrupoDeAcesso,
  ) : super(GrupoDeAcessoInitial()) {
    on<GrupoDeAcessoIniciouEvent>(_onGrupoDeAcessoIniciou);
    on<GrupoDeAcessoAlterouNomeEvent>(_onGrupoDeAcessoAlterouNome);
    on<GrupoDeAcessoAdionouPermissao>(_onGrupoDeAcessoAdionouPermissao);
    on<GrupoDeAcessoRemoveuPermissao>(_onGrupoDeAcessoRemoveuPermissao);
    on<GrupoDeAcessoSalvou>(_onGrupoDeAcessoSalvou);
  }

  Future<void> _onGrupoDeAcessoIniciou(
    GrupoDeAcessoIniciouEvent event,
    Emitter<GrupoDeAcessoState> emit,
  ) async {
    if (event.idGrupoDeAcesso == null) {
      emit(const GrupoDeAcessoEdicaoEmProgresso(
        nome: '',
        id: null,
      ));
    } else {
      emit(GrupoDeAcessoCarregarEmProgresso());

      var grupoDeAcesso =
          await _recuperarGrupoDeAcesso.call(event.idGrupoDeAcesso!);

      emit(GrupoDeAcessoCarregarSucesso());
      emit(
        GrupoDeAcessoEdicaoEmProgresso(
          nome: event.nome ?? '',
          id: event.idGrupoDeAcesso,
          grupoDeAcesso: grupoDeAcesso,
          permissoes: grupoDeAcesso?.permissoes.toList(),
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
    if (state is GrupoDeAcessoEdicaoEmProgresso) {
      final currentState = state as GrupoDeAcessoEdicaoEmProgresso;
      var permissoesAtualizadas =
          List<Permissao>.from(currentState.permissoes ?? [])
            ..add(event.permissao);
      emit(currentState.copyWith(permissoes: permissoesAtualizadas));
    }
  }

  void _onGrupoDeAcessoRemoveuPermissao(
    GrupoDeAcessoRemoveuPermissao event,
    Emitter<GrupoDeAcessoState> emit,
  ) async {
    if (state is GrupoDeAcessoEdicaoEmProgresso) {
      final currentState = state as GrupoDeAcessoEdicaoEmProgresso;
      var permissoesAtualizadas =
          List<Permissao>.from(currentState.permissoes ?? [])
            ..remove(event.permissao);
      emit(currentState.copyWith(permissoes: permissoesAtualizadas));
    }
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
        } else {
          grupoDeAcesso = await _atualizarGrupoDeAcesso(
            grupoDeAcesso: currentState.grupoDeAcesso!,
            novoNome: currentState.nome,
            permissoes: currentState.permissoes ??
                currentState.grupoDeAcesso!.permissoes.toList(),
          );
        }
        emit(GrupoDeAcessoSalvarSucesso(
          grupoDeAcesso: grupoDeAcesso,
        ));
      } catch (e) {
        emit(const GrupoDeAcessoSalvarFalha(
            mensagem: 'Erro ao salvar o grupo de acesso.'));
      }
    }
  }
}
