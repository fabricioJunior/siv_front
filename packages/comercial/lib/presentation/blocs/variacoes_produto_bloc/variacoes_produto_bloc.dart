import 'package:comercial/domain/models/variacao_opcao.dart';
import 'package:comercial/domain/use_cases/variacoes_produto_use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'variacoes_produto_event.dart';
part 'variacoes_produto_state.dart';

/// Cores, estampas e tamanhos da contagem: pré-carga ao abrir a página (os
/// modais em tela cheia só leem o estado) e cadastro de cor/estampa.
class VariacoesProdutoBloc
    extends Bloc<VariacoesProdutoEvent, VariacoesProdutoState> {
  final RecuperarCoresDeProdutos _cores;
  final RecuperarEstampasDeProdutos _estampas;
  final RecuperarTamanhosDeProdutos _tamanhos;
  final CriarCorDeProdutos _criarCor;
  final CriarEstampaDeProdutos _criarEstampa;

  VariacoesProdutoBloc(
    this._cores,
    this._estampas,
    this._tamanhos,
    this._criarCor,
    this._criarEstampa,
  ) : super(const VariacoesProdutoState()) {
    on<VariacoesCarregadas>((_, emit) => Future.wait([
          _ler<VariacaoOpcao>(emit, _cores.call, (s) => s.cores,
              (s, l) => s.copyWith(cores: l), 'cores'),
          _ler<VariacaoOpcao>(emit, _estampas.call, (s) => s.estampas,
              (s, l) => s.copyWith(estampas: l), 'estampas'),
          _ler<TamanhoOpcao>(emit, _tamanhos.call, (s) => s.tamanhos,
              (s, l) => s.copyWith(tamanhos: l), 'tamanhos'),
        ]));
    on<VariacoesCorCadastrada>((e, emit) => _cadastrar(
          emit,
          e.nome,
          _criarCor.call,
          _cores.call,
          (s) => s.cores,
          (s, l) => s.copyWith(cores: l),
        ));
    on<VariacoesEstampaCadastrada>((e, emit) => _cadastrar(
          emit,
          e.nome,
          _criarEstampa.call,
          _estampas.call,
          (s) => s.estampas,
          (s, l) => s.copyWith(estampas: l),
        ));
  }

  Future<void> _ler<T>(
    Emitter<VariacoesProdutoState> emit,
    Future<List<T>> Function() ler,
    VariacaoLista<T> Function(VariacoesProdutoState) get,
    VariacoesProdutoState Function(VariacoesProdutoState, VariacaoLista<T>) set,
    String nome,
  ) async {
    if (get(state).status == VariacaoStatus.sucesso) return;
    emit(set(state, get(state).copyWith(status: VariacaoStatus.carregando)));
    try {
      final itens = await ler();
      emit(set(state,
          get(state).copyWith(status: VariacaoStatus.sucesso, itens: itens)));
    } catch (_) {
      emit(set(
          state,
          get(state).copyWith(
            status: VariacaoStatus.falha,
            erro: 'Não foi possível carregar $nome.',
          )));
    }
  }

  Future<void> _cadastrar(
    Emitter<VariacoesProdutoState> emit,
    String nome,
    Future<VariacaoOpcao> Function(String) criar,
    Future<List<VariacaoOpcao>> Function() ler,
    VariacaoLista<VariacaoOpcao> Function(VariacoesProdutoState) get,
    VariacoesProdutoState Function(
            VariacoesProdutoState, VariacaoLista<VariacaoOpcao>)
        set,
  ) async {
    emit(set(state, get(state).copyWith(itens: get(state).itens)));
    try {
      final nova = await criar(nome);
      emit(set(state, get(state).copyWith(
        status: VariacaoStatus.sucesso,
        itens: await ler(),
        ultimoCadastrado: nova,
      )));
    } catch (_) {
      emit(set(state,
          get(state).copyWith(erro: 'Não foi possível cadastrar “$nome”.')));
    }
  }
}
