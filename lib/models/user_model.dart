class AppUser {
  final int? id;
  final String username;
  final String password;
  final String? photoBase64;

  AppUser({
    this.id,
    required this.username,
    required this.password,
    this.photoBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'photoBase64': photoBase64,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      photoBase64: map['photoBase64'],
    );
  }

  AppUser copyWith({
    int? id,
    String? username,
    String? password,
    String? photoBase64,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }
}
