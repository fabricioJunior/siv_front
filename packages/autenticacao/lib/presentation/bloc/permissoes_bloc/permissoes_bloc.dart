import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:autenticacao/domain/models/permissao.dart';
import 'package:autenticacao/domain/usecases/recuperar_permissoes.dart';

part 'permissoes_event.dart';
part 'permissoes_state.dart';

class PermissoesBloc extends Bloc<PermissoesEvent, PermissoesState> {
  final RecuperarPermissoes recuperarPermissoes;

  PermissoesBloc({required this.recuperarPermissoes})
      : super(PermissoesInicial()) {
    on<PermissoesIniciou>(_onPermissoesIniciou);
    on<PermissoesSelecionou>(_onPermissoesSelecionou);
    on<PermissoesDesselecionou>(_onPermissoesDesselecionou);
  }

  Future<void> _onPermissoesIniciou(
    PermissoesIniciou event,
    Emitter<PermissoesState> emit,
  ) async {
    emit(PermissoesCarregarEmProgesso());
    try {
      final permissoes = await recuperarPermissoes();
      emit(PermissoesCarregarSucesso(permissoes: permissoes.toList()));
    } catch (e) {
      emit(const PermissoesCarregarFalha(mensagem: 'Erro desconhecido'));
    }
  }

  Future<void> _onPermissoesSelecionou(
    PermissoesSelecionou event,
    Emitter<PermissoesState> emit,
  ) async {
    final permissoes = state is PermissoesSelecionarSucesso
        ? (state as PermissoesSelecionarSucesso).permissoesSelecionadas
        : <Permissao>[];
    final permissao = event.permissao;
    final permissoesSelecionadas = [...permissoes, permissao];
    emit(PermissoesSelecionarSucesso(
      permissoesSelecionadas: permissoesSelecionadas,
      permissoes: state.permissoes ?? <Permissao>[],
    ));
  }

  Future<void> _onPermissoesDesselecionou(
    PermissoesDesselecionou event,
    Emitter<PermissoesState> emit,
  ) async {
    final permissoes =
        (state as PermissoesSelecionarSucesso).permissoesSelecionadas;
    final permissao = event.permissao;
    final permissoesSelecionadas =
        permissoes.where((p) => p != permissao).toList();
    emit(
      PermissoesSelecionarSucesso(
        permissoesSelecionadas: permissoesSelecionadas,
        permissoes: state.permissoes ?? <Permissao>[],
      ),
    );
  }
}
