class VehicleModel {
  final String make;
  final String model;
  final String? year;
  final String? color;
  final String? licensePlate;
  final int? seats;

  VehicleModel({
    required this.make,
    required this.model,
    this.year,
    this.color,
    this.licensePlate,
    this.seats,
  });
}
