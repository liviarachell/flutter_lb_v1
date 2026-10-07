
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

final ValueNotifier<AppUser> currentUser = ValueNotifier(
  const AppUser(username: 'Leitor', email: ''),
);

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> register({required String username, required String email, required String password});
  Future<AppUser> updateProfile({required String fullName, required String email, String? password});
}

class LocalAuthRepository implements AuthRepository {
  static const _emailKey = 'account_email';
  static const _passwordKey = 'account_password';
  static const _usernameKey = 'account_username';
  static const _fullNameKey = 'account_full_name';

  @override
  Future<AppUser> login({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    final savedPassword = prefs.getString(_passwordKey);

    if (savedEmail == null || savedPassword == null) {
      throw Exception('Nenhuma conta cadastrada neste dispositivo.');
    }

    if (email.trim().toLowerCase() != savedEmail.toLowerCase() || password != savedPassword) {
      throw Exception('Email ou senha incorretos.');
    }

    final user = AppUser(
      username: prefs.getString(_usernameKey) ?? 'Leitor',
      email: savedEmail,
      fullName: prefs.getString(_fullNameKey),
    );
    currentUser.value = user;
    return user;
  }

  @override
  Future<AppUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_usernameKey, username.trim());
    await prefs.setString(_emailKey, email.trim());
    await prefs.setString(_passwordKey, password);

    final user = AppUser(username: username.trim(), email: email.trim());
    currentUser.value = user;
    return user;
  }

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String email,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_emailKey, email.trim());
    await prefs.setString(_fullNameKey, fullName.trim());

    // A nova senha é persistida imediatamente quando fornecida.
    if (password != null && password.isNotEmpty) {
      await prefs.setString(_passwordKey, password);
    }

    final user = currentUser.value.copyWith(
      fullName: fullName.trim(),
      email: email.trim(),
    );

    currentUser.value = user;
    return user;
  }
}

final AuthRepository authRepository = LocalAuthRepository();
