import 'package:autenticacao/domain/usecases/grupos_de_acesso/recuperar_grupo_de_acessos.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';

part 'grupos_de_acesso_event.dart';
part 'grupos_de_acesso_state.dart';

class GruposDeAcessoBloc
    extends Bloc<GruposDeAcessoEvent, GruposDeAcessoState> {
  final RecuperarGrupoDeAcessos _recuperarGrupoDeAcessos;
  GruposDeAcessoBloc(this._recuperarGrupoDeAcessos)
      : super(GruposDeAcessoInitial()) {
    on<GruposDeAcessoIniciouEvent>(_onGruposDeAcessoIniciou);
    on<GruposDeAcessoSelecionouEvent>(_onGrupoDeAcessoSelecionou);
    on<GruposDeAcessoDeselecionarEvent>(_onGruposDeAcessoDeselecionou);
  }

  Future<void> _onGruposDeAcessoIniciou(
    GruposDeAcessoIniciouEvent event,
    Emitter<GruposDeAcessoState> emit,
  ) async {
    emit(GruposDeAcessoCarregarEmProgresso());
    try {
      final grupos = await _recuperarGrupoDeAcessos.call();
      emit(
        GruposDeAcessoCarregarSucesso(
          grupos: grupos.toList(),
          gruposSelecionados: const [],
        ),
      );
    } catch (e) {
      emit(const GruposDeAcessoCarregarError(mensagem: 'Erro desconhecido'));
    }
  }

  void _onGrupoDeAcessoSelecionou(
    GruposDeAcessoSelecionouEvent event,
    Emitter<GruposDeAcessoState> emit,
  ) {
    if (state is GruposDeAcessoCarregarSucesso) {
      final currentState = state as GruposDeAcessoCarregarSucesso;
      final gruposSelecionados =
          List<GrupoDeAcesso>.from(currentState.gruposSelecionados)
            ..add(event.grupoDeAcesso);
      emit(currentState.copyWith(gruposSelecionados: gruposSelecionados));
    }
  }

  void _onGruposDeAcessoDeselecionou(GruposDeAcessoDeselecionarEvent event,
      Emitter<GruposDeAcessoState> emit) {
    if (state is GruposDeAcessoCarregarSucesso) {
      final currentState = state as GruposDeAcessoCarregarSucesso;
      final gruposSelecionados =
          List<GrupoDeAcesso>.from(currentState.gruposSelecionados)
            ..remove(event.grupoDeAcesso);
      emit(currentState.copyWith(gruposSelecionados: gruposSelecionados));
    }
  }
}
