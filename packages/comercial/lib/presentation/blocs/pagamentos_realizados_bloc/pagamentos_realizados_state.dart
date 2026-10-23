part of 'pagamentos_realizados_bloc.dart';

enum PagamentosRealizadosStep {
  inicial,
  carregando,
  editando,
  falha,
  concluido,
}

enum DescontoTipo {
  valorBruto,
  porcentagem,
  forcaValorTotal,
}

class PagamentosRealizadosState extends Equatable {
  final PagamentosRealizadosStep step;
  final String? hashLista;
  final int? pessoaId;
  final PagamentosRealizadosResumo? resumo;
  final List<SelectData> formasDePagamento;
  final List<PagamentoRealizadoLinha> linhas;
  final bool carregandoSaldoCreditoDevolucao;
  final double saldoCreditoDevolucao;
  final DescontoTipo? descontoTipo;
  final String descontoValorTexto;
  final double valorDescontoAplicado;
  final String taxaEntregaValorTexto;
  final double valorTaxaEntregaAplicado;
  final double abatimentoTotal;
  final Map<int, DescontoTipo> descontosItensTipo;
  final Map<int, String> descontosItensValorTexto;
  final Map<int, double> descontosItensAplicado;
  final String? erro;
  final List<Map<String, dynamic>> resultado;
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final bool pontuarFidelidade;
  final bool clienteElegivelFidelidade;
  final bool carregandoElegibilidadeFidelidade;
  // Distingue "cliente não elegível de verdade" de "erro na consulta"
  // (rede, permissão, etc) -- os dois zeravam clienteElegivelFidelidade
  // igual, e a UI mostrava sempre "cliente sem cadastro", mascarando o erro.
  final bool erroElegibilidadeFidelidade;
  final bool clienteGenerico;
  final bool permiteNotaFiscalEmail;
  final bool enviarNotaPorEmail;
  final String emailNota;
  final String? emailClienteCadastrado;
  // Opcoes de promocao/cupom elegiveis por produtoId (chave = produtoId,
  // mesmo padrao das outras Maps deste state, mesmo a API respondendo por
  // referenciaId -- o mapeamento produtoId->referenciaId e feito no bloc).
  final Map<int, List<OpcaoElegivel>> opcoesElegiveisPorItem;
  // Promocao/cupom escolhido pelo operador por produtoId. Mutuamente
  // exclusivo com descontosItensAplicado (ver bloc).
  final Map<int, OpcaoElegivel> promocaoEscolhidaPorItem;
  final Map<int, int> referenciaIdPorProdutoId;
  final bool carregandoElegibilidade;
  // Promocao/cupom sao exclusivos por produto: item tem 1 promocao
  // (promocaoEscolhidaPorItem, so nao-cupom) OU N cupons cumulativos aqui
  // (todas as opcoes de cupom dos codigos aplicados que servem ao item).
  final Map<int, List<OpcaoElegivel>> cuponsEscolhidosPorItem;
  // Codigos aplicados na venda (maiusculos, sem repeticao, max 5).
  final List<String> cuponsAplicados;
  final String? cupomErro;
  // Resgate de pontos de fidelidade: opcoes do cliente (null = indisponivel/
  // falha) e escolha do operador (faixa OU pontos livres, nunca os dois).
  final OpcoesResgatePontos? opcoesResgate;
  final int? resgateFaixaId;
  final int? resgatePontos;

  const PagamentosRealizadosState({
    this.step = PagamentosRealizadosStep.inicial,
    this.hashLista,
    this.pessoaId,
    this.resumo,
    this.formasDePagamento = const [],
    this.linhas = const [],
    this.carregandoSaldoCreditoDevolucao = false,
    this.saldoCreditoDevolucao = 0,
    this.descontoTipo,
    this.descontoValorTexto = '',
    this.valorDescontoAplicado = 0,
    this.taxaEntregaValorTexto = '',
    this.valorTaxaEntregaAplicado = 0,
    this.abatimentoTotal = 0,
    this.descontosItensTipo = const {},
    this.descontosItensValorTexto = const {},
    this.descontosItensAplicado = const {},
    this.erro,
    this.resultado = const [],
    this.incluirCpfNaNota = false,
    this.cpfNaNota = '',
    this.pontuarFidelidade = false,
    this.clienteElegivelFidelidade = false,
    this.carregandoElegibilidadeFidelidade = false,
    this.erroElegibilidadeFidelidade = false,
    this.clienteGenerico = false,
    this.permiteNotaFiscalEmail = false,
    this.enviarNotaPorEmail = false,
    this.emailNota = '',
    this.emailClienteCadastrado,
    this.opcoesElegiveisPorItem = const {},
    this.promocaoEscolhidaPorItem = const {},
    this.referenciaIdPorProdutoId = const {},
    this.carregandoElegibilidade = false,
    this.cuponsEscolhidosPorItem = const {},
    this.cuponsAplicados = const [],
    this.cupomErro,
    this.opcoesResgate,
    this.resgateFaixaId,
    this.resgatePontos,
  });

