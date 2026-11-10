import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:comercial/domain/use_cases/faturar_pedido.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/domain/models/caixa.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo extends Fake implements IPedidosRepository {
  int? caixaFaturado;
  @override
  Future<void> faturarPedido(int id, {required int caixaId}) async =>
      caixaFaturado = caixaId;
}

class _Caixa extends Fake implements Caixa {
  @override
  final int id;
  _Caixa(this.id);
}

class _Aberto extends Fake implements RecuperarCaixaAberto {
  final int? id;
  _Aberto(this.id);
  @override
  Future<Caixa?> call({required int idEmpresa, required int idTerminal}) async =>
      id == null ? null : _Caixa(id!);
}

class _Sessao extends Fake implements IAcessoGlobalSessao {
  int? atualizado;
  @override
  int? get empresaIdDaSessao => 1;
  @override
  int? get terminalIdDaSessao => 1;
  @override
  void atualizarCaixaIdDaSessao({required int terminalId, int? caixaId}) =>
      atualizado = caixaId;
}

void main() {
  test('caixa da sessão velho: fatura no caixa aberto e corrige a sessão', () async {
    final repo = _Repo();
    final sessao = _Sessao();
    await FaturarPedido(
      repository: repo,
      recuperarCaixaAberto: _Aberto(217),
      sessao: sessao,
    )(249, caixaId: 216);
    expect(repo.caixaFaturado, 217);
    expect(sessao.atualizado, 217);
  });

  test('sem caixa aberto na resposta: mantém o da sessão', () async {
    final repo = _Repo();
    await FaturarPedido(
      repository: repo,
      recuperarCaixaAberto: _Aberto(null),
      sessao: _Sessao(),
    )(249, caixaId: 216);
    expect(repo.caixaFaturado, 216);
  });
}
