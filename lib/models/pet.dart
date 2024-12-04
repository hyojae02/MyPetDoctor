class Pet {
  String id;
  String name;
  int age;
  String breed;
  String gender;
  bool isNeutered;
  double weight;
  String? imageUrl;
  String? allergies;
  String? specialNotes;

  Pet({
    required this.id,
    required this.name,
    required this.age,
    required this.breed,
    required this.gender,
    required this.isNeutered,
    required this.weight,
    this.imageUrl,
    this.allergies,
    this.specialNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'breed': breed,
      'gender': gender,
      'isNeutered': isNeutered,
      'weight': weight,
      'imageUrl': imageUrl,
      'allergies': allergies,
      'specialNotes': specialNotes,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      breed: map['breed'],
      gender: map['gender'],
      isNeutered: map['isNeutered'],
      weight: map['weight'],
      imageUrl: map['imageUrl'],
      allergies: map['allergies'],
      specialNotes: map['specialNotes'],
    );
  }
}