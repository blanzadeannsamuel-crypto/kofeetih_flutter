class Coffee {
  int? id;
  String? coffeeName;
  String? coffeeType;
  String? description;
  String? ingredients;
  double? minPrice;
  double? maxPrice;

  Coffee({this.id, this.coffeeName = '', this.coffeeType = '', this.description= '', this.ingredients= '', this.minPrice, this.maxPrice,});

  factory Coffee.fromJson(Map<String, dynamic> json) {
    // Safely parse ID
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

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'coffee_name': coffeeName,
      'coffee_type': coffeeType,
      'description': description,
      'ingredients': ingredients,
      'minimum_price': minPrice,
      'maximum_price': maxPrice,
    };
  }
}
