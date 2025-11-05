import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtils {
  static String formatAppointmentDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(date.year, date.month, date.day);
    
    if (appointmentDay == today) {
      return 'Today';
    } else if (appointmentDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  static String formatTime(String time) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final dateTime = timeFormat.parse(time);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return time;
    }
  }

  static List<String> generateTimeSlots() {
    List<String> slots = [];
    for (int hour = 9; hour <= 17; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final time = TimeOfDay(hour: hour, minute: minute);
        slots.add(_formatTimeOfDay(time));
      }
    }
    return slots;
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}