import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'romaneio_criacao_event.dart';
part 'romaneio_criacao_state.dart';

class RomaneioCriacaoBloc
    extends Bloc<RomaneioCriacaoEvent, RomaneioCriacaoState> {
  final CriarRomaneio _criarRomaneio;
  final AdicionarItemRomaneio _adicionarItemRomaneio;
  final RecuperarRomaneio _recuperarRomaneio;

  RomaneioCriacaoBloc(
    this._criarRomaneio,
    this._adicionarItemRomaneio,
    this._recuperarRomaneio,
  ) : super(const RomaneioCriacaoState.initial()) {
    on<RomaneioCriacaoSolicitada>(_onSolicitada);
  }

  FutureOr<void> _onSolicitada(
    RomaneioCriacaoSolicitada event,
    Emitter<RomaneioCriacaoState> emit,
  ) async {
    final parametros = Map<String, dynamic>.from(event.parametros);
    final erro = _validar(parametros);
    if (erro != null) {
      emit(
        state.copyWith(
          step: RomaneioCriacaoStep.falha,
          erro: erro,
          parametros: parametros,
        ),
      );
      return;
    }

    final itens = _extrairItens(parametros);

    emit(
      state.copyWith(
        step: RomaneioCriacaoStep.processando,
        erro: null,
        parametros: parametros,
        totalItensProcessados: itens.length,
      ),
    );

    try {
      final criado = await _criarRomaneio.call(
        Romaneio.create(
          pessoaId: _toInt(parametros['pessoaId']),
          funcionarioId: _toInt(parametros['funcionarioId']),
          tabelaPrecoId: _toInt(parametros['tabelaPrecoId']),
          operacao: _toOperacao(parametros['operacao']),
        ),
      );

      final romaneioId = criado.id;
      if (romaneioId == null) {
        throw StateError('A API não retornou o id do romaneio criado.');
      }

      for (final item in itens) {
        await _adicionarItemRomaneio.call(
          romaneioId: romaneioId,
          item: item,
        );
      }

      final romaneioAtualizado = await _recuperarRomaneio.call(romaneioId);

      emit(
        state.copyWith(
          step: RomaneioCriacaoStep.sucesso,
          romaneio: romaneioAtualizado,
          erro: null,
          parametros: parametros,
          totalItensProcessados: itens.length,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: RomaneioCriacaoStep.falha,
          erro: 'Falha ao criar o romaneio.',
          parametros: parametros,
        ),
      );
      addError(e, s);
    }
  }

  String? _validar(Map<String, dynamic> parametros) {
    if (_toInt(parametros['funcionarioId']) == null) {
      return 'Informe um funcionarioId válido.';
    }

    if (_toInt(parametros['tabelaPrecoId']) == null) {
      return 'Informe um tabelaPrecoId válido.';
    }

    final operacao = _toOperacao(parametros['operacao']);
    if (operacao == null) {
      return 'Informe uma operação válida do romaneio.';
    }

    final itens = _extrairItens(parametros);
    if (itens.isEmpty) {
      return 'Informe ao menos um item com produtoId e quantidade.';
    }

    return null;
  }

  List<RomaneioItem> _extrairItens(Map<String, dynamic> parametros) {
    final itens = parametros['itens'];
    if (itens is! List) return const [];

    final resultado = <RomaneioItem>[];
    for (final item in itens) {
      if (item is! Map) continue;

      final mapa = Map<String, dynamic>.from(item);
      final produtoId = _toInt(
        mapa['produtoId'] ?? mapa['id'] ?? mapa['produto'],
      );
      final quantidade = _toDouble(
        mapa['quantidade'] ?? mapa['quantidadeLida'] ?? mapa['qtd'],
      );

      if (produtoId == null || quantidade == null || quantidade <= 0) {
        continue;
      }

      resultado.add(
        RomaneioItem.create(
          produtoId: produtoId,
          quantidade: quantidade,
        ),
      );
    }

    return resultado;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  TipoOperacao? _toOperacao(dynamic value) {
    return TipoOperacao.fromJson(value);
  }
}
