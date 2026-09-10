enum CategoryType { expense, income }

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    this.isDefault = false,
    this.isActive = true,
  });

  final String id;
  final String name;
  final CategoryType type;
  final int iconCodePoint;

  final bool isDefault;
  final bool isActive;

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    int? iconCodePoint,
    bool? isDefault,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
    );
  }
}
