import 'package:corider/models/types/requested_offer_status.dart';
import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class Utils {
  static Color getColorFromValue(String value) {
    switch (value) {
      case 'Black':
        return Colors.black;
      case 'White':
        return Colors.white;
      case 'Gray':
        return Colors.grey;
      case 'Red':
        return Colors.red;
      case 'Blue':
        return Colors.blue;
      case 'Green':
        return Colors.green;
      case 'Brown':
        return Colors.brown;
      case 'Yellow':
        return Colors.yellow;
      case 'Orange':
        return Colors.orange;
      case 'Purple':
        return Colors.purple;
      case 'Pink':
        return Colors.pink;
      default:
        return Colors.transparent; // Return a default color if the value doesn't match any case
    }
  }

  static String getShortLocationName(String locationName) {
    final splitName = locationName.split(',');
    return splitName[0];
  }

  static Color getUserAvatarNameColor(String userId) {
    const colors = [
      Color(0xffff6767),
      Color(0xff66e0da),
      Color(0xfff5a2d9),
      Color(0xfff0c722),
      Color(0xff6a85e5),
      Color(0xfffd9a6f),
      Color(0xff92db6e),
      Color(0xff73b8e5),
      Color(0xfffd7590),
      Color(0xffc78ae5),
    ];
    final index = userId.hashCode % colors.length;
    return colors[index];
  }

  static String getRoomIdByTwoUser(String user1, String user2) {
    final users = [user1, user2];
    users.sort();
    return users.join('_');
  }

  static types.Room displayedDirectRoomInfo(types.Room room, UserModel otherUser) {
    if (room.type != types.RoomType.direct) {
      return room;
    }
    return room.copyWith(
      imageUrl: otherUser.profileImage,
      name: otherUser.fullName,
      users: room.users,
    );
  }

  static Icon requestStatusToIcon(RequestedOfferStatus status) {
    switch (status) {
      case RequestedOfferStatus.INVALID:
        return Icon(Icons.error, color: requestStatusToColor(status));
      case RequestedOfferStatus.PENDING:
        return Icon(Icons.pending, color: requestStatusToColor(status));
      case RequestedOfferStatus.ACCEPTED:
        return Icon(Icons.check, color: requestStatusToColor(status));
      case RequestedOfferStatus.REJECTED:
        return Icon(Icons.close, color: requestStatusToColor(status));
      default:
        return Icon(Icons.pending, color: requestStatusToColor(status));
    }
  }

  static Color requestStatusToColor(RequestedOfferStatus status) {
    switch (status) {
      case RequestedOfferStatus.INVALID:
        return Colors.red;
      case RequestedOfferStatus.PENDING:
        return Colors.orange;
      case RequestedOfferStatus.ACCEPTED:
        return Colors.green;
      case RequestedOfferStatus.REJECTED:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  static String getUserChannelId(String userId) {
    return '$userId-channel';
  }

  static types.TextMessage createNotificationTextMessage(String text) {
    return types.TextMessage(
      id: const Uuid().v4(),
      author: const types.User(id: 'notifications'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: text,
    );
  }

  static String getDistanceByTwoLocation(LatLng location1, LatLng location2) {
    double distance =
        Geolocator.distanceBetween(location1.latitude, location1.longitude, location2.latitude, location2.longitude);
    return '${(distance / 1000).toStringAsFixed(2)} km';
  }
}
