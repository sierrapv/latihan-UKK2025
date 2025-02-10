import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future seedDataOnce() async { //untuk melihat data sekali
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('users')
        .select()
        .eq('email', 'adminsierra@gmail.com')
        .maybeSingle();

    if (response == null) {
      final hashedPassword = BCrypt.hashpw('admin123', BCrypt.gensalt());
      await supabase.from('users').insert({
        'email': 'adminsierra@gmail.com',
        'username': 'Adminsierra',
        'password': hashedPassword,
        'role': 'Admin',
      });
    } else {
      // ignore: avoid_print
      print('User dengan email adminsierra@gmail.com sudah ada.');
    }
  } catch (e) {
    // ignore: avoid_print
    print("Error $e");
  }
}