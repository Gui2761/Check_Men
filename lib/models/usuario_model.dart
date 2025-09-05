class Usuario {
  final int id;
  final String name;
  final String email;

  Usuario({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}