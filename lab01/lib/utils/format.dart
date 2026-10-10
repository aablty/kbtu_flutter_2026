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
  final month = _months[dateTime.month - 1];
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day} $month, ${dateTime.hour}:$minute';
}
