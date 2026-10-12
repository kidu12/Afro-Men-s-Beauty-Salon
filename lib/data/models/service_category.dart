class ServiceCategory {
  final String id;
  final String? branchId;
  final String name;
  final String? description;
  final String? iconName;
  final int displayOrder;
  final bool isActive;

  const ServiceCategory({
    required this.id,
    this.branchId,
    required this.name,
    this.description,
    this.iconName,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      branchId: json['branch_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}
