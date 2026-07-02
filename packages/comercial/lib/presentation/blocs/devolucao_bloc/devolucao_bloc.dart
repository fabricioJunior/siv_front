import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/sessao.dart';

part 'devolucao_event.dart';
part 'devolucao_state.dart';

class DevolucaoBloc extends Bloc<DevolucaoEvent, DevolucaoState> {
  final RecuperarRomaneios _recuperarRomaneios;
  final RecuperarItensRomaneio _recuperarItensRomaneio;
  final CriarRomaneio _criarRomaneio;
  final AdicionarItemRomaneio _adicionarItemRomaneio;
  final ReceberRomaneioNoCaixa _receberRomaneioNoCaixa;
  final IAcessoGlobalSessao _acessoGlobalSessao;

  DevolucaoBloc(
    this._recuperarRomaneios,
    this._recuperarItensRomaneio,
    this._criarRomaneio,
    this._adicionarItemRomaneio,
    this._receberRomaneioNoCaixa,
    this._acessoGlobalSessao,
  ) : super(const DevolucaoState()) {
    on<DevolucaoIniciou>(_onIniciou);
    on<DevolucaoBuscaRomaneiosSolicitada>(_onBuscaRomaneiosSolicitada);
    on<DevolucaoRomaneioOriginalSelecionado>(_onRomaneioOriginalSelecionado);
    on<DevolucaoLeituraSolicitada>(_onLeituraSolicitada);
    on<DevolucaoEdicaoSolicitada>(_onEdicaoSolicitada);
    on<DevolucaoConfirmacaoSolicitada>(_onConfirmacaoSolicitada);
    on<DevolucaoResetSolicitado>(_onResetSolicitado);
  }

