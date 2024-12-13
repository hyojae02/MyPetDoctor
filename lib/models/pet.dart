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
      'isNeutered': isNeutered ? 1 : 0,  // SQLite는 boolean을 1/0으로 저장
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
      isNeutered: map['isNeutered'] == 1,  // SQLite의 1/0을 boolean으로 변환
      weight: map['weight'].toDouble(),  // SQLite에서 숫자를 가져올 때 필요
      imageUrl: map['imageUrl'],
      allergies: map['allergies'],
      specialNotes: map['specialNotes'],
    );
  }
}