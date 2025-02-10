import 'package:flutter/material.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:latihankasirapp/service/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  Future getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final response = await supabase
        .from('users')
        .select('username, role')
        .eq('id', userId as Object)
        .maybeSingle();

    final username = response?['username'] as String?;
    final role = response?['role'] as String?;
    return {
      "username": username,
      "role": role,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Loading state
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text("Gagal memuat profil."));
        }

        final userInfo = snapshot.data;
        final username = userInfo['username'];
        final role = userInfo['role'];

        return Scaffold(
          backgroundColor: backgroundPageColor,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.chevron_left)),
          ),
          body: Center(
            child: Container(
              width: 350,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: secondaryColor,
                    child: Icon(Icons.calculate, color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 6),
                      Text(username,
                          style: sevenTextStyle.copyWith(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work, size: 20),
                      SizedBox(width: 6),
                      Text(role, style: sevenTextStyle),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    ),
                    onPressed: () => logOut(context),
                    child:
                        Text("Logout", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
