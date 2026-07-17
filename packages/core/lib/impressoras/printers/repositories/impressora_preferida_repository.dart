import 'package:core/impressoras/printers/impressora_preferida_local_data_source.dart';
import 'package:core/impressoras/printers/repositories/i_impressora_preferida_repository.dart';

class ImpressoraPreferidaRepository implements IImpressoraPreferidaRepository {
  final IImpressoraPreferidaLocalDataSource localDataSource;

  ImpressoraPreferidaRepository({required this.localDataSource});

  @override
  Future<String?> obterUltimaImpressora() {
    return localDataSource.obterUltimaImpressora();
  }

  @override
  Future<void> salvarUltimaImpressora(String nomeImpressora) {
    return localDataSource.salvarUltimaImpressora(nomeImpressora);
  }
}
