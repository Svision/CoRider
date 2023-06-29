import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

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
