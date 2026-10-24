import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/domain/entities/desconto_fidelidade.dart';
import 'package:empresas/use_cases.dart';

sealed class DescontosFidelidadeEvent {}

class DescontosFidelidadeCarregou extends DescontosFidelidadeEvent {
  final int empresaId;
  DescontosFidelidadeCarregou(this.empresaId);
}

class DescontosFidelidadeSalvou extends DescontosFidelidadeEvent {
  final DescontoFidelidade desconto;
  DescontosFidelidadeSalvou(this.desconto);
}

class DescontosFidelidadeExcluiu extends DescontosFidelidadeEvent {
  final int id;
  DescontosFidelidadeExcluiu(this.id);
}

class DescontosFidelidadeState extends Equatable {
  final bool carregando;
  final List<DescontoFidelidade> faixas;
  final String? erro;

  const DescontosFidelidadeState({
    this.carregando = true,
    this.faixas = const [],
    this.erro,
  });

  @override
  List<Object?> get props => [carregando, faixas, erro];
}

class DescontosFidelidadeBloc
    extends Bloc<DescontosFidelidadeEvent, DescontosFidelidadeState> {
  final ListarDescontosFidelidade _listar;
  final SalvarDescontoFidelidade _salvar;
  final ExcluirDescontoFidelidade _excluir;
  int _empresaId = 0;

  DescontosFidelidadeBloc(this._listar, this._salvar, this._excluir)
      : super(const DescontosFidelidadeState()) {
    on<DescontosFidelidadeCarregou>((e, emit) async {
      _empresaId = e.empresaId;
      await _recarregar(emit);
    });
    on<DescontosFidelidadeSalvou>((e, emit) async {
      await _executar(emit, () => _salvar(_empresaId, e.desconto));
    });
    on<DescontosFidelidadeExcluiu>((e, emit) async {
      await _executar(emit, () => _excluir(_empresaId, e.id));
    });
  }

  Future<void> _executar(
    Emitter<DescontosFidelidadeState> emit,
    Future<void> Function() acao,
  ) async {
    try {
      await acao();
    } catch (err) {
      emit(DescontosFidelidadeState(
        carregando: false,
        faixas: state.faixas,
        erro: mensagemDeErroApi(err, 'Falha ao salvar o desconto.'),
      ));
      return;
    }
    await _recarregar(emit);
  }

  Future<void> _recarregar(Emitter<DescontosFidelidadeState> emit) async {
    try {
      emit(DescontosFidelidadeState(
        carregando: false,
        faixas: await _listar(_empresaId),
      ));
    } catch (err) {
      emit(DescontosFidelidadeState(
        carregando: false,
        faixas: state.faixas,
        erro: mensagemDeErroApi(err, 'Falha ao carregar os descontos.'),
      ));
    }
  }
}
