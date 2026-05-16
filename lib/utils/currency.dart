String formatVnd(double? amount) {
  if (amount == null) return '—';
  return '₫${formatInt(amount)}';
}

/// Thousands-grouped absolute integer (no currency symbol), e.g. `45,200`.
String formatInt(num value) {
  final whole = value.round().abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }
  return buf.toString();
}
