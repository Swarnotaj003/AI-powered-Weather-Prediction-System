// Fetch date string 'DD Month YYYY' from DateTime
String getDateString(DateTime dateTime) {
  int day = dateTime.day;
  int month = dateTime.month;
  int year = dateTime.year;
  List<String> months = [
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
  String date = "${day < 10 ? '0$day' : day} ${months[month - 1]} $year";
  return date;
}

// Get weekday from DateTime
String getDayString(DateTime dateTime) {
  DateTime currTime = DateTime.now();
  if (currTime.month == dateTime.month && currTime.year == dateTime.year) {
    if (currTime.day == dateTime.day) {
      return "Today";
    } else if (currTime.day + 1 == dateTime.day) {
      return "Tommorrow";
    }
  }
  int weekDay = dateTime.weekday;
  List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return weekDays[weekDay - 1];
}

// Fetch time string 'HH:MM' from DateTime
String getTimeString(DateTime dateTime) {
  int hour = dateTime.hour;
  int minute = dateTime.minute;
  String time = '${hour < 10 ? '0$hour' : hour}:${minute < 10 ? '0$minute' : minute}';
  return time;
}