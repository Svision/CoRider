import 'package:uuid/uuid.dart';

class VehicleModel {
  String id;
  int? year;
  String? make;
  String? model;
  String? color;
  String? licensePlate;
  int? availableSeats;

  VehicleModel({
    String? id,
    this.year = 1990,
    this.make = 'Unknown',
    this.model = 'Unknown',
    this.color = 'Unknown',
    this.licensePlate = 'Unknown',
    this.availableSeats = 4,
  }) : id = id ?? const Uuid().v4();

  String get fullName => '$make $model';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      licensePlate: json['licensePlate'],
      availableSeats: json['availableSeats'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'availableSeats': availableSeats,
    };
  }
}
