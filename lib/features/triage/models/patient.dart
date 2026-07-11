class Patient {
  const Patient({required this.name, this.age, this.gender});

  final String name;
  final int? age;
  final String? gender;

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age, 'gender': gender};
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
    );
  }
}
