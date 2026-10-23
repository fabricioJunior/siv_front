import 'package:empresas/domain/entities/desconto_fidelidade.dart';

abstract class IDescontosFidelidadeRepository {
  Future<List<DescontoFidelidade>> listar(int empresaId);

  Future<void> salvar(int empresaId, DescontoFidelidade desconto);

  Future<void> excluir(int empresaId, int id);
}
