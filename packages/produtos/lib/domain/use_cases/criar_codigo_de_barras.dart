import 'dart:math';

class CriarCodigoDeBarras {
  final Random _random = Random();

  Future<String> call() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final base12 =
        timestamp.substring(timestamp.length - 10).padLeft(10, '0') +
        _random.nextInt(100).toString().padLeft(2, '0');
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
