class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String bio;

  // Founder
  final String companyName;
  final String startupStage;

  // Collaborator
  final List<String> skills;
  final String availability;

  // Investor
  final String investmentFocus;
  final String portfolioLink;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.bio = '',
    this.companyName = '',
    this.startupStage = '',
    this.skills = const [],
    this.availability = '',
    this.investmentFocus = '',
    this.portfolioLink = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      startupStage: json['startupStage']?.toString() ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      availability: json['availability']?.toString() ?? '',
      investmentFocus: json['investmentFocus']?.toString() ?? '',
      portfolioLink: json['portfolioLink']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'role': role,
    'bio': bio,
    'companyName': companyName,
    'startupStage': startupStage,
    'skills': skills,
    'availability': availability,
    'investmentFocus': investmentFocus,
    'portfolioLink': portfolioLink,
  };
}