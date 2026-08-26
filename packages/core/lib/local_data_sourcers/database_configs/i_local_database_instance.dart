abstract interface class ILocalDatabaseInstance {
  Future<void> closeAllInstances();

  /// Fecha todas as instâncias abertas e apaga os dados locais do disco.
  /// Usado no logout: dados locais não têm coluna de licenciadoId pra
  /// filtrar na leitura (diferente de empresaId, que os modelos já têm),
  /// então trocar de licenciado sem isso reabre o mesmo banco com dados do
  /// licenciado anterior ainda dentro.
  Future<void> apagarTodosOsDados();
}
