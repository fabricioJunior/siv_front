import 'dart:async';

import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/seletores.dart';

part 'pagamentos_realizados_event.dart';
part 'pagamentos_realizados_state.dart';

class PagamentosRealizadosBloc
    extends Bloc<PagamentosRealizadosEvent, PagamentosRealizadosState> {
  final CarregarResumoPagamentosRealizados _carregarResumo;

  PagamentosRealizadosBloc(this._carregarResumo)
      : super(const PagamentosRealizadosState()) {
    on<PagamentosRealizadosIniciado>(_onIniciado);
    on<PagamentosRealizadosLinhaAdicionada>(_onLinhaAdicionada);
    on<PagamentosRealizadosLinhaRemovida>(_onLinhaRemovida);
    on<PagamentosRealizadosFormaAlterada>(_onFormaAlterada);
    on<PagamentosRealizadosValorAlterado>(_onValorAlterado);
    on<PagamentosRealizadosParcelasAlteradas>(_onParcelasAlteradas);
    on<PagamentosRealizadosFinalizacaoSolicitada>(_onFinalizacaoSolicitada);
  }

  FutureOr<void> _onIniciado(
    PagamentosRealizadosIniciado event,
    Emitter<PagamentosRealizadosState> emit,
  ) async {
    emit(
      state.copyWith(
        step: PagamentosRealizadosStep.carregando,
        erro: null,
        hashLista: event.hashLista,
      ),
    );

    try {
      final resumo = event.resumoInicial ?? await _carregarResumo.call(event.hashLista);
      emit(
        state.copyWith(
          step: PagamentosRealizadosStep.editando,
          resumo: resumo,
          formasDePagamento: const [],
          linhas: [PagamentoRealizadoLinha.nova()],
          erro: null,
          resultado: const [],
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: PagamentosRealizadosStep.falha,
          erro: 'Falha ao carregar pagamentos realizados.',
        ),
      );
      addError(e, s);
    }
  }

  void _onLinhaAdicionada(
    PagamentosRealizadosLinhaAdicionada event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    emit(
      state.copyWith(
        linhas: [
          ...state.linhas,
          PagamentoRealizadoLinha.nova(),
        ],
        erro: null,
      ),
    );
  }

  void _onLinhaRemovida(
    PagamentosRealizadosLinhaRemovida event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    final novasLinhas = state.linhas
        .where((linha) => linha.id != event.linhaId)
        .toList(growable: false);

    emit(
      state.copyWith(
        linhas: novasLinhas.isEmpty
            ? [PagamentoRealizadoLinha.nova()]
            : novasLinhas,
        erro: null,
      ),
    );
  }

  void _onFormaAlterada(
    PagamentosRealizadosFormaAlterada event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    final novasLinhas = state.linhas.map((linha) {
      if (linha.id != event.linhaId) return linha;

      final parcelas = _parcelasMaximas(event.formaDePagamento) > 1
          ? (linha.parcelasTexto.trim().isEmpty ? '1' : linha.parcelasTexto)
          : '1';

      return linha.copyWith(
        formaDePagamento: event.formaDePagamento,
        parcelasTexto: parcelas,
      );
    }).toList(growable: false);

    emit(state.copyWith(linhas: novasLinhas, erro: null));
  }

  void _onValorAlterado(
    PagamentosRealizadosValorAlterado event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    emit(
      state.copyWith(
        linhas: state.linhas.map((linha) {
          if (linha.id != event.linhaId) return linha;
          return linha.copyWith(valorTexto: event.valorTexto);
        }).toList(growable: false),
        erro: null,
      ),
    );
  }

  void _onParcelasAlteradas(
    PagamentosRealizadosParcelasAlteradas event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    emit(
      state.copyWith(
        linhas: state.linhas.map((linha) {
          if (linha.id != event.linhaId) return linha;
          return linha.copyWith(parcelasTexto: event.parcelasTexto);
        }).toList(growable: false),
        erro: null,
      ),
    );
  }

  void _onFinalizacaoSolicitada(
    PagamentosRealizadosFinalizacaoSolicitada event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    final resumo = state.resumo;
    if (resumo == null) {
      emit(state.copyWith(erro: 'Resumo da venda não disponível.'));
      return;
    }

    final linhasValidadas = <PagamentoRealizadoLinha>[];
    for (final linha in state.linhas) {
      if (linha.formaDePagamento == null) {
        emit(
          state.copyWith(
            erro: 'Selecione uma forma de pagamento para todas as linhas.',
          ),
        );
        return;
      }

      final valor = _toDouble(linha.valorTexto);
      if (valor == null || valor <= 0) {
        emit(state.copyWith(erro: 'Informe um valor válido em todas as linhas.'));
        return;
      }

      final parcelas = _toInt(linha.parcelasTexto) ?? 1;
      if (parcelas <= 0) {
        emit(
          state.copyWith(
            erro: 'Informe a quantidade de parcelas corretamente.',
          ),
        );
        return;
      }

      final parcelasMaximas = linha.parcelasMaximas;
      if (parcelasMaximas <= 1 && parcelas != 1) {
        emit(
          state.copyWith(
            erro: 'A forma de pagamento selecionada não aceita parcelamento.',
          ),
        );
        return;
      }

      if (parcelasMaximas > 1 && parcelas > parcelasMaximas) {
        emit(
          state.copyWith(
            erro:
                'A forma de pagamento selecionada aceita no máximo $parcelasMaximas parcela(s).',
          ),
        );
        return;
      }

      linhasValidadas.add(
        linha.copyWith(
          valorTexto: valor.toStringAsFixed(2),
          parcelasTexto: parcelas.toString(),
        ),
      );
    }

    final totalBruto = _calcularTotalBruto(linhasValidadas);
    final possuiDinheiro = linhasValidadas.any((linha) => linha.ehDinheiro);
    final troco = possuiDinheiro && totalBruto > resumo.valorTotalProdutos
        ? totalBruto - resumo.valorTotalProdutos
        : 0.0;
    final totalLiquido = totalBruto - troco;

    if ((totalLiquido - resumo.valorTotalProdutos).abs() > 0.01) {
      emit(
        state.copyWith(
          erro:
              'O total dos pagamentos deve ser igual ao valor pendente de ${_formatarMoeda(resumo.valorTotalProdutos)}.',
        ),
      );
      return;
    }

    final resultado = linhasValidadas.asMap().entries.map((entry) {
      final linha = entry.value;
      return linha.toJson(controle: entry.key + 1);
    }).toList(growable: false);

    emit(
      state.copyWith(
        step: PagamentosRealizadosStep.concluido,
        erro: null,
        resultado: resultado,
      ),
    );
  }

  double _calcularTotalBruto(List<PagamentoRealizadoLinha> linhas) {
    return linhas.fold<double>(0, (acumulado, linha) => acumulado + linha.valor);
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  int? _toInt(String value) => int.tryParse(value.trim());

  double? _toDouble(String value) {
    final texto = value.trim();
    if (texto.isEmpty) return null;

    final normalizado = texto.contains(',') && texto.contains('.')
        ? texto.replaceAll('.', '').replaceAll(',', '.')
        : texto.replaceAll(',', '.');
    return double.tryParse(normalizado);
  }

  int _parcelasMaximas(SelectData? forma) {
    final parcelas = forma?.data['parcelas'];
    if (parcelas is int) return parcelas;
    if (parcelas is num) return parcelas.toInt();
    return int.tryParse(parcelas?.toString() ?? '') ?? 1;
  }
}