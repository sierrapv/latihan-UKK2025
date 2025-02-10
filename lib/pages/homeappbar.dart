import 'package:flutter/material.dart';
import 'package:latihankasirapp/pages/profil.dart';
import 'package:latihankasirapp/service/auth.dart';
import 'theme.dart';

class Homeappbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          //appbar untuk home page
          Text(
            "Kasir Pintar",
            style: secondTextStyle.copyWith(
                fontSize: 25,
                fontWeight: FontWeight.bold), // Membuat tulisan lebih besar
          ),
          Spacer(), // Memastikan ikon keluar berada di kanan
          IconButton(
            icon: Icon(
              Icons.person,
              size: 30,
              color: secondaryColor,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
    );
  }
}
