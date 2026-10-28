import 'package:comercial/domain/models/contagem_em_andamento.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

const tamanhoPaginaContagens = 30;

class ContagensEmAndamentoState extends Equatable {
  final bool carregando;
  final bool carregandoMais;
  final String? erro;
  final List<ContagemEmAndamento> itens;
  final int total;
  final int totalDoFuncionario;
  final String busca;
  final bool minhas;

  const ContagensEmAndamentoState({
    this.carregando = true,
    this.carregandoMais = false,
    this.erro,
    this.itens = const [],
    this.total = 0,
    this.totalDoFuncionario = 0,
    this.busca = '',
    this.minhas = false,
  });

  /// Total do filtro ativo (Todas / Minhas): é o que a paginação precisa alcançar.
  int get totalDoFiltro => minhas ? totalDoFuncionario : total;
  bool get temMais => itens.length < totalDoFiltro;

  ContagensEmAndamentoState copyWith({
    bool? carregando,
    bool? carregandoMais,
    String? erro,
    bool limparErro = false,
    List<ContagemEmAndamento>? itens,
    int? total,
    int? totalDoFuncionario,
    String? busca,
    bool? minhas,
  }) => ContagensEmAndamentoState(
    carregando: carregando ?? this.carregando,
    carregandoMais: carregandoMais ?? this.carregandoMais,
    erro: limparErro ? null : (erro ?? this.erro),
    itens: itens ?? this.itens,
    total: total ?? this.total,
    totalDoFuncionario: totalDoFuncionario ?? this.totalDoFuncionario,
    busca: busca ?? this.busca,
    minhas: minhas ?? this.minhas,
  );

  @override
  List<Object?> get props => [
    carregando,
    carregandoMais,
    erro,
    itens,
    total,
    totalDoFuncionario,
    busca,
    minhas,
  ];
}

/// Lista das contagens abertas. "Minhas" filtra pelo [funcionarioId] (último
/// funcionário escolhido neste aparelho ao iniciar uma contagem).
class ContagensEmAndamentoCubit extends Cubit<ContagensEmAndamentoState> {
  final ObterContagensEmAndamento _obter;
  int? funcionarioId;
  int _pagina = 1;
  int _requisicao = 0;

  ContagensEmAndamentoCubit(this._obter, {this.funcionarioId})
    : super(const ContagensEmAndamentoState());

  Future<void> carregar() async {
    final id = ++_requisicao;
    _pagina = 1;
    emit(state.copyWith(carregando: true, limparErro: true));
    try {
      final r = await _buscar(1);
      if (id != _requisicao) return;
      emit(
        state.copyWith(
          carregando: false,
          itens: r.itens,
          total: r.total,
          totalDoFuncionario: r.totalDoFuncionario,
        ),
      );
    } catch (e) {
      if (id != _requisicao) return;
      emit(state.copyWith(carregando: false, erro: '$e'));
    }
  }

  Future<void> buscar(String termo) async {
    if (termo.trim() == state.busca) return;
    emit(state.copyWith(busca: termo.trim()));
    await carregar();
  }

  Future<void> filtrar({required bool minhas}) async {
    if (minhas == state.minhas) return;
    emit(state.copyWith(minhas: minhas));
    await carregar();
  }

  Future<void> maisItens() async {
    if (state.carregando || state.carregandoMais || !state.temMais) return;
    final id = _requisicao;
    emit(state.copyWith(carregandoMais: true));
    try {
      final r = await _buscar(_pagina + 1);
      if (id != _requisicao) return;
      _pagina++;
      emit(
        state.copyWith(
          carregandoMais: false,
          itens: [...state.itens, ...r.itens],
          total: r.total,
          totalDoFuncionario: r.totalDoFuncionario,
        ),
      );
    } catch (_) {
      if (id == _requisicao) emit(state.copyWith(carregandoMais: false));
    }
  }

  Future<ContagensEmAndamentoPagina> _buscar(int pagina) => _obter(
    busca: state.busca,
    // O contador "Minhas" vem sempre que há funcionário; a lista só é filtrada em "Minhas".
    funcionarioId: funcionarioId,
    minhas: state.minhas,
    pagina: pagina,
    tamanho: tamanhoPaginaContagens,
  );
}