  bool get exigeEmailNota =>
      enviarNotaPorEmail &&
      (emailClienteCadastrado == null || emailClienteCadastrado!.isEmpty);

  double get valorTotalProdutos => resumo?.valorTotalProdutos ?? 0;
  // Total dos produtos SEM promoção aplicada -- teto/base do desconto geral
  // do romaneio (produto com promoção já tem desconto embutido, não faz
  // sentido "descontar desconto" -- ver _onDescontoAlterado no bloc).
  double get valorTotalProdutosSemPromocao {
    final produtos = resumo?.produtosCompartilhados ?? const [];
    return produtos
        .where((p) => !produtoIdsComPromocao.contains(p.produtoId))
        .fold<double>(0, (soma, p) => soma + p.quantidade * p.valorUnitario);
  }
  // Produtos com promocao (exclusiva com desconto manual; cupom soma com ambos).
  Set<int> get produtoIdsComPromocao => promocaoEscolhidaPorItem.keys.toSet();
  double get valorDescontoItensTotal =>
      descontosItensAplicado.values.fold(0, (a, b) => a + b);
  // Forma de pagamento escolhida, só quando há exatamente 1 linha com forma
  // preenchida -- usada pra recalcular prévia de desconto com override por
  // forma. NÃO exige valor digitado: o operador normalmente escolhe a forma
  // primeiro pra saber quanto cobrar, então a prévia precisa reagir antes
  // do campo "Valor recebido" ser preenchido. 0 ou 2+ linhas com forma
  // escolhida (pagamento não escolhido, ou dividido em mais de uma forma)
  // mantém o valor base (sem recálculo).
  int? get formaDePagamentoUnicaId {
    final comForma = linhas.where((l) => l.formaDePagamento != null);
    if (comForma.length != 1) return null;
    return comForma.first.formaDePagamento!.id;
  }

  // Desconto de promocao/cupom escolhido por item (valorDesconto da opcao
  // e por unidade -- multiplica pela quantidade do produto no carrinho).
  // Recalcula pela forma de pagamento escolhida quando a promoção tiver
  // override pra ela (ver OpcaoElegivel.valorDescontoParaForma).
  double get valorDescontoPromocaoTotal {
    if (promocaoEscolhidaPorItem.isEmpty && cuponsEscolhidosPorItem.isEmpty) {
      return 0;
    }
    final valorUnitarioPorProduto = {
      for (final produto in resumo?.produtosCompartilhados ?? const [])
        produto.produtoId: produto,
    };
    final formaId = formaDePagamentoUnicaId;
    final cupons = cuponsEscolhidosPorItem.entries.fold<double>(0,
        (soma, entrada) {
      final produto = valorUnitarioPorProduto[entrada.key];
      if (produto == null) return soma;
      // Cupom soma com promocao e desconto manual do item, ate o teto do preco.
      final promocao = promocaoEscolhidaPorItem[entrada.key];
      final jaDescontado = (promocao?.valorDescontoParaForma(
                formaId,
                valorUnitario: produto.valorUnitario,
              ) ??
              0) +
          (produto.quantidade > 0
              ? (descontosItensAplicado[entrada.key] ?? 0) / produto.quantidade
              : 0);
      return soma +
          descontoCuponsUnitario(
                entrada.value,
                produto.valorUnitario,
                jaDescontadoUnitario: jaDescontado,
              ) *
              produto.quantidade;
    });
    return cupons +
        promocaoEscolhidaPorItem.entries.fold<double>(0, (soma, entrada) {
      final produto = valorUnitarioPorProduto[entrada.key];
      if (produto == null) return soma;
      final desconto = entrada.value.valorDescontoParaForma(
        formaId,
        valorUnitario: produto.valorUnitario,
      );
      return soma + (desconto * produto.quantidade);
    });
  }

