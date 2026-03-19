import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'produtos_da_referencia_event.dart';
part 'produtos_da_referencia_state.dart';

class ProdutosDaReferenciaBloc
    extends Bloc<ProdutosDaReferenciaEvent, ProdutosDaReferenciaState> {
  final RecuperarProdutos _recuperarProdutos;

  ProdutosDaReferenciaBloc(this._recuperarProdutos)
    : super(const ProdutosDaReferenciaInitial()) {
    on<ProdutosDaReferenciaIniciou>(_onIniciou);
  }

  FutureOr<void> _onIniciou(
    ProdutosDaReferenciaIniciou event,
    Emitter<ProdutosDaReferenciaState> emit,
  ) async {
    try {
      emit(const ProdutosDaReferenciaCarregarEmProgresso());
      final produtos = await _recuperarProdutos.call(
        referenciaId: event.referenciaId,
      );

      final mapaCores = <String, Cor>{};
      final mapaTamanhos = <String, Tamanho>{};

      for (final produto in produtos) {
        final cor = produto.cor;
        if (cor != null) {
          final chaveCor = cor.id?.toString() ?? cor.nome.trim().toLowerCase();
          mapaCores[chaveCor] = cor;
        }

        final tamanho = produto.tamanho;
        if (tamanho != null) {
          final chaveTamanho =
              tamanho.id?.toString() ?? tamanho.nome.trim().toLowerCase();
          mapaTamanhos[chaveTamanho] = tamanho;
        }
      }

      final cores = mapaCores.values.toList();
      final tamanhos = mapaTamanhos.values.toList();

      cores.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );
      tamanhos.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );

      Map<String, Produto> mapaCorProdutos = {};
      for (var produto in produtos) {
        final key = '${produto.cor!.id}_${produto.tamanho!.id}';
        mapaCorProdutos[key] = produto;
      }

      emit(
        ProdutosDaReferenciaCarregarSucesso(
          produtos: produtos,
          tamanhos: tamanhos,
          cores: cores,
          mapaCorTamanhoParaProduto: mapaCorProdutos,
        ),
      );
    } catch (e, s) {
      emit(const ProdutosDaReferenciaCarregarFalha());
      addError(e, s);
    }
  }
}
