class VehicleModel {
  int year;
  String make;
  String model;
  String color;
  String licensePlate;
  int seats;

  VehicleModel({
    this.year = 2018,
    this.make = 'Audi',
    this.model = 'A4',
    this.color = 'grey',
    this.licensePlate = 'ABC123',
    this.seats = 5,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      make: json['make'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      licensePlate: json['licensePlate'],
      seats: json['seats'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'seats': seats,
    };
  }
}
