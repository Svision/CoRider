class UserModel {
  final String email;
  final String firstName;
  final String lastName;
  String? profileImage;
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

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }

  setProfileImage(String? imageUrl) {
    profileImage = imageUrl;
  }

  String get fullName => '$firstName $lastName';
}
