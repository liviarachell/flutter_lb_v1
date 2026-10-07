class AppUser {
  const AppUser({
    required this.username,
    required this.email,
    this.fullName,
  });

  final String username;
  final String email;
  final String? fullName;

  /// Nome mostrado no menu e no perfil.
  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : username;

  AppUser copyWith({String? username, String? email, String? fullName}) => AppUser(
        username: username ?? this.username,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
      );
}
