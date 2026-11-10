import 'package:comercial/domain/data/repositories/i_pedidos_repository.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/use_cases.dart';

class FaturarPedido {
  final IPedidosRepository _repository;
  final RecuperarCaixaAberto? _recuperarCaixaAberto;
  final IAcessoGlobalSessao? _sessao;

  FaturarPedido({
    required IPedidosRepository repository,
    RecuperarCaixaAberto? recuperarCaixaAberto,
    IAcessoGlobalSessao? sessao,
  }) : _repository = repository,
       _recuperarCaixaAberto = recuperarCaixaAberto,
       _sessao = sessao;

  Future<void> call(int id, {required int caixaId}) async =>
      _repository.faturarPedido(id, caixaId: await _caixaAberto(caixaId));

  /// O caixa da sessão fica velho quando outro operador fecha/abre caixa no
  /// mesmo terminal (a API recusa: "Caixa não está uma situação válida: aberto").
  /// Relê o caixa aberto do terminal e corrige a sessão; sem resposta, usa [caixaId].
  Future<int> _caixaAberto(int caixaId) async {
    final empresaId = _sessao?.empresaIdDaSessao;
    final terminalId = _sessao?.terminalIdDaSessao;
    if (_recuperarCaixaAberto == null || empresaId == null || terminalId == null) {
      return caixaId;
    }
    try {
      final atual = await _recuperarCaixaAberto.call(
        idEmpresa: empresaId,
        idTerminal: terminalId,
      );
      if (atual == null || atual.id == caixaId) return caixaId;
      _sessao?.atualizarCaixaIdDaSessao(terminalId: terminalId, caixaId: atual.id);
      return atual.id;
    } catch (_) {
      return caixaId;
    }
  }
}
