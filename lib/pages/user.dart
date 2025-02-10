import 'package:flutter/material.dart';
import 'package:latihankasirapp/pages/register.dart';
import 'package:latihankasirapp/pages/theme.dart';
import 'package:latihankasirapp/pages/homeappbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

final supabase = Supabase.instance.client;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Map<String, dynamic>> users = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future fetchUsers() async {
    final response = await supabase
        .from('users')
        .select()
        .order('create_at', ascending: false);
    setState(() {
      users = List<Map<String, dynamic>>.from(response);
    });
  }

  void _editUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController usernameController =
            TextEditingController(text: user['username']);
        TextEditingController emailController =
            TextEditingController(text: user['email']);
        String? selectedRole = user['role'];

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text("Edit User", style: TextStyle(color: secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(color: secondaryColor),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: secondaryColor),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['Admin', 'Pegawai'].map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role, style: TextStyle(color: secondaryColor)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedRole = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: greyColor, width: 2.0),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _ubahPassword(user); // Memanggil popup untuk mengubah password
              },
              child: Text("Ubah Password", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal", style: TextStyle(color: secondaryColor)),
            ),
            TextButton(
              onPressed: () async {
                // Get updated values
                String updatedUsername = usernameController.text.trim();
                String updatedEmail = emailController.text.trim();
                String updatedRole =
                    selectedRole ?? 'Admin'; // Use 'Admin' as default if null

                if (updatedUsername.isNotEmpty && updatedEmail.isNotEmpty) {
                  // Update user in Supabase
                  final response = await supabase.from('users').update({
                    'username': updatedUsername,
                    'email': updatedEmail,
                    'role': updatedRole,
                  }).eq('id', user['id']);

                  if (response == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User updated successfully!')),
                    );
                    fetchUsers(); // Refresh the user list
                    Navigator.pop(context); // Close the dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating user!')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Username and email cannot be empty')),
                  );
                }
              },
              child: Text("Simpan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: secondaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _ubahPassword(Map<String, dynamic> user) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text("Ubah Password", style: TextStyle(color: secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password Baru",
                  labelStyle: TextStyle(color: secondaryColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal", style: TextStyle(color: secondaryColor)),
            ),
            TextButton(
              onPressed: () async {
                final newPassword = passwordController.text.trim();
                if (newPassword.isNotEmpty) {
                  final hashedPassword =
                      BCrypt.hashpw(newPassword, BCrypt.gensalt());
                  await supabase.from('users').update(
                    {
                      'password': hashedPassword,
                      'plain_password': newPassword,
                    },
                  ).eq('id', user['id']);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Password updated successfully!')));
                  Navigator.pop(
                      context); // Menutup dialog setelah password diubah
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password tidak boleh kosong')));
                }
              },
              child: Text("Simpan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: secondaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future _destroyUser(int userId) async {
          final response =
              await supabase.from('users').delete().match({'id': userId});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User berhasil dihapus!')),
          );

          fetchUsers();
          Navigator.pop(context);
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text("Hapus User", style: TextStyle(color: secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text("Anda yakin ingin menghapus user ini?")],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal", style: TextStyle(color: secondaryColor)),
            ),
            TextButton(
              onPressed: () => _destroyUser(user['id']),
              child: Text("Hapus",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: secondaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final username = user['username'].toLowerCase() ?? '';
      return username.contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjust the height
        child: Homeappbar(), // Your custom app bar
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ketik untuk cari...",
                prefixIcon: Icon(Icons.search, color: secondaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daftar User",
                  style: sixTextStyle.copyWith(
                    fontSize: 18,
                    color: secondaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: secondaryColor, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(
                          onUserCreated: fetchUsers,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                if (!user['username'].toLowerCase().contains(searchQuery)) {
                  return SizedBox.shrink();
                }
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      user['username'],
                      style: sevenTextStyle.copyWith(
                          fontWeight: FontWeight.bold, color: secondaryColor),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${user['email']}",
                            style:
                                sevenTextStyle.copyWith(color: secondaryColor)),
                        Text("Role: ${user['role']}",
                            style:
                                sevenTextStyle.copyWith(color: secondaryColor)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue[900]),
                          onPressed: () => _editUser(user),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[900]),
                          onPressed: () => _deleteUser(user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: backgroundPageColor,
    );
  }
}
