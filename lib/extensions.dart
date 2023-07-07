import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';

extension ChatListExntension on List<types.Room> {
  void sortRooms() {
    if (isEmpty) {
      return;
    }
    // order chat rooms by last message timestamp
    sort((a, b) {
      // notification room should be at the top
      if (a.type == types.RoomType.channel) {
        return -1;
      } else if (b.type == types.RoomType.channel) {
        return 1;
      }

      // if no messages, set to min value
      final minTimestamp = DateTime.fromMillisecondsSinceEpoch(0).microsecondsSinceEpoch;
      final aTimestamp = a.lastMessages?.first.createdAt ?? minTimestamp;
      final bTimestamp = b.lastMessages?.first.createdAt ?? minTimestamp;
      return bTimestamp.compareTo(aTimestamp);
    });
  }

  List<types.Room> sortedRooms() {
    final sortedRooms = this;
    sortedRooms.sortRooms();
    return sortedRooms;
  }
}

extension DateTimeExtension on DateTime {
  String getFormattedString() {
    final currentDate = DateTime.now();
    final timeFormatter = DateFormat('hh:mm a');
    final yearFormatter = DateFormat('yyyy-MM-dd');

    if (isSameDay(currentDate)) {
      return timeFormatter.format(this);
    } else if (isYesterday()) {
      return 'Yesterday ${timeFormatter.format(this)}';
    } else if (isSameYear(currentDate)) {
      return yearFormatter.format(this).substring(5);
    } else {
      return yearFormatter.format(this);
    }
  }

  bool isSameDay(DateTime date2) {
    return year == date2.year && month == date2.month && day == date2.day;
  }

  bool isYesterday() {
    final currentDate = DateTime.now();
    final yesterday = currentDate.subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  bool isSameYear(DateTime date2) {
    return year == date2.year;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}
