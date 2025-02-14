import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latihankasirapp/pages/welcomepages.dart';

final supabase = Supabase.instance.client;

Future<String?> auth(String email, String password) async {
  try {
    final response = await supabase
        .from('users')
        .select('id, password')
        .eq('email', email)
        .maybeSingle();

    if (response == null) {
      return "Email tidak terdaftar";
    }

    final hashedPassword = response['password'];
    final userId = response['id'].toString();

    if (!BCrypt.checkpw(password, hashedPassword)) {
      return "Password salah";
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);

    return null; // Login berhasil
  } catch (e) {
    print("Error: $e");
    return "Terjadi kesalahan, silakan coba lagi";
  }
}

Future logOut(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Welcomepages()),
  );
}
