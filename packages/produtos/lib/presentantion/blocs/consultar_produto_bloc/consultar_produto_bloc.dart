import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'consultar_produto_event.dart';
part 'consultar_produto_state.dart';

class ConsultarProdutoBloc
    extends Bloc<ConsultarProdutoEvent, ConsultarProdutoState> {
  final ILeitorDataDatasource _leitorDataDatasource;
  final RecuperarGradeDaReferencia _recuperarGradeDaReferencia;

  int? _tabelaDePrecoId;
  int? _referenciaIdAtual;

  ConsultarProdutoBloc({
    required ILeitorDataDatasource leitorDataDatasource,
    required RecuperarGradeDaReferencia recuperarGradeDaReferencia,
  }) : _leitorDataDatasource = leitorDataDatasource,
       _recuperarGradeDaReferencia = recuperarGradeDaReferencia,
       super(const ConsultarProdutoInitial()) {
    on<ConsultarProdutoCodigoLido>(_onCodigoLido);
    on<ConsultarProdutoReferenciaSelecionada>(_onReferenciaSelecionada);
    on<ConsultarProdutoTabelaDePrecoAlterada>(_onTabelaDePrecoAlterada);
    on<ConsultarProdutoLimpou>(_onLimpou);
  }

  FutureOr<void> _onCodigoLido(
    ConsultarProdutoCodigoLido event,
    Emitter<ConsultarProdutoState> emit,
  ) async {
    final codigo = event.codigo.trim();
    if (codigo.isEmpty) return;

    emit(const ConsultarProdutoCarregarEmProgresso());
    try {
      final leitorData = await _leitorDataDatasource.getData(codigo);
      if (leitorData == null) {
        emit(
          ConsultarProdutoCarregarFalha(
            mensagemErro: 'Nenhum produto encontrado para o código "$codigo".',
          ),
        );
        return;
      }
      await _buscarGrade(leitorData.idReferencia, emit);
    } catch (e, s) {
      emit(
        const ConsultarProdutoCarregarFalha(
          mensagemErro: 'Não foi possível localizar o produto.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onReferenciaSelecionada(
    ConsultarProdutoReferenciaSelecionada event,
    Emitter<ConsultarProdutoState> emit,
  ) async {
    emit(const ConsultarProdutoCarregarEmProgresso());
    await _buscarGrade(event.referenciaId, emit);
  }

  FutureOr<void> _onTabelaDePrecoAlterada(
    ConsultarProdutoTabelaDePrecoAlterada event,
    Emitter<ConsultarProdutoState> emit,
  ) async {
    _tabelaDePrecoId = event.tabelaDePrecoId;
    final referenciaId = _referenciaIdAtual;
    if (referenciaId == null) return;

    emit(const ConsultarProdutoCarregarEmProgresso());
    await _buscarGrade(referenciaId, emit);
  }

  FutureOr<void> _onLimpou(
    ConsultarProdutoLimpou event,
    Emitter<ConsultarProdutoState> emit,
  ) {
    _referenciaIdAtual = null;
    emit(const ConsultarProdutoInitial());
  }

  Future<void> _buscarGrade(
    int referenciaId,
    Emitter<ConsultarProdutoState> emit,
  ) async {
    try {
      final grade = await _recuperarGradeDaReferencia.call(
        referenciaId: referenciaId,
        tabelaDePrecoId: _tabelaDePrecoId,
      );
      _referenciaIdAtual = referenciaId;
      emit(ConsultarProdutoCarregarSucesso(grade: grade));
    } catch (e, s) {
      emit(
        const ConsultarProdutoCarregarFalha(
          mensagemErro: 'Não foi possível carregar a grade do produto.',
        ),
      );
      addError(e, s);
    }
  }
}
