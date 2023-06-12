class UserModel {
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImage: json['profileImage'],
      createdAt: json['createdAt'].toDate(),
    );
  }

  String get fullName => '$firstName $lastName';
}
