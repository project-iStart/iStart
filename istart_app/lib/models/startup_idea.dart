// lib/models/startup_idea.dart

class StartupIdea {
  final String id;
  final String title;
  final String description;
  final String? problemStatement;
  final String? category;
  final String? stage;
  final String? pitchDeckUrl;
  final Map<String, dynamic> founder;
  final List<dynamic> teamMembers;
  final int communityScore;
  final int voteCount;
  final bool isVoted;
  final bool isBookmarked;
  final bool isFollowing;
  final bool fundingInterest;
  final bool hasFundingInterest;
  final int fundingInterestCount;
  final DateTime? createdAt;

  StartupIdea({
    required this.id,
    required this.title,
    required this.description,
    this.problemStatement,
    this.category,
    this.stage,
    this.pitchDeckUrl,
    required this.founder,
    this.teamMembers = const [],
    this.communityScore = 0,
    this.voteCount = 0,
    this.isVoted = false,
    this.isBookmarked = false,
    this.isFollowing = false,
    this.fundingInterest = false,
    this.hasFundingInterest = false,
    this.fundingInterestCount = 0,
    this.createdAt,
  });

  factory StartupIdea.fromJson(Map<String, dynamic> json) {
    return StartupIdea(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      problemStatement: json['problemStatement'],
      category: json['category'],
      stage: json['stage'],
      pitchDeckUrl: json['pitchDeckUrl'],
      founder: json['founder'] is Map ? json['founder'] : {'name': 'Unknown'},
      teamMembers: json['teamMembers'] is List
          ? List<dynamic>.from(json['teamMembers'] as List)
          : const [],
      communityScore: json['communityScore'] ?? 0,
      voteCount: json['voteCount'] ?? 0,
      isVoted: json['isVoted'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
      fundingInterest: json['fundingInterest'] ?? false,
      hasFundingInterest: json['hasFundingInterest'] ?? false,
      fundingInterestCount: json['fundingInterestCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  // Helper method
  List<String> get teamMemberIds {
    return teamMembers.map((m) {
      if (m is Map) {
        return (m['_id'] ?? m['id'] ?? '').toString();
      }
      return m.toString();
    }).where((id) => id.isNotEmpty).toList();
  }

  StartupIdea copyWith({
    String? id,
    String? title,
    String? description,
    String? problemStatement,
    String? category,
    String? stage,
    String? pitchDeckUrl,
    Map<String, dynamic>? founder,
    List<dynamic>? teamMembers,
    int? communityScore,
    int? voteCount,
    bool? isVoted,
    bool? isBookmarked,
    bool? isFollowing,
    bool? fundingInterest,
    bool? hasFundingInterest,
    int? fundingInterestCount,
    DateTime? createdAt,
  }) {
    return StartupIdea(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      problemStatement: problemStatement ?? this.problemStatement,
      category: category ?? this.category,
      stage: stage ?? this.stage,
      pitchDeckUrl: pitchDeckUrl ?? this.pitchDeckUrl,
      founder: founder ?? this.founder,
      teamMembers: teamMembers ?? this.teamMembers,
      communityScore: communityScore ?? this.communityScore,
      voteCount: voteCount ?? this.voteCount,
      isVoted: isVoted ?? this.isVoted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFollowing: isFollowing ?? this.isFollowing,
      fundingInterest: fundingInterest ?? this.fundingInterest,
      hasFundingInterest: hasFundingInterest ?? this.hasFundingInterest,
      fundingInterestCount: fundingInterestCount ?? this.fundingInterestCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}