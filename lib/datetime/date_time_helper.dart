// convert DateTime object to a string yyyymmdd
String convertDateTimeToString(DateTime dateTime) {
  //year in format -> yyyy
  String year = dateTime.year.toString();

  //month in the format -> mm
  String month = dateTime.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

  //day in the format -> dd
  String day = dateTime.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  // final format --> yyyymmdd
  String yyyymmdd = year + month + day;
  return yyyymmdd;
}
