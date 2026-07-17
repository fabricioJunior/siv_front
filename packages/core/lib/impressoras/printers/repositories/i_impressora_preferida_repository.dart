abstract class IImpressoraPreferidaRepository {
  Future<String?> obterUltimaImpressora();
  Future<void> salvarUltimaImpressora(String nomeImpressora);
}
