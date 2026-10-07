import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

/// Tela "Por fluxo" do grupo de acesso: carrega o estado das ações do
/// catálogo e liga/desliga ações. As alterações ficam pendentes (só locais) e
/// vão ao servidor numa única chamada em [AcoesDoGrupoSalvou]; ele devolve o
/// estado resolvido (dependências, permissões órfãs).
sealed class AcoesDoGrupoEvent {}

class AcoesDoGrupoCarregou extends AcoesDoGrupoEvent {
  final int idGrupoDeAcesso;
  AcoesDoGrupoCarregou(this.idGrupoDeAcesso);
}

class AcoesDoGrupoAlternou extends AcoesDoGrupoEvent {
  final String idAcao;
  final bool ligar;
  AcoesDoGrupoAlternou(this.idAcao, {required this.ligar});
}

/// "Completar" uma ação incompleta: pendência de ligar mesmo já "ligada".
class AcoesDoGrupoCompletou extends AcoesDoGrupoEvent {
  final String idAcao;
  AcoesDoGrupoCompletou(this.idAcao);
}

class AcoesDoGrupoDescartou extends AcoesDoGrupoEvent {}

class AcoesDoGrupoSalvou extends AcoesDoGrupoEvent {}

enum AcoesDoGrupoStatus { carregando, pronto, aplicando, falha }

class AcoesDoGrupoState extends Equatable {
  final AcoesDoGrupoStatus status;
  final AcoesDoGrupo? acoes;
  final String? mensagemDeErro;

  /// Alterações ainda não salvas: id da ação -> ligar (true) / desligar.
  final Map<String, bool> pendentes;

  /// Incrementa a cada alteração aplicada com sucesso: quem escuta usa pra
  /// recarregar a lista de permissões individuais.
  final int aplicacoes;

  const AcoesDoGrupoState({
    this.status = AcoesDoGrupoStatus.carregando,
    this.acoes,
    this.mensagemDeErro,
    this.pendentes = const {},
    this.aplicacoes = 0,
  });

  bool get temPendencias => pendentes.isNotEmpty;

  /// Estado exibido: pendência (se houver) ou o do servidor.
  bool ligada(AcaoDoGrupo a) =>
      pendentes[a.id] ?? a.estado != EstadoAcaoDoGrupo.desligada;

  AcoesDoGrupoState copyWith({
    AcoesDoGrupoStatus? status,
    AcoesDoGrupo? acoes,
    String? mensagemDeErro,
    Map<String, bool>? pendentes,
    int? aplicacoes,
  }) =>
      AcoesDoGrupoState(
        status: status ?? this.status,
        acoes: acoes ?? this.acoes,
        mensagemDeErro: mensagemDeErro,
        pendentes: pendentes ?? this.pendentes,
        aplicacoes: aplicacoes ?? this.aplicacoes,
      );

  @override
  List<Object?> get props => [status, acoes, mensagemDeErro, pendentes, aplicacoes];
}

class AcoesDoGrupoBloc extends Bloc<AcoesDoGrupoEvent, AcoesDoGrupoState> {
  final RecuperarAcoesDoGrupoDeAcesso _recuperar;
  final AplicarAcoesDoGrupoDeAcesso _aplicar;
  int? _idGrupo;

  AcoesDoGrupoBloc(this._recuperar, this._aplicar)
      : super(const AcoesDoGrupoState()) {
    on<AcoesDoGrupoCarregou>(_onCarregou);
    on<AcoesDoGrupoAlternou>(_onAlternou);
    on<AcoesDoGrupoCompletou>(_onCompletou);
    on<AcoesDoGrupoDescartou>(
      (_, emit) => emit(state.copyWith(pendentes: const {})),
    );
    on<AcoesDoGrupoSalvou>(_onSalvou);
  }

  Future<void> _onCarregou(
    AcoesDoGrupoCarregou event,
    Emitter<AcoesDoGrupoState> emit,
  ) async {
    _idGrupo = event.idGrupoDeAcesso;
    emit(state.copyWith(status: AcoesDoGrupoStatus.carregando));
    try {
      final acoes = await _recuperar(event.idGrupoDeAcesso);
      emit(state.copyWith(
        status: AcoesDoGrupoStatus.pronto,
        acoes: acoes,
        pendentes: const {},
      ));
    } catch (e, s) {
      emit(state.copyWith(
        status: AcoesDoGrupoStatus.falha,
        mensagemDeErro: 'Não foi possível carregar as ações do grupo.',
      ));
      addError(e, s);
    }
  }

  Map<String, AcaoDoGrupo> get _porId => {
        for (final f in state.acoes?.fluxos ?? const <FluxoDoGrupo>[])
          for (final a in f.acoes) a.id: a,
      };

  void _onAlternou(AcoesDoGrupoAlternou event, Emitter<AcoesDoGrupoState> emit) {
    if (state.status == AcoesDoGrupoStatus.aplicando) return;
    final porId = _porId;
    if (!porId.containsKey(event.idAcao)) return;
    final pendentes = {...state.pendentes};
    final visitados = <String>{};

    void definir(AcaoDoGrupo a) {
      if (!visitados.add(a.id)) return;
      final original = a.estado != EstadoAcaoDoGrupo.desligada;
      if (event.ligar == original) {
        pendentes.remove(a.id);
      } else {
        pendentes[a.id] = event.ligar;
      }
      // ponytail: regra local mínima; o servidor resolve o resto ao salvar.
      if (event.ligar) {
        for (final r in a.requer) {
          final req = porId[r];
          if (req != null && !_ligadaCom(pendentes, req)) {
            definir(req);
          }
        }
      } else {
        for (final d in porId.values) {
          if (d.requer.contains(a.id) && _ligadaCom(pendentes, d)) {
            definir(d);
          }
        }
      }
    }

    definir(porId[event.idAcao]!);
    emit(state.copyWith(pendentes: pendentes));
  }

  bool _ligadaCom(Map<String, bool> pendentes, AcaoDoGrupo a) =>
      pendentes[a.id] ?? a.estado != EstadoAcaoDoGrupo.desligada;

  void _onCompletou(AcoesDoGrupoCompletou event, Emitter<AcoesDoGrupoState> emit) {
    if (state.status == AcoesDoGrupoStatus.aplicando) return;
    emit(state.copyWith(pendentes: {...state.pendentes, event.idAcao: true}));
  }

  Future<void> _onSalvou(
    AcoesDoGrupoSalvou event,
    Emitter<AcoesDoGrupoState> emit,
  ) async {
    final id = _idGrupo;
    if (id == null ||
        !state.temPendencias ||
        state.status == AcoesDoGrupoStatus.aplicando) {
      return;
    }
    emit(state.copyWith(status: AcoesDoGrupoStatus.aplicando));
    try {
      final acoes = await _aplicar(
        idGrupoDeAcesso: id,
        ativar: [
          for (final e in state.pendentes.entries)
            if (e.value) e.key,
        ],
        desativar: [
          for (final e in state.pendentes.entries)
            if (!e.value) e.key,
        ],
      );
      emit(state.copyWith(
        status: AcoesDoGrupoStatus.pronto,
        acoes: acoes,
        pendentes: const {},
        aplicacoes: state.aplicacoes + 1,
      ));
    } catch (e, s) {
      // Mantém as pendências: nada foi aplicado (tudo-ou-nada no servidor).
      emit(state.copyWith(
        status: AcoesDoGrupoStatus.falha,
        mensagemDeErro:
            mensagemDeErroApi(e, 'Não foi possível salvar as permissões.'),
      ));
      addError(e, s);
    }
  }
}
