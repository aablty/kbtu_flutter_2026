const _months = [
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

String formatDateTime(DateTime dateTime) {
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${formatDate(dateTime)}, ${dateTime.hour}:$minute';
}

String formatDate(DateTime dateTime) {
  final month = _months[dateTime.month - 1];
  return '${dateTime.day} $month';
}
