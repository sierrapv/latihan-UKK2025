import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onUserCreated});

  final VoidCallback onUserCreated;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _selectedJabatan;
  bool _isPasswordVisible = false;

  Future _registerUser() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final jabatan = _selectedJabatan;

    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    final existingUser = await supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email sudah terdaftar")),
      );
      return;
    }

    final response = await supabase.from("users").insert({
      'email': email,
      'username': username,
      'password': hashedPassword,
      'plain_password': password,
      'role': jabatan,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registrasi berhasil")),
    );

    widget.onUserCreated();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.chevron_left)),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: defaultMargin),
          children: [
            Image.asset('assets/images/2968290.jpg',
                height: 350, fit: BoxFit.fill),
            const SizedBox(height: 15),
            Text("Buat Akun Baru!", style: secondTextStyle),
            const SizedBox(height: 20),
            Text("Username", style: thirdTextStyle),
            const SizedBox(height: 5),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Masukkan Username',
                hintStyle: fourthTextStyle.copyWith(
                    fontSize: 12, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: greyColor, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("Email", style: thirdTextStyle),
            const SizedBox(height: 5),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Masukkan Email',
                hintStyle: fourthTextStyle.copyWith(
                    fontSize: 12, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: greyColor, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("Kata Sandi", style: thirdTextStyle),
            const SizedBox(height: 5),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Masukkan Kata Sandi',
                hintStyle: fourthTextStyle.copyWith(
                    fontSize: 12, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: greyColor, width: 2.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: greyColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("Role", style: thirdTextStyle),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: _selectedJabatan,
              items: [
                'Admin',
                'Pegawai',
              ].map((jabatan) {
                return DropdownMenuItem(
                  value: jabatan,
                  child: Text(jabatan, style: thirdTextStyle),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJabatan = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: greyColor, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: _registerUser,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                backgroundColor: MaterialStateProperty.all(secondaryColor),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              child: Text(
                'Daftar',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
