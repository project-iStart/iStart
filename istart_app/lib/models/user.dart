class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? bio;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.bio,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id'] ?? json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    bio: json['bio'],
    profileImage: json['profileImage'],
  );
}