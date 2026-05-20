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
  final String? erro;
  final List<Map<String, dynamic>> resultado;

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
    this.erro,
    this.resultado = const [],
  });

  double get valorTotalProdutos => resumo?.valorTotalProdutos ?? 0;
  double get valorTotalComDesconto =>
      (valorTotalProdutos - valorDescontoAplicado)
          .clamp(0, double.infinity)
          .toDouble();
  int get quantidadeTotalProdutos => resumo?.quantidadeTotalProdutos ?? 0;
  double get valorTotalBruto =>
      linhas.fold<double>(0, (soma, linha) => soma + linha.valor);
  double get valorTroco =>
      _possuiDinheiro && valorTotalBruto > valorTotalComDesconto
          ? valorTotalBruto - valorTotalComDesconto
          : 0;
  double get valorLiquido => valorTotalBruto - valorTroco;
  double get valorRestante => (valorTotalComDesconto - valorLiquido)
      .clamp(0, double.infinity)
      .toDouble();
  double get valorDescontoAplicadoArredondado =>
      double.parse(valorDescontoAplicado.toStringAsFixed(2));
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
    Object? erro = _sentinela,
    List<Map<String, dynamic>>? resultado,
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
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
      resultado: resultado ?? this.resultado,
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
        erro,
        resultado,
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
