class Review {
  final String id;
  final String appointmentId;
  final String customerId;
  final String customerName;
  final String? customerAvatar;
  final String barberId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.appointmentId,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    required this.barberId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return Review(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String,
      customerId: json['customer_id'] as String,
      customerName: profile != null ? (profile['full_name'] as String? ?? 'Customer') : (json['customer_name'] as String? ?? 'Customer'),
      customerAvatar: profile != null ? profile['avatar_url'] as String? : json['customer_avatar'] as String?,
      barberId: json['barber_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'customer_id': customerId,
      'barber_id': barberId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
