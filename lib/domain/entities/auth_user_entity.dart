class AuthUserEntity {
  const AuthUserEntity({
    required this.id,
    required this.username,
    required this.role,
  });

  final int id;
  final String username;
  final String role;

  factory AuthUserEntity.fromJson(Map<String, dynamic> j) {
    return AuthUserEntity(
      id: (j['id'] as num).toInt(),
      username: j['username'] as String? ?? '',
      role: j['role'] as String? ?? 'user',
    );
  }
}
