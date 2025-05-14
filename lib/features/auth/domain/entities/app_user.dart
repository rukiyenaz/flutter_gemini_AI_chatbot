class AppUser{
  final String id;
  final String name;
  final String email;


  AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  //convert appuser-> json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  //convert json -> appuser
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}