  // Cupons cumulativos: cada um desconta isolado sobre o preco base; a soma
  // tem teto no preco unitario (mesma regra do backend).
  static double descontoCuponsUnitario(
    List<OpcaoElegivel> cupons,
    double valorUnitario, {
    double jaDescontadoUnitario = 0,
  }) {
    final soma = cupons.fold<double>(0, (a, o) => a + o.valorDesconto);
    final teto = (valorUnitario - jaDescontadoUnitario).clamp(0, valorUnitario);
    return soma > teto ? teto.toDouble() : soma;
  }

  // Payload `cupons` do fechamento: produtoIds agrupados por codigo.
  List<Map<String, dynamic>> get cuponsParaPayload {
    final porCodigo = <String, List<int>>{};
    for (final entrada in cuponsEscolhidosPorItem.entries) {
      for (final opcao in entrada.value) {
        final codigo = opcao.codigo ??
            (cuponsAplicados.isNotEmpty ? cuponsAplicados.first : '');
        porCodigo.putIfAbsent(codigo, () => []).add(entrada.key);
      }
    }
    return [
      for (final e in porCodigo.entries) {'codigo': e.key, 'produtoIds': e.value},
    ];
  }

  // Desconto do romaneio geral (valorDescontoAplicado) é distribuído pelos
  // produtos assim que aplicado (ver _onDescontoAlterado no bloc) -- o
  // valor já está embutido em descontosItensAplicado, então não é
  // subtraído de novo aqui (evitaria contar o mesmo desconto duas vezes).
  // valorDescontoAplicado fica só como registro/exibição do último valor
  // "geral" informado.
  double get valorTotalComDesconto =>
      (valorTotalProdutos -
              valorDescontoItensTotal -
              valorDescontoPromocaoTotal)
          .clamp(0, double.infinity)
          .toDouble();
  // Taxa de entrega é somada FORA do desconto -- nunca sofre desconto,
  // mesma regra do frete FOB no backend.
  // Abatimento (adiantado/já lançado) só incide sobre itens − desconto.
  double get valorTotalAPagar =>
      (valorTotalComDesconto - valorDescontoResgate - abatimentoTotal)
          .clamp(0, double.infinity) +
      valorTaxaEntregaAplicado;
  // Pre-visualizacao do desconto por pontos (backend e a fonte da verdade).
  // Percentual incide sobre o total dos itens menos os demais descontos.
  double get valorDescontoResgate {
    final opcoes = opcoesResgate;
    if (opcoes == null) return 0;
    double desconto = 0;
    if (resgateFaixaId != null) {
      final faixa = opcoes.faixas.where((f) => f.id == resgateFaixaId);
      if (faixa.isEmpty) return 0;
      desconto = faixa.first.ehPercentual
          ? valorTotalComDesconto * faixa.first.valor / 100
          : faixa.first.valor;
    } else if (resgatePontos != null && opcoes.valorPorPonto != null) {
      desconto = resgatePontos! * opcoes.valorPorPonto!;
    }
    return double.parse(desconto.toStringAsFixed(2));
  }

  bool get possuiResgate => resgateFaixaId != null || resgatePontos != null;

  Map<String, int>? get resgatePayload => resgateFaixaId != null
      ? {'faixaId': resgateFaixaId!}
      : resgatePontos != null
          ? {'pontos': resgatePontos!}
          : null;

  bool get possuiOutroDesconto =>
      valorDescontoAplicado > 0 ||
      valorDescontoItensTotal > 0 ||
      promocaoEscolhidaPorItem.isNotEmpty ||
      possuiCupomAplicado;

  // Backend rejeita resgate quando todos os itens ja tem promocao/cupom.
  bool get todosItensComPromocao {
    final produtos = resumo?.produtosCompartilhados ?? const [];
    return produtos.isNotEmpty &&
        produtos.every((p) => promocaoEscolhidaPorItem.containsKey(p.produtoId));
  }

  // Maior quantidade de pontos livres cujo desconto nao excede o valor da venda.
  int get maxPontosLivres {
    final opcoes = opcoesResgate;
    final vpp = opcoes?.valorPorPonto;
    if (opcoes == null || vpp == null || vpp <= 0) return 0;
    final porValor = (valorTotalComDesconto / vpp + 1e-9).floor();
    return porValor < opcoes.saldo ? porValor : opcoes.saldo;
  }