  Future<void> _onIniciou(
    DevolucaoIniciou event,
    Emitter<DevolucaoState> emit,
  ) async {
    emit(state.copyWith(carregandoRomaneios: true, erro: null));

    try {
      final romaneios = await _recuperarRomaneios.call(page: 1, limit: 200);
      final romaneiosDeVenda = romaneios
          .where(
            (romaneio) =>
                romaneio.id != null && romaneio.operacao == TipoOperacao.venda,
          )
          .toList(growable: false);

      emit(
        state.copyWith(
          carregandoRomaneios: false,
          romaneiosDeVenda: romaneiosDeVenda,
          romaneiosBuscaDeVenda: romaneiosDeVenda,
          termoBuscaRomaneios: '',
          erroBuscaRomaneios: null,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoRomaneios: false,
          erro: 'Falha ao carregar romaneios de venda para devolução.',
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onBuscaRomaneiosSolicitada(
    DevolucaoBuscaRomaneiosSolicitada event,
    Emitter<DevolucaoState> emit,
  ) async {
    final searchTerm = (event.searchTerm ?? state.termoBuscaRomaneios).trim();
    final filtroBusca = searchTerm.isEmpty ? null : searchTerm;

    emit(
      state.copyWith(
        carregandoBuscaRomaneios: true,
        termoBuscaRomaneios: searchTerm,
        erroBuscaRomaneios: null,
      ),
    );

    try {
      final romaneios = await _recuperarRomaneios.call(
        page: 1,
        limit: 50,
        searchTerm: filtroBusca,
      );
      final romaneiosDeVenda = romaneios
          .where(
            (romaneio) =>
                romaneio.id != null && romaneio.operacao == TipoOperacao.venda,
          )
          .toList(growable: false);

      emit(
        state.copyWith(
          carregandoBuscaRomaneios: false,
          romaneiosBuscaDeVenda: romaneiosDeVenda,
          termoBuscaRomaneios: searchTerm,
          erroBuscaRomaneios: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoBuscaRomaneios: false,
          termoBuscaRomaneios: searchTerm,
          erroBuscaRomaneios: 'Falha ao buscar romaneios de venda.',
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onRomaneioOriginalSelecionado(
    DevolucaoRomaneioOriginalSelecionado event,
    Emitter<DevolucaoState> emit,
  ) async {
    final romaneio = event.romaneio;
    final romaneioId = romaneio.id;

    if (romaneioId == null) {
      emit(
        state.copyWith(
          erro: 'O romaneio selecionado não possui um identificador válido.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        romaneioOriginal: romaneio,
        carregandoItensDoOriginal: true,
        leituraIniciada: false,
        itensDoRomaneioOriginalPorProduto: const {},
        erro: null,
        romaneioDevolucaoId: null,
        fluxoParcial: false,
      ),
    );

    try {
      final itens = await _recuperarItensRomaneio.call(romaneioId);
      final itensPorProduto = _agruparQuantidadePorProduto(itens);

      emit(
        state.copyWith(
          carregandoItensDoOriginal: false,
          itensDoRomaneioOriginalPorProduto: itensPorProduto,
          erro: itensPorProduto.isEmpty
              ? 'O romaneio selecionado não possui itens para devolução.'
              : null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoItensDoOriginal: false,
          erro: 'Falha ao carregar os itens do romaneio selecionado.',
        ),
      );
      addError(e, s);
    }
  }

  void _onLeituraSolicitada(
    DevolucaoLeituraSolicitada event,
    Emitter<DevolucaoState> emit,
  ) {
    final erro = _validarAntesDaLeitura();
    if (erro != null) {
      emit(state.copyWith(erro: erro));
      return;
    }

    emit(state.copyWith(leituraIniciada: true, erro: null));
  }

  void _onEdicaoSolicitada(
    DevolucaoEdicaoSolicitada event,
    Emitter<DevolucaoState> emit,
  ) {
    emit(state.copyWith(leituraIniciada: false, erro: null));
  }

  Future<void> _onConfirmacaoSolicitada(
    DevolucaoConfirmacaoSolicitada event,
    Emitter<DevolucaoState> emit,
  ) async {
    final romaneioOriginal = state.romaneioOriginal;
    final romaneioOriginalId = romaneioOriginal?.id;

    if (romaneioOriginal == null || romaneioOriginalId == null) {
      emit(
        state.copyWith(
          erro: 'Selecione o romaneio original antes de confirmar a devolução.',
        ),
      );
      return;
    }

    final itens = _mapearItens(event.itens);
    if (itens.isEmpty) {
      emit(
        state.copyWith(
          erro: 'Leia ao menos um item para confirmar a devolução.',
        ),
      );
      return;
    }

    final erroValidacao = _validarItensDevolucao(itens);
    if (erroValidacao != null) {
      emit(state.copyWith(erro: erroValidacao));
      return;
    }

    final caixaId = _acessoGlobalSessao.caixaIdDaSessao;
    if (caixaId == null || caixaId <= 0) {
      emit(
        state.copyWith(
          erro:
              'Não foi possível receber a devolução: caixa da sessão não encontrado.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        processando: true,
        erro: null,
        romaneioDevolucaoId: null,
        fluxoParcial: false,
      ),
    );

    int? romaneioCriadoId;

    try {
      final romaneioCriado = await _criarRomaneio.call(
        Romaneio.create(
          pessoaId: romaneioOriginal.pessoaId,
          funcionarioId: romaneioOriginal.funcionarioId,
          tabelaPrecoId: romaneioOriginal.tabelaPrecoId,
          operacao: TipoOperacao.venda_devolucao,
          romaneiosDevolucao: [romaneioOriginalId],
        ),
      );

      romaneioCriadoId = romaneioCriado.id;
      if (romaneioCriadoId == null || romaneioCriadoId <= 0) {
        throw StateError('A API não retornou o id do romaneio de devolução.');
      }

      for (final item in itens) {
        await _adicionarItemRomaneio.call(
          romaneioId: romaneioCriadoId,
          item: item,
        );
      }

      await _receberRomaneioNoCaixa.call(
        caixaId: caixaId,
        romaneioId: romaneioCriadoId,
        formasDePagamentoRealizadas: const [],
      );

      emit(
        state.copyWith(
          processando: false,
          romaneioDevolucaoId: romaneioCriadoId,
          fluxoParcial: false,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          processando: false,
          romaneioDevolucaoId: romaneioCriadoId,
          fluxoParcial: romaneioCriadoId != null,
          erro: romaneioCriadoId != null
              ? 'O romaneio de devolução #$romaneioCriadoId foi criado, mas não foi recebido no caixa automaticamente. Conclua o recebimento manualmente.'
              : 'Falha ao processar a devolução. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  void _onResetSolicitado(
    DevolucaoResetSolicitado event,
    Emitter<DevolucaoState> emit,
  ) {
    emit(
      state.copyWith(
        leituraIniciada: false,
        processando: false,
        erro: null,
        romaneioDevolucaoId: null,
        fluxoParcial: false,
        romaneioOriginal: null,
        itensDoRomaneioOriginalPorProduto: const {},
      ),
    );
  }

  String? _validarAntesDaLeitura() {
    if (state.romaneioOriginal == null) {
      return 'Selecione o romaneio original para iniciar a devolução.';
    }

    if (state.itensDoRomaneioOriginalPorProduto.isEmpty) {
      return 'O romaneio original não possui itens disponíveis para devolução.';
    }

    return null;
  }

  String? _validarItensDevolucao(List<RomaneioItem> itens) {
    final disponiveis = state.itensDoRomaneioOriginalPorProduto;

    for (final item in itens) {
      final produtoId = item.produtoId;
      final quantidade = item.quantidade ?? 0;

      if (produtoId == null || produtoId <= 0) {
        return 'Existe item sem produto válido na leitura da devolução.';
      }

      final quantidadeDisponivel = disponiveis[produtoId];
      if (quantidadeDisponivel == null || quantidadeDisponivel <= 0) {
        return 'O produto #$produtoId não pertence ao romaneio original selecionado.';
      }

      if (quantidade <= 0) {
        return 'A quantidade do produto #$produtoId deve ser maior que zero.';
      }

      if (quantidade > quantidadeDisponivel) {
        return 'A quantidade devolvida do produto #$produtoId excede o vendido no romaneio original.';
      }
    }

    return null;
  }

  Map<int, double> _agruparQuantidadePorProduto(List<RomaneioItem> itens) {
    final resultado = <int, double>{};

    for (final item in itens) {
      final produtoId = item.produtoId;
      final quantidade = item.quantidade;
      if (produtoId == null || produtoId <= 0 || quantidade == null) {
        continue;
      }

      resultado[produtoId] = (resultado[produtoId] ?? 0) + quantidade;
    }

    return resultado;
  }

  List<RomaneioItem> _mapearItens(List<Map<String, dynamic>> itens) {
    return itens
        .map((item) {
          final produtoId = _toInt(item['produtoId'] ?? item['id']);
          final quantidade = _toDouble(item['quantidade']);

          if (produtoId == null || quantidade == null || quantidade <= 0) {
            return null;
          }

          return RomaneioItem.create(
            produtoId: produtoId,
            quantidade: quantidade,
            referenciaNome:
                item['nome']?.toString() ?? item['descricao']?.toString(),
            corNome: item['corNome']?.toString() ?? item['cor']?.toString(),
            tamanhoNome:
                item['tamanhoNome']?.toString() ?? item['tamanho']?.toString(),
          );
        })
        .whereType<RomaneioItem>()
        .toList(growable: false);
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }
}
