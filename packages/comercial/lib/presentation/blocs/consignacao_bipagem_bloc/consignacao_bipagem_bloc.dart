import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';

part 'consignacao_bipagem_event.dart';
part 'consignacao_bipagem_state.dart';

class ConsignacaoBipagemBloc
    extends Bloc<ConsignacaoBipagemEvent, ConsignacaoBipagemState> {
  final SalvarListaDeProdutosCompartilhada _salvarListaDeProdutosCompartilhada;
  final OrigemCompartilhadaTipo origem;
  final int? pessoaId;
  final int? funcionarioId;
  final int? tabelaPrecoId;

  ConsignacaoBipagemBloc(
    this._salvarListaDeProdutosCompartilhada, {
    required this.origem,
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
  }) : super(const ConsignacaoBipagemState()) {
    on<ConsignacaoBipagemSalvarSolicitado>(_onSalvarSolicitado);
  }

  FutureOr<void> _onSalvarSolicitado(
    ConsignacaoBipagemSalvarSolicitado event,
    Emitter<ConsignacaoBipagemState> emit,
  ) async {
    final produtos = _mapearProdutos(event.itens);
    if (produtos.isEmpty) {
      emit(
        state.copyWith(
          erro: 'Adicione ao menos um produto para continuar.',
        ),
      );
      return;
    }

    emit(state.copyWith(salvando: true, erro: null));

    try {
      final lista = await _salvarListaDeProdutosCompartilhada(
        listaCompartilhada: ListaDeProdutosCompartilhada.criar(
          origem: origem,
          pessoaId: pessoaId,
          funcionarioId: funcionarioId,
          tabelaPrecoId: tabelaPrecoId,
        ),
        produtos: produtos,
      );

      emit(
        state.copyWith(
          salvando: false,
          listaCompartilhadaHash: lista.hash,
          erro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          salvando: false,
          erro: 'Falha ao salvar os produtos localmente. Tente novamente.',
        ),
      );
      addError(e, s);
    }
  }

  List<ProdutoCompartilhado> _mapearProdutos(List<Map<String, dynamic>> itens) {
    final produtos = <ProdutoCompartilhado>[];

    for (final item in itens) {
      final produtoId = _toInt(item['produtoId'] ?? item['id']);
      final quantidade = _toInt(item['quantidade'] ?? item['quantidadeLida']);

      if (produtoId == null || quantidade == null || quantidade <= 0) {
        continue;
      }

      produtos.add(
        ProdutoCompartilhado.create(
          produtoId: produtoId,
          quantidade: quantidade,
          valorUnitario: _toDouble(item['valorUnitario']) ?? 0,
          nome: item['nome']?.toString() ?? item['descricao']?.toString() ?? '',
          corNome: item['corNome']?.toString() ?? item['cor']?.toString() ?? '',
          tamanhoNome:
              item['tamanhoNome']?.toString() ?? item['tamanho']?.toString() ?? '',
        ),
      );
    }

    return produtos;
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
}
