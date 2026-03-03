import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String formatShort() => DateFormat('MMM d, HH:mm').format(this);
  String formatDate() => DateFormat('MMM d, yyyy').format(this);
}
