import 'dart:async';

import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/presentation.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/seletores.dart';

part 'pagamentos_realizados_event.dart';
part 'pagamentos_realizados_state.dart';

class PagamentosRealizadosBloc
    extends Bloc<PagamentosRealizadosEvent, PagamentosRealizadosState> {
  final CarregarResumoPagamentosRealizados _carregarResumo;
  final BuscarSaldoCreditoDevolucao _buscarSaldoCreditoDevolucao;

  PagamentosRealizadosBloc(
    this._carregarResumo,
    this._buscarSaldoCreditoDevolucao,
  ) : super(const PagamentosRealizadosState()) {
    on<PagamentosRealizadosIniciado>(_onIniciado);
    on<PagamentosRealizadosLinhaAdicionada>(_onLinhaAdicionada);
    on<PagamentosRealizadosLinhaRemovida>(_onLinhaRemovida);
    on<PagamentosRealizadosFormaAlterada>(_onFormaAlterada);
    on<PagamentosRealizadosValorAlterado>(_onValorAlterado);
    on<PagamentosRealizadosParcelasAlteradas>(_onParcelasAlteradas);
    on<PagamentosRealizadosDescontoAlterado>(_onDescontoAlterado);
    on<PagamentosRealizadosDescontoItemAlterado>(_onDescontoItemAlterado);
    on<PagamentosRealizadosFinalizacaoSolicitada>(_onFinalizacaoSolicitada);
    on<PagamentosRealizadosIncluirCpfAlterado>(_onIncluirCpfAlterado);
    on<PagamentosRealizadosCpfAlterado>(_onCpfAlterado);
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
        pessoaId: event.pessoaId,
        carregandoSaldoCreditoDevolucao: false,
        saldoCreditoDevolucao: 0,
        incluirCpfNaNota: true,
        cpfNaNota: event.cpfClienteInicial ?? '',
      ),
    );

    try {
      final resumo =
          event.resumoInicial ?? await _carregarResumo.call(event.hashLista);
      final pessoaId = event.pessoaId ?? resumo.listaCompartilhada?.pessoaId;
      emit(
        state.copyWith(
          step: PagamentosRealizadosStep.editando,
          pessoaId: pessoaId,
          resumo: resumo,
          formasDePagamento: const [],
          linhas: [PagamentoRealizadoLinha.nova()],
          erro: null,
          resultado: const [],
          carregandoSaldoCreditoDevolucao: pessoaId != null,
        ),
      );

      if (pessoaId != null) {
        final saldo =
            await _buscarSaldoCreditoDevolucao.call(pessoaId: pessoaId);
        emit(
          state.copyWith(
            saldoCreditoDevolucao: saldo,
            carregandoSaldoCreditoDevolucao: false,
          ),
        );
      }
    } catch (e, s) {
      emit(
        state.copyWith(
          step: PagamentosRealizadosStep.falha,
          erro:
              mensagemDeErroApi(e, 'Falha ao carregar pagamentos realizados.'),
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

  void _onDescontoAlterado(
    PagamentosRealizadosDescontoAlterado event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    if (event.tipo == null || event.valorTexto.trim().isEmpty) {
      emit(
        state.copyWith(
          descontoTipo: null,
          descontoValorTexto: '',
          valorDescontoAplicado: 0,
          erro: null,
        ),
      );
      return;
    }

    final valorBase = state.valorTotalProdutos;
    final valorInformado = _toDouble(event.valorTexto);
    if (valorInformado == null) {
      emit(state.copyWith(erro: 'Informe um valor válido para desconto.'));
      return;
    }

    double descontoAplicado;
    switch (event.tipo!) {
      case DescontoTipo.valorBruto:
        if (valorInformado < 0 || valorInformado > valorBase) {
          emit(
            state.copyWith(
              erro:
                  'O desconto em valor bruto deve estar entre 0 e ${_formatarMoeda(valorBase)}.',
            ),
          );
          return;
        }
        descontoAplicado = valorInformado;
      case DescontoTipo.porcentagem:
        if (valorInformado < 0 || valorInformado > 100) {
          emit(
            state.copyWith(
              erro: 'O desconto em porcentagem deve estar entre 0 e 100.',
            ),
          );
          return;
        }
        descontoAplicado = valorBase * (valorInformado / 100);
      case DescontoTipo.forcaValorTotal:
        if (valorInformado < 0 || valorInformado > valorBase) {
          emit(
            state.copyWith(
              erro:
                  'O valor total forçado deve estar entre 0 e ${_formatarMoeda(valorBase)}.',
            ),
          );
          return;
        }
        descontoAplicado = valorBase - valorInformado;
    }

    emit(
      state.copyWith(
        descontoTipo: event.tipo,
        descontoValorTexto: event.valorTexto,
        valorDescontoAplicado:
            double.parse(descontoAplicado.toStringAsFixed(2)),
        erro: null,
      ),
    );
  }

  void _onDescontoItemAlterado(
    PagamentosRealizadosDescontoItemAlterado event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    if (event.tipo == null || event.valorTexto.trim().isEmpty) {
      final tipoMap = Map<int, DescontoTipo>.from(state.descontosItensTipo)
        ..remove(event.produtoId);
      final valorTextoMap =
          Map<int, String>.from(state.descontosItensValorTexto)
            ..remove(event.produtoId);
      final aplicadoMap = Map<int, double>.from(state.descontosItensAplicado)
        ..remove(event.produtoId);
      emit(
        state.copyWith(
          descontosItensTipo: tipoMap,
          descontosItensValorTexto: valorTextoMap,
          descontosItensAplicado: aplicadoMap,
          erro: null,
        ),
      );
      return;
    }

    final produtosEncontrados = state.resumo?.produtosCompartilhados
            .where((p) => p.produtoId == event.produtoId)
            .toList() ??
        const [];
    final produto =
        produtosEncontrados.isEmpty ? null : produtosEncontrados.first;
    if (produto == null) {
      emit(state.copyWith(erro: 'Produto não encontrado na venda.'));
      return;
    }

    final valorBase = produto.quantidade * produto.valorUnitario;
    final valorInformado = _toDouble(event.valorTexto);
    if (valorInformado == null) {
      emit(state.copyWith(erro: 'Informe um valor válido para desconto.'));
      return;
    }

    double descontoAplicado;
    switch (event.tipo!) {
      case DescontoTipo.valorBruto:
        if (valorInformado < 0 || valorInformado > valorBase) {
          emit(
            state.copyWith(
              erro:
                  'O desconto em valor bruto deve estar entre 0 e ${_formatarMoeda(valorBase)}.',
            ),
          );
          return;
        }
        descontoAplicado = valorInformado;
      case DescontoTipo.porcentagem:
        if (valorInformado < 0 || valorInformado > 100) {
          emit(
            state.copyWith(
              erro: 'O desconto em porcentagem deve estar entre 0 e 100.',
            ),
          );
          return;
        }
        descontoAplicado = valorBase * (valorInformado / 100);
      case DescontoTipo.forcaValorTotal:
        if (valorInformado < 0 || valorInformado > valorBase) {
          emit(
            state.copyWith(
              erro:
                  'O valor total forçado deve estar entre 0 e ${_formatarMoeda(valorBase)}.',
            ),
          );
          return;
        }
        descontoAplicado = valorBase - valorInformado;
    }

    final tipoMap = Map<int, DescontoTipo>.from(state.descontosItensTipo)
      ..[event.produtoId] = event.tipo!;
    final valorTextoMap = Map<int, String>.from(state.descontosItensValorTexto)
      ..[event.produtoId] = event.valorTexto;
    final aplicadoMap = Map<int, double>.from(state.descontosItensAplicado)
      ..[event.produtoId] = double.parse(descontoAplicado.toStringAsFixed(2));

    emit(
      state.copyWith(
        descontosItensTipo: tipoMap,
        descontosItensValorTexto: valorTextoMap,
        descontosItensAplicado: aplicadoMap,
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

    if (state.incluirCpfNaNota &&
        state.cpfNaNota.trim().isNotEmpty &&
        !cpfEhValido(state.cpfNaNota)) {
      emit(
        state.copyWith(
          erro: 'CPF informado para a nota fiscal é inválido.',
        ),
      );
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
        emit(state.copyWith(
            erro: 'Informe um valor válido em todas as linhas.'));
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
    final totalCreditoDevolucao = linhasValidadas
        .where((linha) => linha.ehCreditoDevolucao)
        .fold<double>(0, (acumulado, linha) => acumulado + linha.valor);

    if (totalCreditoDevolucao > 0 && state.carregandoSaldoCreditoDevolucao) {
      emit(
        state.copyWith(
          erro:
              'Aguarde o carregamento do saldo de credito de devolucao para finalizar.',
        ),
      );
      return;
    }

    if (totalCreditoDevolucao - state.saldoCreditoDevolucao > 0.01) {
      emit(
        state.copyWith(
          erro:
              'O valor em credito de devolucao excede o saldo disponivel de ${_formatarMoeda(state.saldoCreditoDevolucao)}.',
        ),
      );
      return;
    }

    final possuiDinheiro = linhasValidadas.any((linha) => linha.ehDinheiro);
    final totalComDesconto = state.valorTotalComDesconto;
    final troco = possuiDinheiro && totalBruto > totalComDesconto
        ? totalBruto - totalComDesconto
        : 0.0;
    final totalLiquido = totalBruto - troco;

    if ((totalLiquido - totalComDesconto).abs() > 0.01) {
      emit(
        state.copyWith(
          erro:
              'O total dos pagamentos deve ser igual ao valor pendente de ${_formatarMoeda(totalComDesconto)}.',
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

  void _onIncluirCpfAlterado(
    PagamentosRealizadosIncluirCpfAlterado event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    emit(
      state.copyWith(
        incluirCpfNaNota: event.incluirCpfNaNota,
        erro: null,
      ),
    );
  }

  void _onCpfAlterado(
    PagamentosRealizadosCpfAlterado event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    emit(state.copyWith(cpfNaNota: event.cpfNaNota, erro: null));
  }

  double _calcularTotalBruto(List<PagamentoRealizadoLinha> linhas) {
    return linhas.fold<double>(
        0, (acumulado, linha) => acumulado + linha.valor);
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
