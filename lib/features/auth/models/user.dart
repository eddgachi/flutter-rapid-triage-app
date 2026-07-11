class User {
  final String id;
  final String name;

  const User({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(id: json['id'] as String, name: json['name'] as String);
  }
}
