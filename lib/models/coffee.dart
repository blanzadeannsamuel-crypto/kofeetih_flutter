class Coffee {
  int? id;
  String? coffeeName;
  String? coffeeType;
  String? description;
  String? ingredients;
  double? minPrice;
  double? maxPrice;
  bool? likedByUser;
  bool? favoritedByUser;
  int? likes;
  int? favorites;
  String? imageUrl;

  Coffee({
    this.id,
    this.coffeeName = '',
    this.coffeeType = '',
    this.description = '',
    this.ingredients = '',
    this.minPrice,
    this.maxPrice,
    this.likedByUser = false,
    this.favoritedByUser = false,
    this.likes = 0,
    this.favorites = 0,
    this.imageUrl,
  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Coffee(
      id: parseId(json['id']),
      coffeeName: json['coffee_name']?.toString() ?? '',
      coffeeType: json['coffee_type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ingredients: json['ingredients']?.toString() ?? '',
      minPrice: parseDouble(json['minimum_price']),
      maxPrice: parseDouble(json['maximum_price']),
      likedByUser: json['likedByUser'] ?? false,
      favoritedByUser: json['favoritedByUser'] ?? false,
      likes: json['likes'] is int ? json['likes'] : int.tryParse(json['likes']?.toString() ?? "0") ?? 0,
      favorites: json['favorites'] is int ? json['favorites'] : int.tryParse(json['favorites']?.toString() ?? "0") ?? 0,
      imageUrl: json['image_url']?.toString(),
    );
  }
}
