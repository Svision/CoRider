import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  int? year;
  String? make;
  String? model;
  String? color;
  String? licensePlate;
  int? availableSeats;

  VehicleModel({
    this.year = 1990,
    this.make = 'Unknown',
    this.model = 'Unknown',
    this.color = 'Unknown',
    this.licensePlate = 'Unknown',
    this.availableSeats = 4,
  });

  String get fullName => '$make $model';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
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
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'availableSeats': availableSeats,
    };
  }

  Future<String?> saveToFirestore(String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(email).update({
        'vehicle': toJson(),
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }
}
