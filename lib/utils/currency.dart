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

/// Short VND for tight spots (calendar cells), e.g. `₫4.8M`, `₫950k`, `₫800`.
String formatVndCompact(double? amount) {
  if (amount == null) return '—';
  final n = amount.abs();
  String trim(double v) =>
      v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  if (n >= 1e9) return '₫${trim(n / 1e9)}B';
  if (n >= 1e6) return '₫${trim(n / 1e6)}M';
  if (n >= 1e3) return '₫${(n / 1e3).round()}k';
  return '₫${n.round()}';
}
