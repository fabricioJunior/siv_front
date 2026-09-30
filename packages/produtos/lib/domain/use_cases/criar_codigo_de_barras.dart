class CriarCodigoDeBarras {
  // Contador de sequência, não aleatório: gerar vários códigos em lote rápido
  // (criar N combinações de uma vez) pode cair no mesmo milissegundo, e só 2
  // dígitos de sorte (100 combinações) colidia de verdade -- backend rejeita
  // código de barras duplicado com 400. Contador garante que duas chamadas
  // na mesma instância (mesmo lote) nunca repetem, mesmo no mesmo ms.
  int _sequencia = 0;

  Future<String> call() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final sequencia = (_sequencia++ % 1000).toString().padLeft(3, '0');
    final base12 =
        timestamp.substring(timestamp.length - 9).padLeft(9, '0') + sequencia;
    final digitoVerificador = _calcularDigitoVerificador(base12);

    return '$base12$digitoVerificador';
  }

  int _calcularDigitoVerificador(String base12) {
    var soma = 0;

    for (var i = 0; i < base12.length; i++) {
      final digito = int.parse(base12[i]);
      soma += (i % 2 == 0) ? digito : digito * 3;
    }

    return (10 - (soma % 10)) % 10;
  }
}
