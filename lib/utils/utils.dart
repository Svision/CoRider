import 'package:flutter/material.dart';

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
        return Colors
            .transparent; // Return a default color if the value doesn't match any case
    }
  }
}
