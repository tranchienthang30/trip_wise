String formatVnd(double? amount) {
  if (amount == null) return '—';
  final whole = amount.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }
  return '₫$buf';
}
