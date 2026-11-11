import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/seletores.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'consultar_produto_event.dart';
part 'consultar_produto_state.dart';

class ConsultarProdutoBloc
    extends Bloc<ConsultarProdutoEvent, ConsultarProdutoState> {
  final ConsultarReferencias _consultarReferencias;
  final RecuperarGradeDaReferencia _recuperarGradeDaReferencia;
  final Duration debounce;
  Timer? _timer;

  ConsultarProdutoBloc({
    required ConsultarReferencias consultarReferencias,
    required RecuperarGradeDaReferencia recuperarGradeDaReferencia,
    this.debounce = const Duration(milliseconds: 400),
  }) : _consultarReferencias = consultarReferencias,
       _recuperarGradeDaReferencia = recuperarGradeDaReferencia,
       super(const ConsultarProdutoState()) {
    on<ConsultarProdutoBuscaAlterada>(_onBuscaAlterada);
    on<ConsultarProdutoFiltrosAlterados>(_onFiltrosAlterados);
    on<ConsultarProdutoPesquisou>((_, emit) => _pesquisar(emit));
    on<ConsultarProdutoMaisCarregado>(_onMaisCarregado);
    on<ConsultarProdutoCodigoLido>(_onCodigoLido);
    on<ConsultarProdutoLeituraReiniciada>(
      (_, emit) => emit(state.copyWith(leitura: () => null)),
    );
    on<ConsultarProdutoReferenciaSelecionada>(
      (e, emit) => _abrir(e.referenciaId, emit),
    );
    on<ConsultarProdutoTabelaDePrecoAlterada>(_onTabela);
    on<ConsultarProdutoLimpou>((_, emit) {
      _timer?.cancel();
      emit(const ConsultarProdutoState());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _onBuscaAlterada(
    ConsultarProdutoBuscaAlterada e,
    Emitter<ConsultarProdutoState> emit,
  ) {
    emit(state.copyWith(busca: e.texto));
    _timer?.cancel();
    _timer = Timer(debounce, () => add(ConsultarProdutoPesquisou()));
  }

  Future<void> _onFiltrosAlterados(
    ConsultarProdutoFiltrosAlterados e,
    Emitter<ConsultarProdutoState> emit,
  ) async {
    _timer?.cancel();
    emit(state.copyWith(cores: e.cores, tamanhos: e.tamanhos, estampas: e.estampas));
    await _pesquisar(emit);
  }

  Future<void> _onTabela(
    ConsultarProdutoTabelaDePrecoAlterada e,
    Emitter<ConsultarProdutoState> emit,
  ) async {
    emit(state.copyWith(tabelaDePreco: e.itens));
    final aberta = state.referenciaAbertaId;
    await _pesquisar(emit);
    if (aberta != null) await _carregarGrade(aberta, emit);
  }

  Future<void> _pesquisar(Emitter<ConsultarProdutoState> emit) async {
    _timer?.cancel();
    if (!state.buscaValida) {
      emit(state.copyWith(
        itens: const [], pagina: 1, totalPaginas: 1, carregando: false, erro: () => null,
      ));
      return;
    }
    emit(state.copyWith(carregando: true, erro: () => null));
    try {
      final p = await _consulta(1);
      emit(state.copyWith(
        itens: p.items, pagina: p.page, totalPaginas: p.totalPages, carregando: false,
      ));
    } catch (e, s) {
      emit(state.copyWith(carregando: false, itens: const [], erro: () => _mensagem(e)));
      addError(e, s);
    }
  }

  Future<ConsultaReferenciasPagina> _consulta(int page, {String? busca, int limit = 30}) {
    final filtrando = busca == null;
    return _consultarReferencias(
      busca: busca ?? state.busca,
      corIds: filtrando ? state.corIds : const [],
      tamanhoIds: filtrando ? state.tamanhoIds : const [],
      estampaIds: filtrando ? state.estampaIds : const [],
      tabelaPrecoId: state.tabelaDePrecoId,
      page: page,
      limit: limit,
    );
  }

  Future<void> _onMaisCarregado(
    ConsultarProdutoMaisCarregado e,
    Emitter<ConsultarProdutoState> emit,
  ) async {
    if (!state.temMais || state.carregando || state.carregandoMais) return;
    emit(state.copyWith(carregandoMais: true));
    try {
      final p = await _consulta(state.pagina + 1);
      emit(state.copyWith(
        itens: [...state.itens, ...p.items],
        pagina: p.page,
        totalPaginas: p.totalPages,
        carregandoMais: false,
      ));
    } catch (e, s) {
      emit(state.copyWith(carregandoMais: false, erro: () => _mensagem(e)));
      addError(e, s);
    }
  }

  Future<void> _onCodigoLido(
    ConsultarProdutoCodigoLido e,
    Emitter<ConsultarProdutoState> emit,
  ) async {
    final codigo = e.codigo.trim();
    if (codigo.isEmpty) return;
    try {
      final p = await _consulta(1, busca: codigo, limit: 1);
      final item = p.items.firstOrNull;
      final variacao = item?.variacoes
          .where((v) => v.produtoId == p.produtoIdLido)
          .firstOrNull;
      if (item == null || variacao == null) {
        emit(state.copyWith(leitura: () => LeituraCodigo(codigo: codigo, encontrada: false)));
        return;
      }
      emit(state.copyWith(
        produtoIdLido: () => variacao.produtoId,
        leitura: () => LeituraCodigo(
          codigo: codigo,
          encontrada: true,
          referenciaId: item.referenciaId,
          produtoId: variacao.produtoId,
          descricao: '${item.nome} · ${variacao.descricao}',
          saldo: variacao.saldo,
        ),
      ));
      await _abrir(item.referenciaId, emit, manterLido: true);
    } catch (err, s) {
      emit(state.copyWith(leitura: () => LeituraCodigo(codigo: codigo, encontrada: false)));
      addError(err, s);
    }
  }

  Future<void> _abrir(
    int referenciaId,
    Emitter<ConsultarProdutoState> emit, {
    bool manterLido = false,
  }) async {
    emit(state.copyWith(
      referenciaAbertaId: () => referenciaId,
      produtoIdLido: manterLido ? null : () => null,
      grade: () => null,
    ));
    await _carregarGrade(referenciaId, emit);
  }

  Future<void> _carregarGrade(int referenciaId, Emitter<ConsultarProdutoState> emit) async {
    emit(state.copyWith(carregandoGrade: true, erroGrade: () => null));
    try {
      final grade = await _recuperarGradeDaReferencia(
        referenciaId: referenciaId,
        tabelaDePrecoId: state.tabelaDePrecoId,
      );
      if (state.referenciaAbertaId != referenciaId) return;
      emit(state.copyWith(grade: () => grade, carregandoGrade: false));
    } catch (e, s) {
      emit(state.copyWith(
        carregandoGrade: false,
        erroGrade: () => 'Não foi possível carregar a grade do produto.',
      ));
      addError(e, s);
    }
  }

  String _mensagem(Object e) {
    final m = e.toString().replaceFirst('Exception: ', '').trim();
    return m.isEmpty ? 'Não foi possível consultar os produtos.' : m;
  }
}
