part of 'pagamentos_realizados_bloc.dart';

enum PagamentosRealizadosStep {
  inicial,
  carregando,
  editando,
  falha,
  concluido,
}

class PagamentosRealizadosState extends Equatable {
  final PagamentosRealizadosStep step;
  final String? hashLista;
  final PagamentosRealizadosResumo? resumo;
  final List<SelectData> formasDePagamento;
  final List<PagamentoRealizadoLinha> linhas;
  final String? erro;
  final List<Map<String, dynamic>> resultado;

  const PagamentosRealizadosState({
    this.step = PagamentosRealizadosStep.inicial,
    this.hashLista,
    this.resumo,
    this.formasDePagamento = const [],
    this.linhas = const [],
    this.erro,
    this.resultado = const [],
  });

  double get valorTotalProdutos => resumo?.valorTotalProdutos ?? 0;
  int get quantidadeTotalProdutos => resumo?.quantidadeTotalProdutos ?? 0;
  double get valorTotalBruto =>
      linhas.fold<double>(0, (soma, linha) => soma + linha.valor);
  double get valorTroco => _possuiDinheiro && valorTotalBruto > valorTotalProdutos
      ? valorTotalBruto - valorTotalProdutos
      : 0;
  double get valorLiquido => valorTotalBruto - valorTroco;
  double get valorRestante =>
      (valorTotalProdutos - valorLiquido).clamp(0, double.infinity).toDouble();
  bool get podeAdicionarLinha => step == PagamentosRealizadosStep.editando;
  bool get podeFinalizar =>
      step == PagamentosRealizadosStep.editando && linhas.isNotEmpty;

  bool get _possuiDinheiro => linhas.any((linha) => linha.ehDinheiro);

  PagamentosRealizadosState copyWith({
    PagamentosRealizadosStep? step,
    Object? hashLista = _sentinela,
    PagamentosRealizadosResumo? resumo,
    List<SelectData>? formasDePagamento,
    List<PagamentoRealizadoLinha>? linhas,
    Object? erro = _sentinela,
    List<Map<String, dynamic>>? resultado,
  }) {
    return PagamentosRealizadosState(
      step: step ?? this.step,
      hashLista:
          identical(hashLista, _sentinela) ? this.hashLista : hashLista as String?,
      resumo: resumo ?? this.resumo,
      formasDePagamento: formasDePagamento ?? this.formasDePagamento,
      linhas: linhas ?? this.linhas,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
      resultado: resultado ?? this.resultado,
    );
  }

  @override
  List<Object?> get props => [
        step,
        hashLista,
        resumo,
        formasDePagamento,
        linhas,
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