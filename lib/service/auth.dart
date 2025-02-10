import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latihankasirapp/pages/welcomepages.dart';

final supabase = Supabase.instance.client;

Future auth(String email, String password) async {
  try{
    final response = await supabase
      .from('users')
      .select('id, password') //select data yang akan digunakan
      .eq('email', email) //pengecekan email
      .maybeSingle(); //data kosong atau 1

    final hashedPassword = response!['password']; //cek password inputan users apakah sudah sama dengan enkripsi yang ada
    final userId = response['id'].toString();

    if (BCrypt.checkpw(password, hashedPassword)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);

      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("Error: $e");
    return false;
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