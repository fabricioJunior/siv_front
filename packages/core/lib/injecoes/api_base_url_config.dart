class ApiBaseUrlConfig {
  String _urlBase = '';

  String get urlBase => _urlBase;

  void atualizar(String urlBase) {
    _urlBase = urlBase;
  }
}
