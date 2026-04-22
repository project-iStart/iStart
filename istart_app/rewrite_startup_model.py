from pathlib import Path

path = Path('lib/models/startup_idea.dart')
content = '''// lib/models/startup_idea.dart

class StartupIdea {
  final String id;
  final String founderId;
  final String title;
  final String description;
  final String? problemStatement;
  final String? category;
  final String? stage;
  final String? pitchDeckUrl;
  final List<String> bookmarkedBy;
  final int communityScore;
  final bool fundingInterest;
  final List<String> teamMembers;
  final DateTime createdAt;
  final DateTime updatedAt;

  StartupIdea({
    required this.id,
    required this.founderId,
    required this.title,
    required this.description,
    this.problemStatement,
    this.category,
    this.stage,
    this.pitchDeckUrl,
    this.bookmarkedBy = const [],
    this.communityScore = 0,
    this.fundingInterest = false,
    this.teamMembers = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory StartupIdea.fromJson(Map<String, dynamic> json) {
    final bookmarkedBy = (json['bookmarkedBy'] as List<dynamic>?)
            ?.map((item) => item?.toString() ?? '')
            .where((item) => item.isNotEmpty)
            .toList() ??
        [];

    final teamMembers = (json['teamMembers'] as List<dynamic>?)
            ?.map((item) => item?.toString() ?? '')
            .where((item) => item.isNotEmpty)
            .toList() ??
        [];

    return StartupIdea(
      id: json['_id']?.toString() ?? '',
      founderId: json['founder']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      problemStatement: json['problemStatement']?.toString(),
      category: json['category']?.toString(),
      stage: json['stage']?.toString(),
      pitchDeckUrl: json['pitchDeckUrl']?.toString(),
      bookmarkedBy: bookmarkedBy,
      communityScore: int.tryParse(json['communityScore']?.toString() ?? '') ?? 0,
      fundingInterest: json['fundingInterest'] == True or
          str(json['fundingInterest']).lower() == 'true',
      teamMembers: teamMembers,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') or DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') or DateTime.now(),
    );
  }
}
'''
path.write_text(content, encoding='utf-8')
print(f'Wrote {path.resolve()}')
