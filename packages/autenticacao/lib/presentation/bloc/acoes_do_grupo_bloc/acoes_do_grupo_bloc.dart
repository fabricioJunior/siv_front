import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

/// Tela "Por fluxo" do grupo de acesso: carrega o estado das ações do
/// catálogo e liga/desliga ações. Cada alteração é aplicada na hora no
/// servidor (ele devolve o novo estado), então a tela nunca mostra um estado
/// que o servidor não confirmou.
sealed class AcoesDoGrupoEvent {}

class AcoesDoGrupoCarregou extends AcoesDoGrupoEvent {
  final int idGrupoDeAcesso;
  AcoesDoGrupoCarregou(this.idGrupoDeAcesso);
}

class AcoesDoGrupoAlterou extends AcoesDoGrupoEvent {
  final List<String> ativar;
  final List<String> desativar;
  AcoesDoGrupoAlterou({this.ativar = const [], this.desativar = const []});
}

enum AcoesDoGrupoStatus { carregando, pronto, aplicando, falha }

class AcoesDoGrupoState extends Equatable {
  final AcoesDoGrupoStatus status;
  final AcoesDoGrupo? acoes;
  final String? mensagemDeErro;

  /// Incrementa a cada alteração aplicada com sucesso: quem escuta usa pra
  /// recarregar a lista de permissões individuais.
  final int aplicacoes;

  const AcoesDoGrupoState({
    this.status = AcoesDoGrupoStatus.carregando,
    this.acoes,
    this.mensagemDeErro,
    this.aplicacoes = 0,
  });

  AcoesDoGrupoState copyWith({
    AcoesDoGrupoStatus? status,
    AcoesDoGrupo? acoes,
    String? mensagemDeErro,
    int? aplicacoes,
  }) =>
      AcoesDoGrupoState(
        status: status ?? this.status,
        acoes: acoes ?? this.acoes,
        mensagemDeErro: mensagemDeErro,
        aplicacoes: aplicacoes ?? this.aplicacoes,
      );

  @override
  List<Object?> get props => [status, acoes, mensagemDeErro, aplicacoes];
}

class AcoesDoGrupoBloc extends Bloc<AcoesDoGrupoEvent, AcoesDoGrupoState> {
  final RecuperarAcoesDoGrupoDeAcesso _recuperar;
  final AplicarAcoesDoGrupoDeAcesso _aplicar;
  int? _idGrupo;

  AcoesDoGrupoBloc(this._recuperar, this._aplicar)
      : super(const AcoesDoGrupoState()) {
    on<AcoesDoGrupoCarregou>(_onCarregou);
    on<AcoesDoGrupoAlterou>(_onAlterou);
  }

  Future<void> _onCarregou(
    AcoesDoGrupoCarregou event,
    Emitter<AcoesDoGrupoState> emit,
  ) async {
    _idGrupo = event.idGrupoDeAcesso;
    emit(state.copyWith(status: AcoesDoGrupoStatus.carregando));
    try {
      final acoes = await _recuperar(event.idGrupoDeAcesso);
      emit(state.copyWith(status: AcoesDoGrupoStatus.pronto, acoes: acoes));
    } catch (e, s) {
      emit(state.copyWith(
        status: AcoesDoGrupoStatus.falha,
        mensagemDeErro: 'Não foi possível carregar as ações do grupo.',
      ));
      addError(e, s);
    }
  }

  Future<void> _onAlterou(
    AcoesDoGrupoAlterou event,
    Emitter<AcoesDoGrupoState> emit,
  ) async {
    final id = _idGrupo;
    if (id == null || state.status == AcoesDoGrupoStatus.aplicando) return;
    emit(state.copyWith(status: AcoesDoGrupoStatus.aplicando));
    try {
      final acoes = await _aplicar(
        idGrupoDeAcesso: id,
        ativar: event.ativar,
        desativar: event.desativar,
      );
      emit(state.copyWith(
        status: AcoesDoGrupoStatus.pronto,
        acoes: acoes,
        aplicacoes: state.aplicacoes + 1,
      ));
    } catch (e, s) {
      // Mantém o último estado confirmado e só avisa: nada foi aplicado.
      emit(state.copyWith(
        status: AcoesDoGrupoStatus.falha,
        mensagemDeErro: 'Não foi possível aplicar a alteração.',
      ));
      addError(e, s);
    }
  }
}
