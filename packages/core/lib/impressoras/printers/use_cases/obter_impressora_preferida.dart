import 'package:core/impressoras/printers/repositories/i_impressora_preferida_repository.dart';
import 'package:core/impressoras/printers/tipo_impressora.dart';

class ObterImpressoraPreferida {
  final IImpressoraPreferidaRepository _repository;

  ObterImpressoraPreferida({required IImpressoraPreferidaRepository repository})
      : _repository = repository;

  Future<String?> call({required TipoImpressora tipo}) {
    return _repository.obterUltimaImpressora(tipo);
  }
}
