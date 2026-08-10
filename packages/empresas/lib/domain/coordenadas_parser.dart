final _dmsRegex = RegExp(
  r'''(\d+(?:[.,]\d+)?)[°º]\s*(\d+(?:[.,]\d+)?)['′’]\s*(\d+(?:[.,]\d+)?)["″”]\s*([NSEWnsew])\s+'''
  r'''(\d+(?:[.,]\d+)?)[°º]\s*(\d+(?:[.,]\d+)?)['′’]\s*(\d+(?:[.,]\d+)?)["″”]\s*([NSEWnsew])''',
);

final _decimalRegex = RegExp(
  r'^\s*(-?\d+(?:\.\d+)?)\s*[,\s]\s*(-?\d+(?:\.\d+)?)\s*$',
);

/// Converte string de coordenadas copiada do Google Maps (DMS, ex:
/// `2°54'49.7"S 41°45'15.6"W`) ou decimal (`-2.9138, -41.7543`) em
/// `(latitude, longitude)`. Retorna null se não conseguir interpretar.
(double, double)? parseCoordenadas(String texto) {
  final dms = _dmsRegex.firstMatch(texto);
  if (dms != null) {
    final lat = _dmsParaDecimal(dms.group(1)!, dms.group(2)!, dms.group(3)!, dms.group(4)!);
    final lng = _dmsParaDecimal(dms.group(5)!, dms.group(6)!, dms.group(7)!, dms.group(8)!);
    return (lat, lng);
  }

  final decimal = _decimalRegex.firstMatch(texto);
  if (decimal != null) {
    final lat = double.parse(decimal.group(1)!);
    final lng = double.parse(decimal.group(2)!);
    return (lat, lng);
  }

  return null;
}

double _dmsParaDecimal(
  String graus,
  String minutos,
  String segundos,
  String hemisferio,
) {
  final decimal = double.parse(graus.replaceAll(',', '.')) +
      double.parse(minutos.replaceAll(',', '.')) / 60 +
      double.parse(segundos.replaceAll(',', '.')) / 3600;
  final negativo = hemisferio.toUpperCase() == 'S' || hemisferio.toUpperCase() == 'W';
  return negativo ? -decimal : decimal;
}
