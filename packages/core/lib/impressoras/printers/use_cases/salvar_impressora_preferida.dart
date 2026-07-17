import 'package:core/impressoras/printers/repositories/i_impressora_preferida_repository.dart';

class SalvarImpressoraPreferida {
  final IImpressoraPreferidaRepository _repository;

  SalvarImpressoraPreferida({required IImpressoraPreferidaRepository repository})
      : _repository = repository;

  Future<void> call(String nomeImpressora) {
    return _repository.salvarUltimaImpressora(nomeImpressora);
  }
}
