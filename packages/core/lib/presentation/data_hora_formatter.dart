String formatarData(DateTime? dt) {
  if (dt == null) return '-';
  final local = dt.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String formatarDataHora(DateTime? dt) {
  if (dt == null) return '-';
  final local = dt.toLocal();
  return '${formatarData(local)} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String formatarHora(DateTime? dt) {
  if (dt == null) return '-';
  final local = dt.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
