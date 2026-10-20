import 'package:comercial/models.dart';

int? _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

double _num(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '.')) ?? 0;

DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse('$v');

CreditoDevolucao creditoDevolucaoDeJson(Map<String, dynamic> j) {
  return CreditoDevolucao(
    id: _int(j['id']) ?? 0,
    codigo: '${j['codigo'] ?? 'C-${j['id']}'}',
    origem: '${j['origem'] ?? ''}',
    motivo: j['motivo']?.toString(),
    observacao: j['observacao']?.toString(),
    romaneioId: _int(j['romaneioId']),
    faturaId: _int(j['faturaId']),
    faturaParcela: _int(j['faturaParcela']),
    empresaId: _int(j['empresaId']) ?? 0,
    empresaNome: j['empresaNome']?.toString(),
    data: _data(j['data']) ?? DateTime.now(),
    validade: _data(j['validade']),
    valorOriginal: _num(j['valorOriginal']),
    valorRestante: _num(j['valorRestante']),
    situacao: SituacaoCreditoDevolucao.de(j['situacao']),
    operadorNome: j['operadorNome']?.toString(),
    encerradoEm: _data(j['encerradoEm']),
    motivoEncerramento: j['motivoEncerramento']?.toString(),
  );
}

ResumoCreditoDevolucao resumoCreditoDevolucaoDeJson(Map<String, dynamic> j) {
  return ResumoCreditoDevolucao(
    saldoDisponivel: _num(j['saldoDisponivel']),
    quantidadeDisponiveis: _int(j['quantidadeDisponiveis']) ?? 0,
    venceEm30Dias: _num(j['venceEm30Dias']),
    proximoVencimento: _data(j['proximoVencimento']),
    usado12Meses: _num(j['usado12Meses']),
    vendasComUso12Meses: _int(j['vendasComUso12Meses']) ?? 0,
    expirado12Meses: _num(j['expirado12Meses']),
    creditosExpirados12Meses: _int(j['creditosExpirados12Meses']) ?? 0,
  );
}

ResultadoAcaoCredito resultadoAcaoCreditoDeJson(Map<String, dynamic> j) {
  return ResultadoAcaoCredito(
    credito: creditoDevolucaoDeJson(j['credito'] as Map<String, dynamic>),
    saldoDisponivel: _num(j['saldoDisponivel']),
  );
}