  String? motivoFaixaIndisponivel(FaixaResgate f) {
    final saldo = opcoesResgate?.saldo ?? 0;
    if (!f.disponivel) {
      return f.pontos > saldo
          ? 'Faltam ${f.pontos - saldo} pontos'
          : 'Indisponível';
    }
    if (todosItensComPromocao) return 'Itens já têm promoção/cupom';
    if (!f.ehPercentual && f.valor > valorTotalComDesconto + 0.001) {
      return 'Desconto maior que o valor da venda';
    }
    if (!f.cumulativo && possuiOutroDesconto) {
      return 'Não cumulativo: remova os outros descontos';
    }
    return null;
  }

  String? get motivoPontosLivresIndisponivel {
    final opcoes = opcoesResgate;
    if (opcoes == null || opcoes.valorPorPonto == null) return 'Indisponível';
    if (todosItensComPromocao) return 'Itens já têm promoção/cupom';
    if (!opcoes.cumulativoValorPorPonto && possuiOutroDesconto) {
      return 'Não cumulativo: remova os outros descontos';
    }
    if (maxPontosLivres < 1) return 'Sem pontos utilizáveis nesta venda';
    return null;
  }

  // Resgate ativo que nao pode coexistir com outro desconto.
  bool get resgateNaoCumulativoAtivo {
    final opcoes = opcoesResgate;
    if (opcoes == null) return false;
    if (resgateFaixaId != null) {
      return opcoes.faixas.any((f) => f.id == resgateFaixaId && !f.cumulativo);
    }
    return resgatePontos != null && !opcoes.cumulativoValorPorPonto;
  }

  int get quantidadeTotalProdutos => resumo?.quantidadeTotalProdutos ?? 0;
  double get valorTotalBruto =>
      linhas.fold<double>(0, (soma, linha) => soma + linha.valor);
  double get valorTroco =>
      _possuiDinheiro && valorTotalBruto > valorTotalAPagar
          ? valorTotalBruto - valorTotalAPagar
          : 0;
  double get valorLiquido => valorTotalBruto - valorTroco;
  double get valorRestante => (valorTotalAPagar - valorLiquido)
      .clamp(0, double.infinity)
      .toDouble();
  double get valorDescontoAplicadoArredondado =>
      double.parse(valorDescontoAplicado.toStringAsFixed(2));
  double get valorTaxaEntregaAplicadoArredondado =>
      double.parse(valorTaxaEntregaAplicado.toStringAsFixed(2));
  bool get possuiCupomAplicado => cuponsAplicados.isNotEmpty;
  static const maxCupons = 5;
  bool get podeAdicionarCupom => cuponsAplicados.length < maxCupons;
  // Interseção das formas de pagamento permitidas pelas promoções escolhidas
  // com restrição (null = nenhuma promoção escolhida restringe forma de
  // pagamento). Interseção vazia é estado válido (nenhuma forma serve).
  Set<int>? get formasPagamentoPermitidasIds {
    final restricoes = promocaoEscolhidaPorItem.values
        .map((opcao) => opcao.formasPagamentoPermitidasIds)
        .whereType<List<int>>()
        .map((ids) => ids.toSet())
        .toList(growable: false);
    if (restricoes.isEmpty) return null;
    return restricoes.reduce((a, b) => a.intersection(b));
  }

  bool get podeAdicionarLinha => step == PagamentosRealizadosStep.editando;
  bool get podeFinalizar =>
      step == PagamentosRealizadosStep.editando && linhas.isNotEmpty;

  bool get _possuiDinheiro => linhas.any((linha) => linha.ehDinheiro);

