import 'package:comercial/data.dart';

class ReceberRomaneioNoCaixa {
  final IRomaneiosRepository _repository;

  ReceberRomaneioNoCaixa({required IRomaneiosRepository repository})
      : _repository = repository;

  Future<void> call({
    required int caixaId,
    required int romaneioId,
  }) {
    return _repository.receberRomaneioNoCaixa(
      caixaId: caixaId,
      romaneioId: romaneioId,
    );
  }
}
