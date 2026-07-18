import 'package:core/impressoras/printers/repositories/i_impressora_preferida_repository.dart';
import 'package:core/impressoras/printers/tipo_impressora.dart';

class SalvarImpressoraPreferida {
  final IImpressoraPreferidaRepository _repository;

  SalvarImpressoraPreferida({required IImpressoraPreferidaRepository repository})
      : _repository = repository;

  Future<void> call({required TipoImpressora tipo, required String nomeImpressora}) {
    return _repository.salvarUltimaImpressora(tipo, nomeImpressora);
  }
}
