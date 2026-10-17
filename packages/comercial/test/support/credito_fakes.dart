import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/sessao.dart';
import 'package:empresas/models.dart';
import 'package:empresas/use_cases.dart';

CreditoDevolucao cred(int id, double restante,
        {SituacaoCreditoDevolucao s = SituacaoCreditoDevolucao.disponivel}) =>
    CreditoDevolucao(
      id: id,
      codigo: 'CR-$id',
      origem: 'avulso',
      empresaId: 1,
      data: DateTime(2026, 1, 1),
      valorOriginal: 100,
      valorRestante: restante,
      situacao: s,
    );

class FakeLista implements BuscarCreditosDevolucao {
  List<CreditoDevolucao> itens = [cred(1, 100)];
  Object? erro;
  int chamadas = 0;
  @override
  Future<List<CreditoDevolucao>> call(
      {required int pessoaId, String situacao = 'todos'}) async {
    chamadas++;
    if (erro != null) throw erro!;
    return itens;
  }
}

class FakeResumo implements BuscarResumoCreditoDevolucao {
  double saldo = 100;
  DateTime? proximoVencimento;
  double venceEm30 = 0;
  @override
  Future<ResumoCreditoDevolucao> call({required int pessoaId}) async =>
      ResumoCreditoDevolucao(
        saldoDisponivel: saldo,
        quantidadeDisponiveis: 1,
        venceEm30Dias: venceEm30,
        proximoVencimento: proximoVencimento,
      );
}

class FakeExtrato implements BuscarCreditoDevolucaoMovimentacoes {
  @override
  Future<List<CreditoDevolucaoMovimentacao>> call({
    required int pessoaId,
    List<int>? empresaIds,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async =>
      const [];
}

class FakeAdicionar implements AdicionarCreditoAvulso {
  Map<String, Object?>? args;
  Object? erro;
  @override
  Future<ResultadoAcaoCredito> call({
    required int pessoaId,
    required double valor,
    required String motivo,
    required String observacao,
    DateTime? validade,
    int? empresaId,
  }) async {
    if (erro != null) throw erro!;
    args = {
      'pessoaId': pessoaId,
      'valor': valor,
      'motivo': motivo,
      'observacao': observacao,
      'empresaId': empresaId,
    };
    return ResultadoAcaoCredito(credito: cred(2, valor), saldoDisponivel: 150);
  }
}

class FakeRemover implements RemoverCreditoDevolucao {
  Map<String, Object?>? args;
  @override
  Future<ResultadoAcaoCredito> call({
    required int pessoaId,
    required int creditoId,
    double? valor,
    required String motivo,
    String? observacao,
  }) async {
    args = {'creditoId': creditoId, 'valor': valor, 'motivo': motivo};
    return ResultadoAcaoCredito(credito: cred(1, 0), saldoDisponivel: 40);
  }
}

class FakeExpirar implements ExpirarCreditoDevolucao {
  Map<String, Object?>? args;
  @override
  Future<ResultadoAcaoCredito> call({
    required int pessoaId,
    required int creditoId,
    String? motivo,
  }) async {
    args = {'creditoId': creditoId, 'motivo': motivo};
    return ResultadoAcaoCredito(
        credito: cred(1, 0, s: SituacaoCreditoDevolucao.expirado),
        saldoDisponivel: 0);
  }
}

class FakeConfig implements RecuperarConfigCreditoDevolucao {
  bool falha = false;
  @override
  Future<ConfigCreditoDevolucao> call(int empresaId) async {
    if (falha) throw Exception('x');
    return const ConfigCreditoDevolucao(
        validadeDiasPadrao: 60, avisoDiasAntes: 10);
  }
}

class FakeEmpresas implements RecuperarEmpresas {
  @override
  Future<List<Empresa>> call() async => const [];
}

class FakeSessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;
  @override
  noSuchMethod(Invocation i) => null;
}

