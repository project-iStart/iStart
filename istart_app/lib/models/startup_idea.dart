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
  final bool isBookmarked;
  final bool isVoted;
  final int voteCount;
  final bool hasFundingInterest;
  final int fundingInterestCount;
  final bool isFollowing;

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
    this.isBookmarked = false,
    this.isVoted = false,
    this.voteCount = 0,
    this.hasFundingInterest = false,
    this.fundingInterestCount = 0,
    this.isFollowing = false,
  });

  factory StartupIdea.fromJson(Map<String, dynamic> json) => StartupIdea(
    id: json['_id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    problemStatement: json['problemStatement'],
    category: json['category'],
    stage: json['stage'],
    pitchDeckUrl: json['pitchDeckUrl'],
    communityScore: json['communityScore'] ?? 0,
    fundingInterest: json['fundingInterest'] ?? false,
    founder: json['founder'] ?? {},
    teamMembers: json['teamMembers'] ?? [],
    isBookmarked: json['isBookmarked'] ?? false,
    isVoted: json['isVoted'] ?? false,
    voteCount: json['voteCount'] ?? 0,
    hasFundingInterest: json['hasFundingInterest'] ?? false,
    fundingInterestCount: json['fundingInterestCount'] ?? 0,
    isFollowing: json['isFollowing'] ?? false,
  );

  StartupIdea copyWith({
    bool? isBookmarked,
    bool? isVoted,
    int? voteCount,
    bool? hasFundingInterest,
    int? fundingInterestCount,
    bool? isFollowing,
  }) => StartupIdea(
    id: id,
    title: title,
    description: description,
    problemStatement: problemStatement,
    category: category,
    stage: stage,
    pitchDeckUrl: pitchDeckUrl,
    communityScore: communityScore,
    fundingInterest: fundingInterest,
    founder: founder,
    teamMembers: teamMembers,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    isVoted: isVoted ?? this.isVoted,
    voteCount: voteCount ?? this.voteCount,
    hasFundingInterest: hasFundingInterest ?? this.hasFundingInterest,
    fundingInterestCount: fundingInterestCount ?? this.fundingInterestCount,
    isFollowing: isFollowing ?? this.isFollowing,
  );
}
