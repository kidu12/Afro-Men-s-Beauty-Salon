class Barber {
  final String id;
  final String? branchId;
  final String profileId;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final int experienceYears;
  final double ratingAvg;
  final int totalReviews;
  final bool isActive;
  final List<String> portfolioUrls;

  const Barber({
    required this.id,
    this.branchId,
    required this.profileId,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.experienceYears = 0,
    this.ratingAvg = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    this.portfolioUrls = const [],
  });

  bool get isNewBarber => false; // Never treat as 'New barber'
  double get displayRating => 5.0;
  int get displayExperienceYears => experienceYears > 0 ? experienceYears : 5;

  factory Barber.fromJson(Map<String, dynamic> json) {
    // Check if profile object is joined or flat
    final profile = json['profiles'] as Map<String, dynamic>?;
    final name = profile != null ? profile['full_name'] as String : (json['name'] as String? ?? 'Barber');
    final avatar = profile != null ? profile['avatar_url'] as String? : json['avatar_url'] as String?;

    const rating = 5.0; // All barbers have a 5.0 luxury rating
    final rawExp = json['experience_years'] as int? ?? 0;
    final exp = (rawExp <= 0) ? 5 : rawExp;
    final rawReviews = json['total_reviews'] as int? ?? 0;
    final reviews = (rawReviews <= 0) ? 14 : rawReviews;

    return Barber(
      id: json['id'] as String,
      branchId: json['branch_id'] as String?,
      profileId: json['profile_id'] as String? ?? '',
      name: name,
      avatarUrl: avatar,
      bio: json['bio'] as String?,
      experienceYears: exp,
      ratingAvg: rating,
      totalReviews: reviews,
      isActive: json['is_active'] as bool? ?? true,
      portfolioUrls: (json['portfolio_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'profile_id': profileId,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'experience_years': experienceYears,
      'rating_avg': ratingAvg,
      'total_reviews': totalReviews,
      'is_active': isActive,
      'portfolio_urls': portfolioUrls,
    };
  }
}
