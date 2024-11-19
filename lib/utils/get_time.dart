import 'package:intl/intl.dart';

/// Global function to get today's date formatted as "Today Feb 14, 2024"
String getFormattedDate() {
  DateTime now = DateTime.now();

  // Format the date as "Today MMM dd, yyyy"
  String formattedDate = DateFormat('MMM dd, yyyy').format(now);

  return formattedDate;
}

String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return 'Good \nMorning';
  } else if (hour < 17) {
    return 'Good \nAfternoon';
  } else if (hour < 21) {
    return 'Good \nEvening';
  } else {
    return 'Good \nNight';
  }
}