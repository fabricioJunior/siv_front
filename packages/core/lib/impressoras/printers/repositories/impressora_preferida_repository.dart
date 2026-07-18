import 'package:core/impressoras/printers/impressora_preferida_local_data_source.dart';
import 'package:core/impressoras/printers/repositories/i_impressora_preferida_repository.dart';
import 'package:core/impressoras/printers/tipo_impressora.dart';

class ImpressoraPreferidaRepository implements IImpressoraPreferidaRepository {
  final IImpressoraPreferidaLocalDataSource localDataSource;

  ImpressoraPreferidaRepository({required this.localDataSource});

  @override
  Future<String?> obterUltimaImpressora(TipoImpressora tipo) {
    return localDataSource.obterUltimaImpressora(tipo);
  }

  @override
  Future<void> salvarUltimaImpressora(TipoImpressora tipo, String nomeImpressora) {
    return localDataSource.salvarUltimaImpressora(tipo, nomeImpressora);
  }
}
