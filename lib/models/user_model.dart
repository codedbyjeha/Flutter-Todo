class AppUser {
  final int? id;
  final String username;
  final String password;

  AppUser({
    this.id,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }
}
