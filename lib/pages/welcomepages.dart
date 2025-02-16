import 'package:flutter/material.dart';
import 'package:latihankasirapp/components/bottombar.dart';
import 'package:latihankasirapp/pages/homepage.dart';
import 'theme.dart';
import 'package:latihankasirapp/service/auth.dart';

class Welcomepages extends StatefulWidget {
  const Welcomepages({super.key});

  @override
  State<Welcomepages> createState() => _WelcomepagesState();
}

class _WelcomepagesState extends State<Welcomepages> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  Future _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailError = "Email tidak boleh kosong";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = "Password tidak boleh kosong";
      });
      return;
    }

    final errorMessage = await auth(email, password);

    if (errorMessage != null) {
      setState(() {
        if (errorMessage.contains("Email")) {
          _emailError = errorMessage;
        } else {
          _passwordError = errorMessage;
        }
      });
      return;
    }

    // Jika sukses login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomBar()),
    );
  }

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: defaultMargin),
          children: [
            Image.asset('assets/images/4860253.jpg',
                height: 250, width: double.infinity, fit: BoxFit.contain),
            const SizedBox(
              height: 15,
            ),
            Text(
              "Selamat Datang!",
              style: secondTextStyle,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Email",
              style: thirdTextStyle,
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Masukkan Email',
                hintStyle: fourthTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: greyColor, width: 2.0),
                ),
                errorText: _emailError, // Tambahkan ini
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Kata Sandi",
              style: thirdTextStyle,
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Masukkan Kata Sandi',
                hintStyle: fourthTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
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
                errorText: _passwordError, // Tambahkan ini
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: _handleLogin,
              style: ButtonStyle(
                padding: MaterialStateProperty.resolveWith((states) {
                  return const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15);
                }),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return const Color.fromARGB(255, 224, 13, 13);
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.white;
                }),
                shape: MaterialStateProperty.resolveWith((states) {
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  );
                }),
              ),
              child: Text(
                'Masuk',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Text("Lupa password?",
            //     textAlign: TextAlign.right,
            //     style: thirdTextStyle.copyWith(
            //       fontSize: 10,
            //     )),
          ],
        ),
      ),
    );
  }
}
