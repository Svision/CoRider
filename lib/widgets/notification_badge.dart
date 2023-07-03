import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({Key? key, required this.totalNotifications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalNotifications == 0) {
      return const SizedBox.shrink();
    }
    String totalNotificationsString = totalNotifications <= 99 ? totalNotifications.toString() : '99+';
    return Container(
      width: 22.0 + 5 * (totalNotificationsString.length - 1),
      height: 22.0,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            totalNotificationsString,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }
}
