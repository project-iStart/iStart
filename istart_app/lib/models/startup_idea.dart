// lib/models/startup_idea.dart

class StartupIdea {
  final String id;
  final String title;
  final String description;
  final String? problemStatement;
  final String? category;
  final String? stage;
  final String? pitchDeckUrl;
  final int communityScore;
  final bool fundingInterest;
  final Map<String, dynamic> founder;
  final List<dynamic> teamMembers;

  StartupIdea({
    required this.id,
    required this.title,
    required this.description,
    this.problemStatement,
    this.category,
    this.stage,
    this.pitchDeckUrl,
    required this.communityScore,
    required this.fundingInterest,
    required this.founder,
    required this.teamMembers,
  });

  factory StartupIdea.fromJson(Map<String, dynamic> json) => StartupIdea(
    id: json['_id'],
    title: json['title'],
    description: json['description'],
    problemStatement: json['problemStatement'],
    category: json['category'],
    stage: json['stage'],
    pitchDeckUrl: json['pitchDeckUrl'],
    communityScore: json['communityScore'] ?? 0,
    fundingInterest: json['fundingInterest'] ?? false,
    founder: json['founder'] ?? {},
    teamMembers: json['teamMembers'] ?? [],
  );
}