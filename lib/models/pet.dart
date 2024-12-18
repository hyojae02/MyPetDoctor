class Pet {
  String id;
  String name;
  int age;
  String breed;
  String gender;
  bool isNeutered;
  double weight;
  String? imageUrl;

  Pet({
    required this.id,
    required this.name,
    required this.age,
    required this.breed,
    required this.gender,
    required this.isNeutered,
    required this.weight,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'breed': breed,
      'gender': gender,
      'isNeutered': isNeutered ? 1 : 0,
      'weight': weight,
      'imageUrl': imageUrl ?? '',  // Convert null to empty string for SQLite
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      breed: map['breed'] as String,
      gender: map['gender'] as String,
      isNeutered: (map['isNeutered'] as int) == 1,
      weight: (map['weight'] as num).toDouble(),
      imageUrl: map['imageUrl'] != '' ? map['imageUrl'] as String? : null,  // Convert empty string back to null
    );
  }

  // Add copy method for easy cloning/updating
  Pet copyWith({
    String? id,
    String? name,
    int? age,
    String? breed,
    String? gender,
    bool? isNeutered,
    double? weight,
    String? imageUrl,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      isNeutered: isNeutered ?? this.isNeutered,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}