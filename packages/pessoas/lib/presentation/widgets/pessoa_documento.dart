String? mascararDocumento(String? documento) {
  final d = (documento ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  if (d.length == 11) return '${d.substring(0, 3)}.***.***-${d.substring(9)}';
  if (d.length == 14) {
    return '${d.substring(0, 2)}.***.***/****-${d.substring(12)}';
  }
  return null;
}
