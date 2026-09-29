import 'package:financeiro/domain/models/despesa.dart';
import 'package:financeiro/domain/models/despesa_ocorrencia_calendario.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';

/// Ocorrências de um dia pagas pelo mesmo cartão de crédito -- base pra
/// mostrar "Marcar cartão como pago" agrupado em vez de item por item.
class GrupoCartao {
  final int origemPagamentoId;
  final String nome;
  final List<DespesaOcorrenciaCalendario> ocorrencias;

  const GrupoCartao({
    required this.origemPagamentoId,
    required this.nome,
    required this.ocorrencias,
  });

  List<DespesaOcorrenciaCalendario> get pendentes =>
      ocorrencias.where((o) => o.status == StatusDespesa.pendente).toList();

  int get totalPagas =>
      ocorrencias.where((o) => o.status == StatusDespesa.pago).length;

  double get totalPendente =>
      pendentes.fold(0.0, (soma, o) => soma + o.valor);

  bool get totalmentePago => ocorrencias.isNotEmpty && pendentes.isEmpty;
}

/// Agrupa [ocorrencias] por origem de pagamento quando a origem for do tipo
/// cartão de crédito. Ocorrências canceladas ou de outras origens ficam de
/// fora -- seguem renderizadas individualmente.
List<GrupoCartao> agruparOcorrenciasPorCartao(
  List<DespesaOcorrenciaCalendario> ocorrencias,
  Map<int, OrigemPagamentoDespesa> origemPagamentoPorId,
) {
  final porOrigem = <int, List<DespesaOcorrenciaCalendario>>{};
  for (final o in ocorrencias) {
    if (o.status == StatusDespesa.cancelado) continue;
    final origem = origemPagamentoPorId[o.origemPagamentoId];
    if (origem == null || origem.tipo != TipoOrigemPagamentoDespesa.cartaoCredito) {
      continue;
    }
    porOrigem.putIfAbsent(o.origemPagamentoId, () => []).add(o);
  }

  return [
    for (final entrada in porOrigem.entries)
      GrupoCartao(
        origemPagamentoId: entrada.key,
        nome: origemPagamentoPorId[entrada.key]!.nome,
        ocorrencias: entrada.value,
      ),
  ];
}
