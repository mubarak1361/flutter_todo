import 'package:flutter/material.dart';

class DateUtil {
  static String getFormattedTime(String dateTime) {
    TimeOfDay timeOfDay = new TimeOfDay.fromDateTime(DateTime.parse(dateTime));
    return '${_addDateTimePrefix(timeOfDay.hourOfPeriod.toString())} : ${_addDateTimePrefix(timeOfDay.minute.toString())} ${getTimePeriod(timeOfDay)}';
  }

  static String getTimePeriod(TimeOfDay timeOfDay) {
    return timeOfDay.periodOffset == 0 ? 'AM' : 'PM';
  }

  static String _addDateTimePrefix(String dateTime) {
    return dateTime.length > 1 ? dateTime : '0${dateTime}';
  }

  static String getFormattedDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${_addDateTimePrefix(dateTime.day.toString())}/${_addDateTimePrefix(dateTime.month.toString())}/${_addDateTimePrefix(dateTime.year.toString())}';
  }
}
