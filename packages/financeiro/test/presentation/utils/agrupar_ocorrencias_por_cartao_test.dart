import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/presentation/utils/agrupar_ocorrencias_por_cartao.dart';
import 'package:flutter_test/flutter_test.dart';

DespesaOcorrenciaCalendario _ocorrencia({
  required int origemPagamentoId,
  required StatusDespesa status,
  double valor = 100,
  bool virtual = false,
}) {
  return DespesaOcorrenciaCalendario(
    despesaId: 1,
    descricao: 'x',
    valor: valor,
    categoriaId: 1,
    origemPagamentoId: origemPagamentoId,
    dataPagamento: DateTime(2026, 9, 10),
    status: status,
    virtual: virtual,
  );
}

void main() {
  final cartao = const OrigemPagamentoDespesa(
      id: 1, nome: 'Nubank', tipo: TipoOrigemPagamentoDespesa.cartaoCredito);
  final pix = const OrigemPagamentoDespesa(
      id: 2, nome: 'Pix', tipo: TipoOrigemPagamentoDespesa.pix);

  test('agrupa apenas ocorrências de origem cartão de crédito', () {
    final ocorrencias = [
      _ocorrencia(origemPagamentoId: 1, status: StatusDespesa.pendente),
      _ocorrencia(origemPagamentoId: 1, status: StatusDespesa.pago),
      _ocorrencia(origemPagamentoId: 2, status: StatusDespesa.pendente),
    ];

    final grupos = agruparOcorrenciasPorCartao(
        ocorrencias, {1: cartao, 2: pix});

    expect(grupos, hasLength(1));
    expect(grupos.single.origemPagamentoId, 1);
    expect(grupos.single.ocorrencias, hasLength(2));
    expect(grupos.single.pendentes, hasLength(1));
    expect(grupos.single.totalPagas, 1);
    expect(grupos.single.totalmentePago, isFalse);
  });

  test('grupo totalmente pago sem pendentes', () {
    final ocorrencias = [
      _ocorrencia(origemPagamentoId: 1, status: StatusDespesa.pago),
    ];

    final grupos = agruparOcorrenciasPorCartao(ocorrencias, {1: cartao});

    expect(grupos.single.totalmentePago, isTrue);
  });

  test('ignora ocorrências canceladas', () {
    final ocorrencias = [
      _ocorrencia(origemPagamentoId: 1, status: StatusDespesa.cancelado),
    ];

    final grupos = agruparOcorrenciasPorCartao(ocorrencias, {1: cartao});

    expect(grupos, isEmpty);
  });
}
