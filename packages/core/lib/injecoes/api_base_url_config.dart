class ApiBaseUrlConfig {
  String _urlBase = 'https://apollo-api-stg.coralcloud.app';

  String get urlBase => _urlBase;

  void atualizar(String urlBase) {
    _urlBase = urlBase;
  }
}
