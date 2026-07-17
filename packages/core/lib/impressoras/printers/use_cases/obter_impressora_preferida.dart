import 'package:core/impressoras/printers/repositories/i_impressora_preferida_repository.dart';

class ObterImpressoraPreferida {
  final IImpressoraPreferidaRepository _repository;

  ObterImpressoraPreferida({required IImpressoraPreferidaRepository repository})
      : _repository = repository;

  Future<String?> call() {
    return _repository.obterUltimaImpressora();
  }
}
