import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;
  final bool forTotal;

  const NotificationBadge({Key? key, required this.totalNotifications, this.forTotal = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalNotifications == 0) {
      return const SizedBox.shrink();
    }
    String totalNotificationsString = totalNotifications <= 99 ? totalNotifications.toString() : '99+';
    return Container(
      width: forTotal
          ? 15.0 + 2 * (totalNotificationsString.length - 1)
          : 22.0 + 5 * (totalNotificationsString.length - 1),
      height: forTotal ? 15 : 22.0,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Padding(
          padding: forTotal ? const EdgeInsets.all(2.0) : const EdgeInsets.all(4.0),
          child: Text(
            totalNotificationsString,
            style: TextStyle(color: Colors.white, fontSize: forTotal ? 7 : 10),
          ),
        ),
      ),
    );
  }
}
