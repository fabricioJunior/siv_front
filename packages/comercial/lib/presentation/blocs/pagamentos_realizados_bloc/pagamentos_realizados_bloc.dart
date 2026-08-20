import 'dart:async';

import 'package:comercial/domain/models/pagamentos_realizados_resumo.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/leitor/data_source/i_leitor_data_datasource.dart';
import 'package:core/presentation.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:empresas/use_cases.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/use_cases.dart';

part 'pagamentos_realizados_event.dart';
part 'pagamentos_realizados_state.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class PagamentosRealizadosBloc
    extends Bloc<PagamentosRealizadosEvent, PagamentosRealizadosState> {
  final CarregarResumoPagamentosRealizados _carregarResumo;
  final BuscarSaldoCreditoDevolucao _buscarSaldoCreditoDevolucao;
  final VerificarElegibilidadeFidelidade _verificarElegibilidadeFidelidade;
  final RecuperarConfiguracaoNotaFiscalEmail
      _recuperarConfiguracaoNotaFiscalEmail;
  final IAcessoGlobalSessao _acessoGlobalSessao;
  final ApurarElegibilidade _apurarElegibilidade;
  final ILeitorDataDatasource _leitorDataDatasource;

  PagamentosRealizadosBloc(
    this._carregarResumo,
    this._buscarSaldoCreditoDevolucao,
    this._verificarElegibilidadeFidelidade,
    this._recuperarConfiguracaoNotaFiscalEmail,
    this._acessoGlobalSessao,
    this._apurarElegibilidade,
    this._leitorDataDatasource,
  ) : super(const PagamentosRealizadosState()) {
    on<PagamentosRealizadosIniciado>(_onIniciado);
    on<PagamentosRealizadosLinhaAdicionada>(_onLinhaAdicionada);
    on<PagamentosRealizadosLinhaRemovida>(_onLinhaRemovida);
    on<PagamentosRealizadosFormaAlterada>(_onFormaAlterada);
    on<PagamentosRealizadosValorAlterado>(_onValorAlterado);
    on<PagamentosRealizadosParcelasAlteradas>(_onParcelasAlteradas);
    on<PagamentosRealizadosDescontoAlterado>(_onDescontoAlterado);
    on<PagamentosRealizadosTaxaEntregaAlterada>(_onTaxaEntregaAlterada);
    on<PagamentosRealizadosDescontoItemAlterado>(_onDescontoItemAlterado);
    on<PagamentosRealizadosDescontosItensLimpos>(_onDescontosItensLimpos);
    on<PagamentosRealizadosFinalizacaoSolicitada>(_onFinalizacaoSolicitada);
    on<PagamentosRealizadosIncluirCpfAlterado>(_onIncluirCpfAlterado);
    on<PagamentosRealizadosCpfAlterado>(_onCpfAlterado);
    on<PagamentosRealizadosPontuarFidelidadeAlterado>(
      _onPontuarFidelidadeAlterado,
    );
    on<PagamentosRealizadosEnviarNotaPorEmailAlterado>(
      _onEnviarNotaPorEmailAlterado,
    );
    on<PagamentosRealizadosEmailNotaAlterado>(_onEmailNotaAlterado);
    on<PagamentosRealizadosCarregouElegibilidade>(_onCarregouElegibilidade);
    on<PagamentosRealizadosPromocaoEscolhida>(_onPromocaoEscolhida);
    on<PagamentosRealizadosPromocaoGlobalAlterada>(_onPromocaoGlobalAlterada);
    on<PagamentosRealizadosCupomInformado>(_onCupomInformado);
    on<PagamentosRealizadosCupomRemovido>(_onCupomRemovido);
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
        incluirCpfNaNota: false,
        cpfNaNota: event.clienteGenerico ? '' : (event.cpfClienteInicial ?? ''),
        pontuarFidelidade: false,
        clienteElegivelFidelidade: false,
        carregandoElegibilidadeFidelidade: false,
        clienteGenerico: event.clienteGenerico,
        enviarNotaPorEmail: event.enviarNotaPorEmailInicial,
        emailNota: event.emailClienteInicial ?? '',
        emailClienteCadastrado: event.emailClienteInicial,
        permiteNotaFiscalEmail: false,
      ),
    );

    await _carregarPermiteNotaFiscalEmail(emit);

    try {
      final resumo =
          event.resumoInicial ?? await _carregarResumo.call(event.hashLista);
      final pessoaId = event.pessoaId ?? resumo.listaCompartilhada?.pessoaId;

      // Pré-carrega o desconto já persistido no romaneio (fora deste
      // diálogo, ver romaneio_page.dart) como se já tivesse sido aplicado
      // aqui -- reaproveita os botões "Editar desconto"/"Remover desconto"
      // já existentes pra corrigir ou zerar esse valor, em vez de criar UI
      // nova. Mesma distribuição proporcional usada em _onDescontoAlterado.
      final produtosSemPromocaoSeed = resumo.produtosCompartilhados
          .where((p) => !state.promocaoEscolhidaPorItem.containsKey(
                p.produtoId,
              ))
          .toList(growable: false);
      final valorBaseSemPromocaoSeed = produtosSemPromocaoSeed.fold<double>(
        0,
        (soma, p) => soma + p.quantidade * p.valorUnitario,
      );
      final descontosItensSeed = _distribuirDescontoProporcional(
        produtos: produtosSemPromocaoSeed,
        descontoTotal: event.descontoJaAplicadoNoRomaneio,
        valorBase: valorBaseSemPromocaoSeed,
      );

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
          carregandoElegibilidadeFidelidade: pessoaId != null,
          descontoTipo: descontosItensSeed.isNotEmpty
              ? DescontoTipo.valorBruto
              : null,
          descontoValorTexto: descontosItensSeed.isNotEmpty
              ? event.descontoJaAplicadoNoRomaneio.toStringAsFixed(2)
              : '',
          valorDescontoAplicado: event.descontoJaAplicadoNoRomaneio,
          taxaEntregaValorTexto: event.taxaEntregaJaAplicadaNoRomaneio > 0
              ? event.taxaEntregaJaAplicadaNoRomaneio.toStringAsFixed(2)
              : '',
          valorTaxaEntregaAplicado: event.taxaEntregaJaAplicadaNoRomaneio,
          descontosItensTipo: {
            for (final produto in resumo.produtosCompartilhados)
              produto.produtoId: DescontoTipo.valorBruto,
          },
          descontosItensValorTexto: {
            for (final entrada in descontosItensSeed.entries)
              entrada.key: entrada.value.toStringAsFixed(2),
          },
          descontosItensAplicado: descontosItensSeed,
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

        try {
          final elegivel = await _verificarElegibilidadeFidelidade.call(
            pessoaId: pessoaId,
          );
          emit(
            state.copyWith(
              clienteElegivelFidelidade: elegivel,
              carregandoElegibilidadeFidelidade: false,
              pontuarFidelidade: elegivel && state.pontuarFidelidade,
            ),
          );
        } catch (e, s) {
          emit(
            state.copyWith(
              clienteElegivelFidelidade: false,
              carregandoElegibilidadeFidelidade: false,
              pontuarFidelidade: false,
            ),
          );
          addError(e, s);
        }
      }

      add(const PagamentosRealizadosCarregouElegibilidade());
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

  Future<void> _carregarPermiteNotaFiscalEmail(
    Emitter<PagamentosRealizadosState> emit,
  ) async {
    final empresaId = _acessoGlobalSessao.empresaIdDaSessao;
    if (empresaId == null) return;

    try {
      final configuracao =
          await _recuperarConfiguracaoNotaFiscalEmail.call(empresaId);
      emit(state.copyWith(permiteNotaFiscalEmail: configuracao.ativo));
    } catch (e, s) {
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
          descontosItensTipo: const {},
          descontosItensValorTexto: const {},
          descontosItensAplicado: const {},
          erro: null,
        ),
      );
      return;
    }

    final valorBase = state.valorTotalProdutosSemPromocao;
    final valorInformado = _toDouble(event.valorTexto);
    if (valorInformado == null) {
      emit(state.copyWith(erro: 'Informe um valor válido para desconto.'));
      return;
    }

    if (valorBase <= 0 && valorInformado > 0) {
      emit(
        state.copyWith(
          erro:
              'Não há produtos sem promoção para aplicar desconto geral.',
        ),
      );
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

    descontoAplicado = double.parse(descontoAplicado.toStringAsFixed(2));

    // Desconto do romaneio geral é distribuído proporcionalmente pelo
    // valor de cada produto SEM promoção (não pela quantidade) -- produto
    // mais caro absorve fatia maior do desconto. Produto com promoção fica
    // de fora (já tem desconto embutido, não empilha com o geral). O
    // último item elegível fica com o resto da divisão (soma - já
    // distribuído) em vez de sua fatia exata, pra a soma dos descontos por
    // item bater centavo a centavo com o desconto total aplicado (evita
    // erro de arredondamento por soma).
    final distribuicao = _recalcularDistribuicaoDesconto(
      descontoAplicado,
      state.promocaoEscolhidaPorItem,
    );

    emit(
      state.copyWith(
        descontoTipo: event.tipo,
        descontoValorTexto: event.valorTexto,
        valorDescontoAplicado: descontoAplicado,
        descontosItensTipo: distribuicao.tipo,
        descontosItensValorTexto: distribuicao.valorTexto,
        descontosItensAplicado: distribuicao.aplicado,
        erro: null,
      ),
    );
  }

  void _onTaxaEntregaAlterada(
    PagamentosRealizadosTaxaEntregaAlterada event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    if (event.valorTexto.trim().isEmpty) {
      emit(
        state.copyWith(
          taxaEntregaValorTexto: '',
          valorTaxaEntregaAplicado: 0,
          erro: null,
        ),
      );
      return;
    }

    final valorInformado = _toDouble(event.valorTexto);
    if (valorInformado == null || valorInformado < 0) {
      emit(
        state.copyWith(erro: 'Informe um valor válido para taxa de entrega.'),
      );
      return;
    }

    emit(
      state.copyWith(
        taxaEntregaValorTexto: event.valorTexto,
        valorTaxaEntregaAplicado:
            double.parse(valorInformado.toStringAsFixed(2)),
        erro: null,
      ),
    );
  }

  void _onDescontosItensLimpos(
    PagamentosRealizadosDescontosItensLimpos event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    emit(
      state.copyWith(
        descontoTipo: null,
        descontoValorTexto: '',
        valorDescontoAplicado: 0,
        descontosItensTipo: const {},
        descontosItensValorTexto: const {},
        descontosItensAplicado: const {},
        erro: null,
      ),
    );
  }

  // Recalcula a distribuição do desconto geral entre os produtos SEM
  // promoção do mapa informado. Usado tanto ao alterar o desconto geral
  // quanto ao escolher/remover promoção de item com desconto geral já
  // aplicado (redistribuição reativa, ver _onPromocaoEscolhida).
  ({
    Map<int, DescontoTipo> tipo,
    Map<int, String> valorTexto,
    Map<int, double> aplicado,
  }) _recalcularDistribuicaoDesconto(
    double descontoTotal,
    Map<int, OpcaoElegivel> promocaoEscolhidaPorItem,
  ) {
    final produtos = (state.resumo?.produtosCompartilhados ?? const [])
        .where((p) => !promocaoEscolhidaPorItem.containsKey(p.produtoId))
        .toList(growable: false);
    final valorBase = produtos.fold<double>(
      0,
      (soma, p) => soma + p.quantidade * p.valorUnitario,
    );

    final aplicado = _distribuirDescontoProporcional(
      produtos: produtos,
      descontoTotal: descontoTotal,
      valorBase: valorBase,
    );

    return (
      tipo: {
        for (final produto in produtos)
          produto.produtoId: DescontoTipo.valorBruto,
      },
      valorTexto: {
        for (final entrada in aplicado.entries)
          entrada.key: entrada.value.toStringAsFixed(2),
      },
      aplicado: aplicado,
    );
  }

  Map<int, double> _distribuirDescontoProporcional({
    required List<ProdutoCompartilhado> produtos,
    required double descontoTotal,
    required double valorBase,
  }) {
    if (produtos.isEmpty || valorBase <= 0 || descontoTotal <= 0) {
      return const {};
    }

    final mapa = <int, double>{};
    var somaDistribuida = 0.0;

    for (var i = 0; i < produtos.length; i++) {
      final produto = produtos[i];
      final valorItem = produto.quantidade * produto.valorUnitario;

      final parcela = i == produtos.length - 1
          ? double.parse((descontoTotal - somaDistribuida).toStringAsFixed(2))
          : double.parse(
              (descontoTotal * (valorItem / valorBase)).toStringAsFixed(2),
            );

      mapa[produto.produtoId] = parcela;
      somaDistribuida += parcela;
    }

    return mapa;
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

    // Desconto manual e promocao/cupom sao mutuamente exclusivos por
    // produtoId -- aplicar desconto manual remove a promocao escolhida
    // desse item, se houver (ver tambem _onPromocaoEscolhida, sentido
    // inverso).
    final promocaoMap = Map<int, OpcaoElegivel>.from(
      state.promocaoEscolhidaPorItem,
    )..remove(event.produtoId);

    emit(
      state.copyWith(
        descontosItensTipo: tipoMap,
        descontosItensValorTexto: valorTextoMap,
        descontosItensAplicado: aplicadoMap,
        promocaoEscolhidaPorItem: promocaoMap,
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

    if (state.exigeEmailNota && !_emailRegex.hasMatch(state.emailNota.trim())) {
      emit(
        state.copyWith(
          erro: 'Informe um e-mail válido para o envio da nota fiscal.',
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
    final totalAPagar = state.valorTotalAPagar;
    final troco = possuiDinheiro && totalBruto > totalAPagar
        ? totalBruto - totalAPagar
        : 0.0;
    final totalLiquido = totalBruto - troco;

    if ((totalLiquido - totalAPagar).abs() > 0.01) {
      emit(
        state.copyWith(
          erro:
              'O total dos pagamentos deve ser igual ao valor pendente de ${_formatarMoeda(totalAPagar)}.',
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

  void _onPontuarFidelidadeAlterado(
    PagamentosRealizadosPontuarFidelidadeAlterado event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    if (!state.clienteElegivelFidelidade) return;

    emit(
      state.copyWith(
        pontuarFidelidade: event.pontuarFidelidade,
        erro: null,
      ),
    );
  }

  void _onEnviarNotaPorEmailAlterado(
    PagamentosRealizadosEnviarNotaPorEmailAlterado event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    emit(
      state.copyWith(
        enviarNotaPorEmail: event.enviarNotaPorEmail,
        erro: null,
      ),
    );
  }

  void _onEmailNotaAlterado(
    PagamentosRealizadosEmailNotaAlterado event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    emit(state.copyWith(emailNota: event.emailNota, erro: null));
  }

  Future<void> _onCarregouElegibilidade(
    PagamentosRealizadosCarregouElegibilidade event,
    Emitter<PagamentosRealizadosState> emit,
  ) async {
    final produtos = state.resumo?.produtosCompartilhados ?? const [];
    if (produtos.isEmpty) return;

    emit(state.copyWith(carregandoElegibilidade: true));

    try {
      final itens = await _montarItensApuracao(produtos);
      if (itens.isEmpty) {
        emit(state.copyWith(carregandoElegibilidade: false));
        return;
      }

      final resultado = await _apurarElegibilidade.call(
        clienteId: state.pessoaId,
        itens: itens.values.toList(),
        codigoCupom: state.cupomCodigoAplicado,
      );

      final opcoesPorItem = _mapearOpcoesPorProduto(itens, resultado);

      emit(
        state.copyWith(
          opcoesElegiveisPorItem: opcoesPorItem,
          referenciaIdPorProdutoId: itens.map(
            (produtoId, item) => MapEntry(produtoId, item.referenciaId),
          ),
          promocaoEscolhidaPorItem: _autoAplicarPromocaoUnica(
            opcoesPorItem,
            state.promocaoEscolhidaPorItem,
            state.descontosItensAplicado,
          ),
          carregandoElegibilidade: false,
        ),
      );
    } catch (e, s) {
      // Elegibilidade e um extra do fluxo de pagamento -- falha aqui nao
      // pode travar a venda, so fica sem opcoes de promocao/cupom.
      emit(state.copyWith(carregandoElegibilidade: false));
      addError(e, s);
    }
  }

  // Mapeia produtoId -> item de apuracao (com referenciaId), consultando o
  // leitor por produtoId pra descobrir a referencia de cada item do
  // carrinho (ProdutoCompartilhado nao carrega referenciaId).
  Future<Map<int, ItemApuracaoElegibilidade>> _montarItensApuracao(
    List<ProdutoCompartilhado> produtos,
  ) async {
    final itens = <int, ItemApuracaoElegibilidade>{};

    for (final produto in produtos) {
      try {
        final leitorData =
            await _leitorDataDatasource.getDataPorProdutoId(produto.produtoId);
        if (leitorData == null) continue;

        itens[produto.produtoId] = ItemApuracaoElegibilidade(
          referenciaId: leitorData.idReferencia,
          produtoId: produto.produtoId,
          quantidade: produto.quantidade,
          valorUnitario: produto.valorUnitario,
        );
      } catch (e, s) {
        addError(e, s);
      }
    }

    return itens;
  }

  Map<int, List<OpcaoElegivel>> _mapearOpcoesPorProduto(
    Map<int, ItemApuracaoElegibilidade> itensPorProduto,
    ResultadoElegibilidade resultado,
  ) {
    final opcoesPorReferencia = {
      for (final item in resultado.itens) item.referenciaId: item.opcoesElegiveis,
    };

    return {
      for (final entrada in itensPorProduto.entries)
        entrada.key: opcoesPorReferencia[entrada.value.referenciaId] ?? const [],
    };
  }

  void _onPromocaoEscolhida(
    PagamentosRealizadosPromocaoEscolhida event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    final promocaoMap = Map<int, OpcaoElegivel>.from(
      state.promocaoEscolhidaPorItem,
    );

    if (event.opcao == null) {
      promocaoMap.remove(event.produtoId);
    } else {
      promocaoMap[event.produtoId] = event.opcao!;
    }

    // Mutuamente exclusivo com desconto manual do mesmo produto (sentido
    // inverso de _onDescontoItemAlterado).
    var tipoMap = Map<int, DescontoTipo>.from(state.descontosItensTipo)
      ..remove(event.produtoId);
    var valorTextoMap = Map<int, String>.from(state.descontosItensValorTexto)
      ..remove(event.produtoId);
    var aplicadoMap = Map<int, double>.from(state.descontosItensAplicado)
      ..remove(event.produtoId);

    var valorDescontoAplicado = state.valorDescontoAplicado;
    var descontoTipo = state.descontoTipo;
    var descontoValorTexto = state.descontoValorTexto;
    String? avisoRedistribuicao;

    // Item ganhou/perdeu promoção com desconto geral já distribuído --
    // redistribui a fatia do desconto geral entre os produtos sem promoção
    // restantes, senão a soma dos descontos por item fica menor que o
    // desconto geral aplicado (ver _recalcularDistribuicaoDesconto).
    if (state.valorDescontoAplicado > 0) {
      final distribuicao = _recalcularDistribuicaoDesconto(
        state.valorDescontoAplicado,
        promocaoMap,
      );
      if (distribuicao.aplicado.isEmpty) {
        valorDescontoAplicado = 0;
        descontoTipo = null;
        descontoValorTexto = '';
        tipoMap = const {};
        valorTextoMap = const {};
        aplicadoMap = const {};
        avisoRedistribuicao = 'Desconto geral removido: todos os produtos '
            'agora têm promoção aplicada.';
      } else {
        tipoMap = distribuicao.tipo;
        valorTextoMap = distribuicao.valorTexto;
        aplicadoMap = distribuicao.aplicado;
      }
    }

    emit(
      state.copyWith(
        promocaoEscolhidaPorItem: promocaoMap,
        descontoTipo: descontoTipo,
        descontoValorTexto: descontoValorTexto,
        valorDescontoAplicado: valorDescontoAplicado,
        descontosItensTipo: tipoMap,
        descontosItensValorTexto: valorTextoMap,
        descontosItensAplicado: aplicadoMap,
        erro: avisoRedistribuicao,
      ),
    );
  }

  // Picker global de promocoes (ver _ResumoPagamentoCard no widget). Marcar
  // aplica a promocao em todo produto elegivel ainda sem OUTRA promocao
  // diferente aplicada (conflito e bloqueado na UI, nao resolvido aqui).
  // Desmarcar remove a promocao de todo produto onde estava aplicada.
  void _onPromocaoGlobalAlterada(
    PagamentosRealizadosPromocaoGlobalAlterada event,
    Emitter<PagamentosRealizadosState> emit,
  ) {
    final promocaoMap = Map<int, OpcaoElegivel>.from(
      state.promocaoEscolhidaPorItem,
    );

    if (!event.marcado) {
      promocaoMap.removeWhere(
        (_, opcao) => opcao.id == event.promocaoId && !opcao.ehCupom,
      );
      emit(state.copyWith(promocaoEscolhidaPorItem: promocaoMap, erro: null));
      return;
    }

    final tipoMap = Map<int, DescontoTipo>.from(state.descontosItensTipo);
    final valorTextoMap =
        Map<int, String>.from(state.descontosItensValorTexto);
    final aplicadoMap = Map<int, double>.from(state.descontosItensAplicado);

    for (final entrada in state.opcoesElegiveisPorItem.entries) {
      final produtoId = entrada.key;
      final opcaoExistente = promocaoMap[produtoId];
      if (opcaoExistente != null && opcaoExistente.id != event.promocaoId) {
        continue;
      }

      for (final opcao in entrada.value) {
        if (opcao.id == event.promocaoId && !opcao.ehCupom) {
          promocaoMap[produtoId] = opcao;
          tipoMap.remove(produtoId);
          valorTextoMap.remove(produtoId);
          aplicadoMap.remove(produtoId);
          break;
        }
      }
    }

    emit(
      state.copyWith(
        promocaoEscolhidaPorItem: promocaoMap,
        descontosItensTipo: tipoMap,
        descontosItensValorTexto: valorTextoMap,
        descontosItensAplicado: aplicadoMap,
        erro: null,
      ),
    );
  }

  Future<void> _onCupomInformado(
    PagamentosRealizadosCupomInformado event,
    Emitter<PagamentosRealizadosState> emit,
  ) async {
    final codigo = event.codigo.trim();
    if (codigo.isEmpty) {
      emit(state.copyWith(erro: 'Informe o código do cupom.'));
      return;
    }

    final produtos = state.resumo?.produtosCompartilhados ?? const [];
    emit(state.copyWith(carregandoElegibilidade: true, cupomErro: null));

    try {
      final itens = await _montarItensApuracao(produtos);
      final resultado = await _apurarElegibilidade.call(
        clienteId: state.pessoaId,
        itens: itens.values.toList(),
        codigoCupom: codigo,
      );

      if (resultado.cupomInvalido != null) {
        emit(
          state.copyWith(
            carregandoElegibilidade: false,
            cupomErro: resultado.cupomInvalido,
            cupomCodigoAplicado: null,
          ),
        );
        return;
      }

      final opcoesPorItem = _mapearOpcoesPorProduto(itens, resultado);

      emit(
        state.copyWith(
          opcoesElegiveisPorItem: opcoesPorItem,
          referenciaIdPorProdutoId: itens.map(
            (produtoId, item) => MapEntry(produtoId, item.referenciaId),
          ),
          promocaoEscolhidaPorItem: _autoAplicarPromocaoUnica(
            opcoesPorItem,
            state.promocaoEscolhidaPorItem,
            state.descontosItensAplicado,
          ),
          carregandoElegibilidade: false,
          cupomCodigoAplicado: codigo,
          cupomErro: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregandoElegibilidade: false,
          cupomErro: mensagemDeErroApi(e, 'Falha ao validar cupom.'),
        ),
      );
      addError(e, s);
    }
  }

  // Para cada produto, se ele tiver exatamente 1 opcao elegivel nao-cupom
  // (cupom sempre exige codigo digitado, fluxo manual), aplica ela
  // automaticamente nesse produto -- independente de quantas promocoes
  // distintas existem no carrinho como um todo. Produto com 2+ opcoes
  // elegiveis simultaneas (conflito real) continua exigindo escolha manual.
  // Defensivo: nunca sobrescreve item que ja tem promocao escolhida ou
  // desconto manual ja aplicado.
  Map<int, OpcaoElegivel> _autoAplicarPromocaoUnica(
    Map<int, List<OpcaoElegivel>> opcoesPorItem,
    Map<int, OpcaoElegivel> promocaoAtual,
    Map<int, double> descontosItensAplicado,
  ) {
    final resultado = Map<int, OpcaoElegivel>.from(promocaoAtual);

    for (final entrada in opcoesPorItem.entries) {
      final produtoId = entrada.key;
      if (resultado.containsKey(produtoId)) continue;
      if ((descontosItensAplicado[produtoId] ?? 0) > 0) continue;

      final naoCupom =
          entrada.value.where((opcao) => !opcao.ehCupom).toList();
      if (naoCupom.length != 1) continue;

      resultado[produtoId] = naoCupom.first;
    }

    return resultado;
  }

  Future<void> _onCupomRemovido(
    PagamentosRealizadosCupomRemovido event,
    Emitter<PagamentosRealizadosState> emit,
  ) async {
    // Limpa a escolha de qualquer item que estava usando o cupom removido
    // (promocoes escolhidas continuam intactas).
    final promocaoMap = Map<int, OpcaoElegivel>.from(
      state.promocaoEscolhidaPorItem,
    )..removeWhere((_, opcao) => opcao.ehCupom);

    emit(
      state.copyWith(
        cupomCodigoAplicado: null,
        cupomErro: null,
        promocaoEscolhidaPorItem: promocaoMap,
      ),
    );

    add(const PagamentosRealizadosCarregouElegibilidade());
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
