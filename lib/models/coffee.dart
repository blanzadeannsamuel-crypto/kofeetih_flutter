class Coffee {
  int? id;
  String? coffeeType;
  String? description;

  Coffee({this.id, this.coffeeType = '', this.description= ''});

  factory Coffee.fromJson(Map<String, dynamic> json) {
    // Safely parse ID
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Coffee(
      id: parseId(json['id']),
      coffeeType: json['coffee_type']?.toString() ?? '',
      description: json['description']?.toString()?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'coffee_type': coffeeType,
      'description': description,
    };
  }
}