  PagamentosRealizadosState copyWith({
    PagamentosRealizadosStep? step,
    Object? hashLista = _sentinela,
    Object? pessoaId = _sentinela,
    PagamentosRealizadosResumo? resumo,
    List<SelectData>? formasDePagamento,
    List<PagamentoRealizadoLinha>? linhas,
    bool? carregandoSaldoCreditoDevolucao,
    double? saldoCreditoDevolucao,
    Object? descontoTipo = _sentinela,
    String? descontoValorTexto,
    double? valorDescontoAplicado,
    String? taxaEntregaValorTexto,
    double? valorTaxaEntregaAplicado,
    double? abatimentoTotal,
    Map<int, DescontoTipo>? descontosItensTipo,
    Map<int, String>? descontosItensValorTexto,
    Map<int, double>? descontosItensAplicado,
    Object? erro = _sentinela,
    List<Map<String, dynamic>>? resultado,
    bool? incluirCpfNaNota,
    String? cpfNaNota,
    bool? pontuarFidelidade,
    bool? clienteElegivelFidelidade,
    bool? carregandoElegibilidadeFidelidade,
    bool? erroElegibilidadeFidelidade,
    bool? clienteGenerico,
    bool? permiteNotaFiscalEmail,
    bool? enviarNotaPorEmail,
    String? emailNota,
    Object? emailClienteCadastrado = _sentinela,
    Map<int, List<OpcaoElegivel>>? opcoesElegiveisPorItem,
    Map<int, OpcaoElegivel>? promocaoEscolhidaPorItem,
    Map<int, int>? referenciaIdPorProdutoId,
    bool? carregandoElegibilidade,
    Map<int, List<OpcaoElegivel>>? cuponsEscolhidosPorItem,
    List<String>? cuponsAplicados,
    Object? cupomErro = _sentinela,
    Object? opcoesResgate = _sentinela,
    Object? resgateFaixaId = _sentinela,
    Object? resgatePontos = _sentinela,
  }) {
    return PagamentosRealizadosState(
      step: step ?? this.step,
      hashLista: identical(hashLista, _sentinela)
          ? this.hashLista
          : hashLista as String?,
      pessoaId:
          identical(pessoaId, _sentinela) ? this.pessoaId : pessoaId as int?,
      resumo: resumo ?? this.resumo,
      formasDePagamento: formasDePagamento ?? this.formasDePagamento,
      linhas: linhas ?? this.linhas,
      carregandoSaldoCreditoDevolucao: carregandoSaldoCreditoDevolucao ??
          this.carregandoSaldoCreditoDevolucao,
      saldoCreditoDevolucao:
          saldoCreditoDevolucao ?? this.saldoCreditoDevolucao,
      descontoTipo: identical(descontoTipo, _sentinela)
          ? this.descontoTipo
          : descontoTipo as DescontoTipo?,
      descontoValorTexto: descontoValorTexto ?? this.descontoValorTexto,
      valorDescontoAplicado:
          valorDescontoAplicado ?? this.valorDescontoAplicado,
      taxaEntregaValorTexto:
          taxaEntregaValorTexto ?? this.taxaEntregaValorTexto,
      valorTaxaEntregaAplicado:
          valorTaxaEntregaAplicado ?? this.valorTaxaEntregaAplicado,
      abatimentoTotal: abatimentoTotal ?? this.abatimentoTotal,
      descontosItensTipo: descontosItensTipo ?? this.descontosItensTipo,
      descontosItensValorTexto:
          descontosItensValorTexto ?? this.descontosItensValorTexto,
      descontosItensAplicado:
          descontosItensAplicado ?? this.descontosItensAplicado,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
      resultado: resultado ?? this.resultado,
      incluirCpfNaNota: incluirCpfNaNota ?? this.incluirCpfNaNota,
      cpfNaNota: cpfNaNota ?? this.cpfNaNota,
      pontuarFidelidade: pontuarFidelidade ?? this.pontuarFidelidade,
      clienteElegivelFidelidade:
          clienteElegivelFidelidade ?? this.clienteElegivelFidelidade,
      carregandoElegibilidadeFidelidade: carregandoElegibilidadeFidelidade ??
          this.carregandoElegibilidadeFidelidade,
      erroElegibilidadeFidelidade:
          erroElegibilidadeFidelidade ?? this.erroElegibilidadeFidelidade,
      clienteGenerico: clienteGenerico ?? this.clienteGenerico,
      permiteNotaFiscalEmail:
          permiteNotaFiscalEmail ?? this.permiteNotaFiscalEmail,
      enviarNotaPorEmail: enviarNotaPorEmail ?? this.enviarNotaPorEmail,
      emailNota: emailNota ?? this.emailNota,
      emailClienteCadastrado: identical(emailClienteCadastrado, _sentinela)
          ? this.emailClienteCadastrado
          : emailClienteCadastrado as String?,
      opcoesElegiveisPorItem:
          opcoesElegiveisPorItem ?? this.opcoesElegiveisPorItem,
      promocaoEscolhidaPorItem:
          promocaoEscolhidaPorItem ?? this.promocaoEscolhidaPorItem,
      referenciaIdPorProdutoId:
          referenciaIdPorProdutoId ?? this.referenciaIdPorProdutoId,
      carregandoElegibilidade:
          carregandoElegibilidade ?? this.carregandoElegibilidade,
      cuponsEscolhidosPorItem:
          cuponsEscolhidosPorItem ?? this.cuponsEscolhidosPorItem,
      cuponsAplicados: cuponsAplicados ?? this.cuponsAplicados,
      cupomErro: identical(cupomErro, _sentinela)
          ? this.cupomErro
          : cupomErro as String?,
      opcoesResgate: identical(opcoesResgate, _sentinela)
          ? this.opcoesResgate
          : opcoesResgate as OpcoesResgatePontos?,
      resgateFaixaId: identical(resgateFaixaId, _sentinela)
          ? this.resgateFaixaId
          : resgateFaixaId as int?,
      resgatePontos: identical(resgatePontos, _sentinela)
          ? this.resgatePontos
          : resgatePontos as int?,
    );
  }

