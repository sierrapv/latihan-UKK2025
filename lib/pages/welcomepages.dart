import 'package:flutter/material.dart';
import 'package:latihankasirapp/components/bottombar.dart';
import 'package:latihankasirapp/pages/homepage.dart';
// import 'package:latihankasirapp/pages/homepage.dart';
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

  Future _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final isSuccess = await auth(email, password);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomBar()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email atau Password Anda salah!")));
    }
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
                height: 250, fit: BoxFit.fill),
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
              obscureText:
                  !_isPasswordVisible, //field memasukkan sandi dengan biar bisa dilihat - disensor
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
                        : Icons
                            .visibility_off, //logika yang mengubah sandi bisa dilihat atau tidak
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
