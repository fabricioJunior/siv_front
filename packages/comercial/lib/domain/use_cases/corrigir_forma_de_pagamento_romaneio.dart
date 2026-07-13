import 'package:comercial/domain/data/repositories/i_romaneios_repository.dart';
import 'package:comercial/domain/models/romaneio.dart';

class CorrigirFormaDePagamentoRomaneio {
  final IRomaneiosRepository _repository;

  CorrigirFormaDePagamentoRomaneio({
    required IRomaneiosRepository repository,
  }) : _repository = repository;

  Future<Romaneio> call({
    required int caixaId,
    required int romaneioId,
    required List<Map<String, dynamic>> pagamentos,
  }) {
    return _repository.corrigirFormaDePagamento(
      caixaId: caixaId,
      romaneioId: romaneioId,
      pagamentos: pagamentos,
    );
  }
}