  @override
  List<Object?> get props => [
        step,
        hashLista,
        pessoaId,
        resumo,
        formasDePagamento,
        linhas,
        carregandoSaldoCreditoDevolucao,
        saldoCreditoDevolucao,
        descontoTipo,
        descontoValorTexto,
        valorDescontoAplicadoArredondado,
        taxaEntregaValorTexto,
        valorTaxaEntregaAplicadoArredondado,
        abatimentoTotal,
        descontosItensTipo,
        descontosItensValorTexto,
        descontosItensAplicado,
        erro,
        resultado,
        incluirCpfNaNota,
        cpfNaNota,
        pontuarFidelidade,
        clienteElegivelFidelidade,
        carregandoElegibilidadeFidelidade,
        erroElegibilidadeFidelidade,
        clienteGenerico,
        permiteNotaFiscalEmail,
        enviarNotaPorEmail,
        emailNota,
        emailClienteCadastrado,
        opcoesElegiveisPorItem,
        promocaoEscolhidaPorItem,
        referenciaIdPorProdutoId,
        carregandoElegibilidade,
        cuponsEscolhidosPorItem,
        cuponsAplicados,
        cupomErro,
        opcoesResgate,
        resgateFaixaId,
        resgatePontos,
      ];
}

class PagamentoRealizadoLinha extends Equatable {
  final String id;
  final SelectData? formaDePagamento;
  final String valorTexto;
  final String parcelasTexto;

  const PagamentoRealizadoLinha({
    required this.id,
    required this.formaDePagamento,
    required this.valorTexto,
    required this.parcelasTexto,
  });

  factory PagamentoRealizadoLinha.nova({
    SelectData? formaDePagamento,
  }) {
    return PagamentoRealizadoLinha(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      formaDePagamento: formaDePagamento,
      valorTexto: '',
      parcelasTexto: '1',
    );
  }

  double get valor => _toDouble(valorTexto) ?? 0;
  int get parcelas => _toInt(parcelasTexto) ?? 1;
  bool get ehDinheiro =>
      (formaDePagamento?.data['tipo']?.toString().trim().toLowerCase() ?? '') ==
      'dinheiro';
  bool get ehCreditoDevolucao {
    final dados = formaDePagamento?.data;
    final candidatos = [
      dados?['tipoDocumento']?.toString(),
      dados?['tipo']?.toString(),
      dados?['descricao']?.toString(),
      formaDePagamento?.nome,
    ];

    for (final item in candidatos) {
      final normalizado = (item ?? '')
          .toLowerCase()
          .trim()
          .replaceAll(' ', '_')
          .replaceAll('-', '_');
      if (normalizado.contains('credito_de_devolucao') ||
          normalizado.contains('crédito_de_devolução')) {
        return true;
      }
    }

    return false;
  }

  int get parcelasMaximas {
    final parcelas = formaDePagamento?.data['parcelas'];
    if (parcelas is int) return parcelas;
    if (parcelas is num) return parcelas.toInt();
    return int.tryParse(parcelas?.toString() ?? '') ?? 1;
  }

  bool get aceitaParcelamento => parcelasMaximas > 1;
  double get valorParcela => parcelas <= 0 ? 0 : valor / parcelas;

  PagamentoRealizadoLinha copyWith({
    SelectData? formaDePagamento,
    String? valorTexto,
    String? parcelasTexto,
  }) {
    return PagamentoRealizadoLinha(
      id: id,
      formaDePagamento: formaDePagamento ?? this.formaDePagamento,
      valorTexto: valorTexto ?? this.valorTexto,
      parcelasTexto: parcelasTexto ?? this.parcelasTexto,
    );
  }

  Map<String, dynamic> toJson({required int controle}) {
    return {
      'controle': controle,
      'formaDePagamentoId': formaDePagamento!.id,
      'parcela': parcelas,
      'valor': valor,
      'ehDinheiro': ehDinheiro,
    };
  }

  @override
  List<Object?> get props => [id, formaDePagamento, valorTexto, parcelasTexto];
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

const Object _sentinela = Object();
