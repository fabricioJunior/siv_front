import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/gerar_nome_de_referencia.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/precos_da_referencia_bloc/precos_da_referencia_bloc.dart'
    show parseValor;
import 'package:produtos/use_cases.dart';

part 'referencia_cadastro_event.dart';
part 'referencia_cadastro_state.dart';

/// Wizard de cadastro: categoria -> (subcategoria) -> nome -> preço ->
/// variações. A referência só é criada na API ao confirmar o preço (o preço
/// precisa de uma referência existente); as variações já usam o id criado.
class ReferenciaCadastroBloc
    extends Bloc<ReferenciaCadastroEvent, ReferenciaCadastroState> {
  final RecuperarCategorias _recuperarCategorias;
  final RecuperarSubCategorias _recuperarSubCategorias;
  final CriarReferencia _criarReferencia;
  final RecuperarProximoIdReferencia _recuperarProximoId;
  final ListarPrecosDaReferenciaPorTabela _listarPrecos;
  final SalvarPrecoDaReferencia _salvarPreco;

  ReferenciaCadastroBloc(
    this._recuperarCategorias,
    this._recuperarSubCategorias,
    this._criarReferencia,
    this._recuperarProximoId,
    this._listarPrecos,
    this._salvarPreco,
  ) : super(const ReferenciaCadastroState()) {
    on<ReferenciaCadastroIniciou>(_onIniciou);
    on<ReferenciaCadastroCategoriaSelecionada>(_onCategoriaSelecionada);
    on<ReferenciaCadastroSubCategoriaSelecionada>(_onSubCategoriaSelecionada);
    on<ReferenciaCadastroNomeAlterado>(
      (e, emit) => emit(state.copyWith(nome: e.nome)),
    );
    on<ReferenciaCadastroGerarNome>(
      (e, emit) => emit(
        state.copyWith(
          nome: gerarNomeDeReferencia(state.categoria!, state.subCategoria),
        ),
      ),
    );
    on<ReferenciaCadastroOpcionaisAlterados>(
      (e, emit) => emit(
        state.copyWith(
          unidadeMedida: e.unidadeMedida,
          descricao: e.descricao,
          composicao: e.composicao,
          cuidados: e.cuidados,
        ),
      ),
    );
    on<ReferenciaCadastroPrecoAlterado>(
      (e, emit) => emit(state.copyWith(preco: e.preco)),
    );
    on<ReferenciaCadastroProximo>(_onProximo);
    on<ReferenciaCadastroVoltar>(_onVoltar);
    on<ReferenciaCadastroIrPara>(_onIrPara);
    on<ReferenciaCadastroVariacoesConcluidas>(
      (e, emit) => emit(state.copyWith(step: ReferenciaCadastroStep.concluido)),
    );
    on<ReferenciaCadastroReiniciar>(_onReiniciar);
  }

  FutureOr<void> _onIniciou(
    ReferenciaCadastroIniciou event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    try {
      emit(state.copyWith(carregandoCategorias: true));
      final categorias = await _recuperarCategorias.call();
      categorias.sort((a, b) => a.nome.compareTo(b.nome));
      emit(state.copyWith(carregandoCategorias: false, categorias: categorias));
    } catch (e, s) {
      emit(state.copyWith(carregandoCategorias: false, mensagem: 'Falha'));
      addError(e, s);
    }
  }

  /// Escolher a categoria já avança: pra subcategoria, se houver, senão pro nome.
  FutureOr<void> _onCategoriaSelecionada(
    ReferenciaCadastroCategoriaSelecionada event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    final categoriaId = event.categoria.id;
    if (categoriaId == null) {
      emit(state.copyWith(mensagem: 'Categoria invalida'));
      return;
    }
    emit(
      state.copyWith(
        categoria: () => event.categoria,
        subCategoria: () => null,
        subCategorias: const [],
        carregandoSubCategorias: true,
      ),
    );
    try {
      final subCategorias = await _recuperarSubCategorias.call(
        categoriaId,
        inativa: false,
      );
      emit(
        state.copyWith(
          carregandoSubCategorias: false,
          subCategorias: subCategorias,
          nome: event.categoria.nome,
          step: subCategorias.isEmpty
              ? ReferenciaCadastroStep.nome
              : ReferenciaCadastroStep.subCategoria,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoSubCategorias: false,
          mensagem: 'Falha ao carregar sub-categorias',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onSubCategoriaSelecionada(
    ReferenciaCadastroSubCategoriaSelecionada event,
    Emitter<ReferenciaCadastroState> emit,
  ) {
    emit(
      state.copyWith(
        subCategoria: () => event.subCategoria,
        nome: event.subCategoria.nome,
        step: ReferenciaCadastroStep.nome,
      ),
    );
  }

  FutureOr<void> _onProximo(
    ReferenciaCadastroProximo event,
    Emitter<ReferenciaCadastroState> emit,
  ) async {
    switch (state.step) {
      case ReferenciaCadastroStep.nome:
        if (state.nome.trim().isEmpty) {
          emit(state.copyWith(mensagem: 'Informe o nome da referencia'));
          return;
        }
        emit(state.copyWith(step: ReferenciaCadastroStep.preco));
      case ReferenciaCadastroStep.preco:
        await _criarComPreco(emit);
      default:
        return;
    }
  }

  Future<void> _criarComPreco(Emitter<ReferenciaCadastroState> emit) async {
    final valor = parseValor(state.preco);
    if (valor == null || valor <= 0) {
      emit(state.copyWith(mensagem: 'Informe o preço de venda'));
      return;
    }
    emit(state.copyWith(salvando: true));
    try {
      var id = state.referenciaId;
      if (id == null) {
        id = await _recuperarProximoId.call();
        final subCategoria = state.subCategoria;
        final categoria = state.categoria!;
        await _criarReferencia.call(
          categoriaId: categoria.id!,
          subCategoriaId: subCategoria?.id,
          id: id,
          nome: state.nome.trim(),
          unidadeMedida: _opcional(state.unidadeMedida),
          descricao: _opcional(state.descricao),
          composicao: _opcional(state.composicao),
          cuidados: _opcional(state.cuidados),
          ncm: subCategoria?.ncm ?? categoria.ncm,
          pesoGramas: subCategoria?.pesoGramas ?? categoria.pesoGramas,
        );
        emit(state.copyWith(referenciaId: id));
      }
      final tabelas = await _listarPrecos.call(referenciaId: id);
      final padrao = tabelas.firstWhere((t) => t.tabelaPadrao);
      await _salvarPreco.call(
        tabelaDePrecoId: padrao.tabelaDePrecoId,
        referenciaId: id,
        valor: valor,
        precoJaExiste: padrao.temPreco,
      );
      emit(
        state.copyWith(salvando: false, step: ReferenciaCadastroStep.variacoes),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          salvando: false,
          mensagem: e is HttpException
              ? (e.apiMessage ?? e.message)
              : 'Falha ao cadastrar referência',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onVoltar(
    ReferenciaCadastroVoltar event,
    Emitter<ReferenciaCadastroState> emit,
  ) {
    final etapas = state.etapas;
    final i = etapas.indexOf(state.step);
    if (i > 0 && !state.criada) emit(state.copyWith(step: etapas[i - 1]));
  }

  FutureOr<void> _onIrPara(
    ReferenciaCadastroIrPara event,
    Emitter<ReferenciaCadastroState> emit,
  ) {
    final etapas = state.etapas;
    final alvo = etapas.indexOf(event.step);
    if (!state.criada && alvo >= 0 && alvo < etapas.indexOf(state.step)) {
      emit(state.copyWith(step: event.step));
    }
  }

  FutureOr<void> _onReiniciar(
    ReferenciaCadastroReiniciar event,
    Emitter<ReferenciaCadastroState> emit,
  ) {
    final manter = event.manterCategoria && state.categoria != null;
    emit(
      ReferenciaCadastroState(
        categorias: state.categorias,
        categoria: manter ? state.categoria : null,
        subCategorias: manter ? state.subCategorias : const [],
        subCategoria: manter ? state.subCategoria : null,
        nome: manter ? (state.subCategoria?.nome ?? state.categoria!.nome) : '',
        step: manter
            ? ReferenciaCadastroStep.nome
            : ReferenciaCadastroStep.categoria,
      ),
    );
  }

  String? _opcional(String v) => v.trim().isEmpty ? null : v.trim();
}
