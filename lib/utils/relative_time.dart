/// Client-side relative-time formatter. Mirrors the server's `relativeLabel`
/// in `notifications.service.ts`, but recomputed in the UI so a label like
/// "Just now" can age into "1m ago" without a server round-trip.
///
/// Pass an ISO 8601 timestamp (e.g. `2026-05-26T10:15:00.000Z`). Returns "" if
/// the input is null, empty, or unparseable — callers can fall back to the
/// server-provided `timeLabel` in that case.
String relativeTimeLabel(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final then = DateTime.tryParse(iso);
  if (then == null) return '';

  final diff = DateTime.now().difference(then);
  final minutes = diff.inMinutes;
  if (minutes < 1) return 'Just now';
  if (minutes < 60) return '${minutes}m ago';
  final hours = diff.inHours;
  if (hours < 24) return '${hours}h ago';
  final days = diff.inDays;
  if (days == 1) return 'Yesterday';
  if (days < 7) return '${days}d ago';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[then.month - 1]} ${then.day}';
}
